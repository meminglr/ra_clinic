import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';

class SyncProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Kullanıcı ID'si (Login olunca set edilecek)
  String? _userId; 

  StreamSubscription? _customerSubscription;
  StreamSubscription? _calendarSubscription;
  StreamSubscription? _internetSubscription;

  // UI'da loading göstermek için durum değişkeni
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // Hive Kutuları
  Box<CustomerModel> get _customerBox => Hive.box<CustomerModel>("customersBox");
  Box<Schedule> get _scheduleBox => Hive.box<Schedule>("scheduleBox");
  Box get _settingsBox => Hive.box("settingsBox");

  // --- AYARLAR ---
  bool get isSyncEnabled => _settingsBox.get("isSyncEnabled", defaultValue: true);

  // ===========================================================================
  // 1. BAŞLATMA (INIT) - HomePage'de çağırılacak
  // ===========================================================================
  void init(String uid) {
    if (_userId == uid) return; // Zaten bu kullanıcı ile çalışıyor
    _userId = uid;
    
    // Hive dinleyicilerini kur (Sadece bir kez kurulur)
    _setupHiveListeners();

    // Eğer ayar açıksa sistemi başlat
    if (isSyncEnabled && _userId != null) {
      _startRemoteListening();
      syncNow(); // Bekleyenleri gönder
    }
  }

  // ===========================================================================
  // 2. KONTROL (SWITCH & BUTTONS)
  // ===========================================================================
  
  // Switch'e basınca çağırılacak
  void toggleSync(bool value) {
    _settingsBox.put('isSyncEnabled', value);
    notifyListeners(); // Switch UI güncellensin

    if (value) {
      print("🟢 Senkronizasyon AÇILDI");
      _startRemoteListening();
      syncNow();
    } else {
      print("🔴 Senkronizasyon KAPATILDI");
      _stopRemoteListening();
    }
  }

  // Manuel tetikleme veya otomatik tetikleme için
  Future<void> syncNow() async {
    if (!isSyncEnabled || _userId == null) return;
    
    // İnternet kontrolü
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    // UI'a "Yükleniyor" bilgisi ver
    _isSyncing = true;
    notifyListeners();

    // İşlemleri yap
    await _syncCustomers();
    await _syncCalendar();

    // İşlem bitti
    _isSyncing = false;
    notifyListeners();
  }

  // ===========================================================================
  // 3. INTERNAL SYNC LOGIC (PUSH)
  // ===========================================================================

  Future<void> _syncCustomers() async {
    var unsyncedList = _customerBox.values.where((c) => !c.isSynced).toList();
    if (unsyncedList.isEmpty) return;

    for (var localData in unsyncedList) {
      try {
        DocumentReference ref = _firestore.collection('users').doc(_userId).collection('customers').doc(localData.customerId);
        if (localData.isDeleted) {
          await ref.delete();
          await _customerBox.delete(localData.customerId);
        } else {
          await ref.set(localData.toMap(), SetOptions(merge: true));
          await _customerBox.put(localData.customerId, localData.copyWith(isSynced: true));
        }
      } catch (e) {
        print("Sync Hatası: $e");
      }
    }
  }

  Future<void> _syncCalendar() async {
    var unsyncedEvents = _scheduleBox.values.where((e) => !e.isSynced).toList();
    if (unsyncedEvents.isEmpty) return;

    for (var event in unsyncedEvents) {
      try {
        DocumentReference ref = _firestore.collection('users').doc(_userId).collection('calendar').doc(event.id);
        if (event.isDeleted) {
          await ref.delete();
          await _scheduleBox.delete(event.id);
        } else {
          await ref.set(event.toMap(), SetOptions(merge: true));
          await _scheduleBox.put(event.id, event.copyWith(isSynced: true));
        }
      } catch (e) {
        print("Takvim Sync Hatası: $e");
      }
    }
  }

  // ===========================================================================
  // 4. LISTENERS (PULL & LOCAL WATCH)
  // ===========================================================================

  void _setupHiveListeners() {
    // Localde müşteri değişirse -> Gönder
    _customerBox.listenable().addListener(() {
      if (isSyncEnabled && _userId != null) syncNow();
    });

    // Localde takvim değişirse -> Gönder
    _scheduleBox.listenable().addListener(() {
      if (isSyncEnabled && _userId != null) syncNow();
    });

    // İnternet gelirse -> Gönder
    _internetSubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && isSyncEnabled && _userId != null) {
        syncNow();
      }
    });
  }

  void _startRemoteListening() {
    if (_userId == null) return;
    if (_customerSubscription != null) return; // Zaten dinliyor

    print("🎧 Firebase Dinleniyor...");

    // Müşterileri Dinle
    _customerSubscription = _firestore.collection('users').doc(_userId).collection('customers')
        .snapshots().listen((snap) => _processChanges(snap, isCustomer: true));

    // Takvimi Dinle
    _calendarSubscription = _firestore.collection('users').doc(_userId).collection('calendar')
        .snapshots().listen((snap) => _processChanges(snap, isCustomer: false));
  }

  void _stopRemoteListening() {
    _customerSubscription?.cancel();
    _calendarSubscription?.cancel();
    _customerSubscription = null;
    _calendarSubscription = null;
    print("🛑 Dinlemeler durduruldu.");
  }

  // Ortak Değişiklik İşleme Fonksiyonu
  Future<void> _processChanges(QuerySnapshot snapshot, {required bool isCustomer}) async {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.removed) {
        if (isCustomer) {
          await _customerBox.delete(change.doc.id);
        } else {
          await _scheduleBox.delete(change.doc.id);
        }
      } else {
        var data = change.doc.data() as Map<String, dynamic>?;
        if (data != null) {
          if (isCustomer) {
             var remote = CustomerModel.fromMap(data, change.doc.id);
             var local = _customerBox.get(remote.customerId);
             // Tarih kontrolü (Basitlik için direkt yazıyorum, tarih kontrolünü ekleyebilirsin)
             await _customerBox.put(remote.customerId, remote.copyWith(isSynced: true));
          } else {
             var remote = Schedule.fromMap(data);
             // Tarih kontrolü...
             await _scheduleBox.put(remote.id, remote.copyWith(isSynced: true));
          }
        }
      }
    }
  }
  
  // Çıkış (Logout) için temizlik
  void clear() {
    _stopRemoteListening();
    _internetSubscription?.cancel();
    _userId = null;
  }
}