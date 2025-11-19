import 'package:flutter/foundation.dart';
import 'package:ra_clinic/calendar/model/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

}