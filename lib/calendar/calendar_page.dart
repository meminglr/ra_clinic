import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/calendar/event_editin_page.dart';
import 'package:ra_clinic/providers/event_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'model/event_data_source.dart';

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (builder) => EventEditinPage()),
          );
        },
        icon: Icon(Icons.add),
        label: Text("Etkinlik Ekle"),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: EventDataSource(events),

        initialSelectedDate: DateTime.now(),
        firstDayOfWeek: 1,

        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,

          monthCellStyle: MonthCellStyle(
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          showAgenda: true,
        ),
        showDatePickerButton: true,
        showNavigationArrow: true,
        showCurrentTimeIndicator: true,

        showTodayButton: true,
      ),
    );
  }
}
