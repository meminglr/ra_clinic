import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:ra_clinic/calendar/model/schedule.dart'; // Yolunu kontrol et

class EventProvider extends ChangeNotifier {
  static const String _boxName = 'scheduleBox';
  late Box<Schedule> _box;

  EventProvider() {
    _box = Hive.box<Schedule>(_boxName);
    
    // SyncService dışarıdan veri eklediğinde (Firebase'den gelince)
    // UI'ın haberi olsun diye dinleyici ekliyoruz.
    _box.listenable().addListener(() {
      notifyListeners();
    });
  }

  // Getter: Sadece silinmemişleri getir
  List<Schedule> get events => _box.values.where((e) => !e.isDeleted).toList();

  // --- ETKİNLİK EKLEME ---
  Future<void> addEvent(Schedule event) async {
    // ID boş gelirse UUID oluştur
    String finalId = event.id.isEmpty ? const Uuid().v4() : event.id;

    final newEvent = event.copyWith(
      id: finalId,
      isSynced: false,
      isDeleted: false,
      lastUpdated: DateTime.now(),
    );

    // UUID anahtarı ile kaydet
    await _box.put(finalId, newEvent);
    notifyListeners();
  }

  // --- ETKİNLİK GÜNCELLEME ---
  Future<void> updateEvent(Schedule updatedEvent) async {
    final eventToSave = updatedEvent.copyWith(
      isSynced: false, // Değiştiği için tekrar gönderilmeli
      lastUpdated: DateTime.now(),
    );

    await _box.put(eventToSave.id, eventToSave);
    notifyListeners();
  }

  // --- ETKİNLİK SİLME (SOFT DELETE) ---
  Future<void> deleteEvent(String id) async {
    final event = _box.get(id);
    if (event != null) {
      final deletedEvent = event.copyWith(
        isDeleted: true,
        isSynced: false, // Silindiği bilgisi server'a gitmeli
        lastUpdated: DateTime.now(),
      );

      await _box.put(id, deletedEvent);
      notifyListeners();
    }
  }
  
  // Tümünü Temizle (Geliştirme aşamasında lazım olabilir)
  Future<void> clearLocalData() async {
    await _box.clear();
    notifyListeners();
  }
}