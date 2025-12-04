import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ra_clinic/model/costumer_model.dart'; // Model dosyanın yolu

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId; // Hangi kullanıcının verisi senkronize edilecek?
  StreamSubscription? _remoteSubscription; // Dinlemeyi durdurmak için gerekli

  SyncService(this.userId);

  // Hive Kutusuna hızlı erişim
  Box<CustomerModel> get _box => Hive.box<CustomerModel>("customersBox");

  // ===========================================================================
  // 1. PUSH: LOCAL -> FIREBASE (Bizdeki değişiklikleri gönder)
  // ===========================================================================
  Future<void> syncLocalToRemote() async {
    // İnternet var mı kontrol et
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("İnternet yok, sync iptal.");
      return;
    }

    // Gönderilmeyi bekleyenleri bul (isSynced == false)
    var unsyncedList = _box.values.where((c) => !c.isSynced).toList();

    if (unsyncedList.isEmpty) return; // Yapacak iş yok

    print("📤 Sync Başladı: ${unsyncedList.length} veri gönderiliyor...");

    for (var localData in unsyncedList) {
      try {
        DocumentReference ref = _firestore
            .collection('users')
            .doc(userId)
            .collection('customers')
            .doc(localData.customerId); // UUID eşleşmesi

        if (localData.isDeleted) {
          // --- SENARYO A: SİLİNMİŞ VERİ ---
          // Eğer soft delete ise, Firebase'den tamamen siliyoruz
          await ref.delete();
          
          // Firebase'den sildik, artık Local'den de tamamen uçurabiliriz (yer kaplamasın)
          await _box.delete(localData.customerId); 
          print("🗑️ Silindi: ${localData.name}");

        } else {
          // --- SENARYO B: EKLENMİŞ / GÜNCELLENMİŞ VERİ ---
          // Modelindeki toMap() metodu seansları da kapsadığı için
          // Müşteriyi gönderince seanslar da otomatik gider!
          await ref.set(localData.toMap(), SetOptions(merge: true));

          // Başarılı oldu, Local'de "Eşitlendi" olarak işaretle
          // copyWith kullanarak sadece isSynced alanını değiştiriyoruz
          final syncedData = localData.copyWith(isSynced: true);
          await _box.put(localData.customerId, syncedData);
          print("✅ Gönderildi: ${localData.name}");
        }
      } catch (e) {
        print("❌ Hata (${localData.name}): $e");
        // Hata olursa isSynced false kalır, sonraki denemede tekrar gider.
      }
    }
  }

  // ===========================================================================
  // 2. PULL: FIREBASE -> LOCAL (Serverdaki değişiklikleri dinle)
  // ===========================================================================
  void startListeningToRemoteChanges() {
    print("🎧 Firebase dinleniyor...");
    
    _remoteSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('customers')
        .snapshots() // Canlı yayın (Stream)
        .listen((snapshot) async {

      for (var change in snapshot.docChanges) {
        // --- DURUM 1: SERVERDAN SİLİNMİŞ ---
        if (change.type == DocumentChangeType.removed) {
          // Serverdan silindiyse, localden de sil
          await _box.delete(change.doc.id);
          print("📥 Serverdan silindiği için localden silindi: ${change.doc.id}");
        } 
        // --- DURUM 2: SERVERA EKLENMİŞ VEYA DEĞİŞMİŞ ---
        else {
          final remoteDataMap = change.doc.data();
          if (remoteDataMap != null) {
            // Firebase map'ini bizim modele çevir
            final remoteCustomer = CustomerModel.fromMap(remoteDataMap, change.doc.id);
            
            // ÇAKIŞMA KONTROLÜ (Conflict Resolution)
            final localCustomer = _box.get(remoteCustomer.customerId);

            bool shouldUpdateLocal = false;

            if (localCustomer == null) {
              // Localde hiç yoksa, kesin ekle (Yeni gelmiş)
              shouldUpdateLocal = true;
            } else {
              // Localde varsa tarihlere bak:
              // Eğer Server'daki tarih > Local'deki tarih ise güncelle.
              // (Eşitse güncelleme, yoksa sonsuz döngüye gireriz)
              if (remoteCustomer.lastUpdated != null && localCustomer.lastUpdated != null) {
                 if (remoteCustomer.lastUpdated!.isAfter(localCustomer.lastUpdated!)) {
                   shouldUpdateLocal = true;
                 }
              }
            }

            if (shouldUpdateLocal) {
              // Local veritabanına kaydet
              // ÖNEMLİ: isSynced: true olarak kaydediyoruz ki tekrar geri göndermesin.
              final dataToSave = remoteCustomer.copyWith(isSynced: true);
              await _box.put(dataToSave.customerId, dataToSave);
              print("📥 Serverdan güncel veri geldi: ${dataToSave.name}");
            }
          }
        }
      }
    });
  }

  // Dinlemeyi durdur (Örn: Çıkış yapınca)
  void stopListening() {
    _remoteSubscription?.cancel();
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