import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';

class EventProvider extends ChangeNotifier {
  late Box<Schedule> _box;

  EventProvider() {
    _box = Hive.box<Schedule>('scheduleBox');
    _events = _box.values.toList();
  }

  List<Schedule> _events = [];

  List<Schedule> get events => _events;

  /// Benzersiz int ID üret
  int generateId() {
    if (_box.isEmpty) return 1;
    final ids = _box.values.map((e) => e.id).toList();
    ids.sort();
    return ids.last + 1;
  }

  void addEvent(Schedule event) {
    // 1) benzersiz int ID üret
    final newId = generateId();
    event.id = newId;

    // 2) Hive auto key ile kaydet (key önemli değil)
    _box.add(event);

    // 3) Listeyi yenile
    _events = _box.values.toList();
    notifyListeners();
  }

  void updateEvent(Schedule updatedEvent) {
    // HiveObject’ı yeniden box'a eklemeye çalışmak yerine, key bul ve putAt kullan
    final key = _box.keys.firstWhere(
      (k) => _box.get(k)?.id == updatedEvent.id,
      orElse: () => null,
    );

    if (key != null) {
      _box.put(key, updatedEvent);
      _events = _box.values.toList();
      notifyListeners();
    }
  }

  void deleteEvent(int id) {
    // Hive box içindeki itemleri kontrol et ve id eşleşenleri sil
    final keyToDelete = _box.keys.firstWhere(
      (key) => _box.get(key)?.id == id,
      orElse: () => null,
    );

    if (keyToDelete != null) {
      _box.delete(keyToDelete);
      _events = _box.values.toList();
      notifyListeners();
    }
  }

  Future<void> resetAllEvents() async {
    await _box.clear(); // Hive verilerini temizle
    _events = _box.values.toList(); // provider listesini güncelle
    notifyListeners();
  }
}
