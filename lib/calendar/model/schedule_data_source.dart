import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'schedule.dart';

class ScheduleDataSource extends CalendarDataSource<Schedule> {
  List<Schedule> source;

  ScheduleDataSource(this.source);

  @override
  List<dynamic> get appointments => source;

  @override
  Object? getId(int index) {
    return source[index].id;
  }

  @override
  DateTime getStartTime(int index) {
    return source[index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return source[index].endDate;
  }

  @override
  String getSubject(int index) {
    return source[index].name;
  }

  @override
  Color getColor(int index) {
    return source[index].color;
  }

  @override
  bool isAllDay(int index) {
    return source[index].isAllDay;
  }

  @override
  Schedule? convertAppointmentToObject(
    Schedule? customData,
    Appointment appointment,
  ) {
    return customData;
  }
}
