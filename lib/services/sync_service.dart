import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ra_clinic/model/costumer_model.dart'; // Müşteri Modeli
import 'package:ra_clinic/calendar/model/schedule.dart'; // Takvim Modeli (Bunu import etmeyi unutma)

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  
  // İki ayrı dinleyiciye ihtiyacımız var, çünkü iki farklı koleksiyon dinliyoruz
  StreamSubscription? _customerSubscription;
  StreamSubscription? _calendarSubscription;

  SyncService(this.userId);

  // Hive Kutularına hızlı erişim
  Box<CustomerModel> get _customerBox => Hive.box<CustomerModel>("customersBox");
  Box<Schedule> get _scheduleBox => Hive.box<Schedule>("scheduleBox"); // Takvim kutusu

  // ===========================================================================
  // 1. PUSH: LOCAL -> FIREBASE (Bizdeki değişiklikleri gönder)
  // ===========================================================================
  
  // Bu ana fonksiyon, hem müşterileri hem takvimi tetikler
  Future<void> syncLocalToRemote() async {
    // İnternet kontrolü
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("İnternet yok, sync iptal.");
      return;
    }

    // İkisini de sırayla gönder
    await _syncCustomers();
    await _syncCalendar();
  }

  // --- MÜŞTERİLERİ GÖNDER (Senin eski kodun) ---
  Future<void> _syncCustomers() async {
    var unsyncedList = _customerBox.values.where((c) => !c.isSynced).toList();
    if (unsyncedList.isEmpty) return;

    print("📤 Müşteri Sync Başladı: ${unsyncedList.length} veri...");

    for (var localData in unsyncedList) {
      try {
        DocumentReference ref = _firestore
            .collection('users')
            .doc(userId)
            .collection('customers')
            .doc(localData.customerId);

        if (localData.isDeleted) {
          await ref.delete();
          await _customerBox.delete(localData.customerId);
          print("🗑️ Müşteri Silindi: ${localData.name}");
        } else {
          await ref.set(localData.toMap(), SetOptions(merge: true));
          final syncedData = localData.copyWith(isSynced: true);
          await _customerBox.put(localData.customerId, syncedData);
          print("✅ Müşteri Gönderildi: ${localData.name}");
        }
      } catch (e) {
        print("❌ Müşteri Hata (${localData.name}): $e");
      }
    }
  }

  // --- TAKVİMİ GÖNDER (Yeni Eklenen Kısım) ---
  Future<void> _syncCalendar() async {
    // Takvim kutusunda senkronize olmamışları bul
    var unsyncedEvents = _scheduleBox.values.where((e) => !e.isSynced).toList();
    if (unsyncedEvents.isEmpty) return;

    print("📅 Takvim Sync Başladı: ${unsyncedEvents.length} etkinlik...");

    for (var event in unsyncedEvents) {
      try {
        DocumentReference ref = _firestore
            .collection('users')
            .doc(userId)
            .collection('calendar') // Takvim koleksiyonu
            .doc(event.id);

        if (event.isDeleted) {
          await ref.delete();
          await _scheduleBox.delete(event.id); // Localden tamamen sil
          print("🗑️ Etkinlik Silindi: ${event.name}");
        } else {
          await ref.set(event.toMap(), SetOptions(merge: true));
          
          // isSynced = true yapıp kaydet
          final syncedEvent = event.copyWith(isSynced: true);
          await _scheduleBox.put(event.id, syncedEvent);
          print("✅ Etkinlik Gönderildi: ${event.name}");
        }
      } catch (e) {
        print("❌ Takvim Hata (${event.name}): $e");
      }
    }
  }

  // ===========================================================================
  // 2. PULL: FIREBASE -> LOCAL (Serverdaki değişiklikleri dinle)
  // ===========================================================================
  void startListeningToRemoteChanges() {
    print("🎧 Firebase (Müşteri ve Takvim) dinleniyor...");
    
    // --- MÜŞTERİLERİ DİNLE ---
    _customerSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('customers')
        .snapshots()
        .listen((snapshot) {
           _processCustomerChanges(snapshot);
        });

    // --- TAKVİMİ DİNLE (YENİ) ---
    _calendarSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('calendar')
        .snapshots()
        .listen((snapshot) {
           _processCalendarChanges(snapshot);
        });
  }

  // Müşteri Değişikliklerini İşle
  Future<void> _processCustomerChanges(QuerySnapshot snapshot) async {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await _customerBox.delete(change.doc.id);
        print("📥 Serverdan müşteri silindi: ${change.doc.id}");
      } else {
        final remoteDataMap = change.doc.data() as Map<String, dynamic>?;
        if (remoteDataMap != null) {
          final remoteCustomer = CustomerModel.fromMap(remoteDataMap, change.doc.id);
          final localCustomer = _customerBox.get(remoteCustomer.customerId);

          bool shouldUpdateLocal = false;
          if (localCustomer == null) {
            shouldUpdateLocal = true;
          } else {
            // Tarih kontrolü
            if (remoteCustomer.lastUpdated != null && localCustomer.lastUpdated != null) {
               if (remoteCustomer.lastUpdated!.isAfter(localCustomer.lastUpdated!)) {
                 shouldUpdateLocal = true;
               }
            }
          }

          if (shouldUpdateLocal) {
            final dataToSave = remoteCustomer.copyWith(isSynced: true);
            await _customerBox.put(dataToSave.customerId, dataToSave);
            print("📥 Serverdan müşteri güncellendi: ${dataToSave.name}");
          }
        }
      }
    }
  }

  // Takvim Değişikliklerini İşle (YENİ)
  Future<void> _processCalendarChanges(QuerySnapshot snapshot) async {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        await _scheduleBox.delete(change.doc.id);
        print("📥 Serverdan etkinlik silindi: ${change.doc.id}");
      } else {
        final remoteDataMap = change.doc.data() as Map<String, dynamic>?;
        if (remoteDataMap != null) {
          // Schedule modelinde fromMap olduğunu varsayıyorum
          final remoteEvent = Schedule.fromMap(remoteDataMap); 
          final localEvent = _scheduleBox.get(remoteEvent.id);

          bool shouldUpdateLocal = false;
          if (localEvent == null) {
            shouldUpdateLocal = true;
          } else {
            // Tarih kontrolü
            if (remoteEvent.lastUpdated != null && localEvent.lastUpdated != null) {
               if (remoteEvent.lastUpdated!.isAfter(localEvent.lastUpdated!)) {
                 shouldUpdateLocal = true;
               }
            }
          }

          if (shouldUpdateLocal) {
            final dataToSave = remoteEvent.copyWith(isSynced: true);
            await _scheduleBox.put(dataToSave.id, dataToSave);
            print("📥 Serverdan etkinlik güncellendi: ${dataToSave.name}");
          }
        }
      }
    }
  }

  // Dinlemeyi durdur
  void stopListening() {
    _customerSubscription?.cancel();
    _calendarSubscription?.cancel();
    print("🛑 Dinlemeler durduruldu.");
  }
}







// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:ra_clinic/model/costumer_model.dart';

// class SyncService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final String userId; // Giriş yapmış kullanıcının UID'si

//   SyncService(this.userId);

//   // Hive Kutusunu çağırıyoruz
//   Box<CustomerModel> get _box => Hive.box<CustomerModel>("customersBox");

//   // --- İŞLEM 1: LOCAL -> FIREBASE (PUSH) ---
//   Future<void> syncLocalChangesToFirebase() async {
//     // 1. İnternet var mı kontrol et
//     var connectivityResult = await (Connectivity().checkConnectivity());
//     if (connectivityResult == ConnectivityResult.none) return;

//     // 2. isSynced == false olanları bul
//     // (Silinmişler de dahil, çünkü Firebase'den de silmemiz lazım)
//     var unsyncedCustomers = _box.values.where((c) => c.isSynced == false).toList();

//     if (unsyncedCustomers.isEmpty) return; // Gönderilecek bir şey yok

//     print("Senkronizasyon Başladı: ${unsyncedCustomers.length} veri gönderilecek.");

//     for (var customer in unsyncedCustomers) {
//       try {
//         DocumentReference ref = _firestore
//             .collection('users')
//             .doc(userId)
//             .collection('customers')
//             .doc(customer.customerId); // UUID burada devreye giriyor

//         if (customer.isDeleted) {
//           // --- SİLME SENARYOSU ---
//           // Eğer soft delete ise, Firebase'de isDeleted:true yapabiliriz
//           // veya veriyi tamamen silebiliriz. Genelde tamamen silmek temizdir.
//           await ref.delete();
          
//           // Firebase'den sildikten sonra, artık Local Hive'dan da tamamen uçurabiliriz
//           await _box.delete(customer.customerId);
          
//         } else {
//           // --- EKLEME / GÜNCELLEME SENARYOSU ---
//           // toMap fonksiyonun seansları da kapsadığı için seanslar da gider
//           await ref.set(customer.toMap(), SetOptions(merge: true));
          
//           // Başarılı oldu, bayrağı düzelt
//           final syncedCustomer = customer.copyWith(isSynced: true);
//           await _box.put(customer.customerId, syncedCustomer);
//         }
//       } catch (e) {
//         print("Hata oluştu (${customer.name}): $e");
//         // Hata olursa isSynced false kalır, bir sonraki sefere tekrar denenir.
//       }
//     }
//     print("Senkronizasyon Bitti.");
//   }
// }