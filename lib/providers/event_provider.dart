import 'package:flutter/foundation.dart';
import 'package:ra_clinic/calendar/model/event.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';

class EventProvider extends ChangeNotifier {
  List<Schedule> _events = [];

  List<Schedule> get events => _events;

  void addEvent(Schedule event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(Schedule updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

    void deleteEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }
  
}
