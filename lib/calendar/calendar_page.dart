import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/calendar/event_editin_page.dart';
import 'package:ra_clinic/calendar/model/event.dart';
import 'package:ra_clinic/providers/event_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'model/event_data_source.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? selectedDate;

  CalendarController controller = CalendarController();
  CalendarView calendarView = CalendarView.month;

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (builder) =>
                  EventEditinPage(selectedDate: selectedDate!),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text("Etkinlik Ekle"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [buildCalendarViewOptions(controller)],
          ),
          Expanded(child: buildCalendar(events)),
        ],
      ),
    );
  }

  SfCalendar buildCalendar(List<Event> events) {
    return SfCalendar(
      view: calendarView,
      dataSource: EventDataSource(events),
      controller: controller,
      onSelectionChanged: (calendarSelectionDetails) {
        if (calendarSelectionDetails.date != null) {
          selectedDate = calendarSelectionDetails.date!;
        }
      },

      initialSelectedDate: DateTime.now(),
      firstDayOfWeek: 1,

      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
        agendaViewHeight: 300,

        monthCellStyle: MonthCellStyle(
          textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        showAgenda: true,
      ),
      showDatePickerButton: true,
      showCurrentTimeIndicator: true,
      showTodayButton: true,

      headerStyle: CalendarHeaderStyle(backgroundColor: Colors.white),
    );
  }

  Widget buildCalendarViewOptions(CalendarController controller) =>
      PullDownButton(
        routeTheme: PullDownMenuRouteTheme(backgroundColor: Colors.white),
        itemBuilder: (context) => [
          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.month,
            onTap: () {
              setState(() {
                controller.view = CalendarView.month;
              });
            },
            title: "Ay Görünüm",
          ),

          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.day,
            onTap: () {
              setState(() {
                controller.view = CalendarView.day;
              });
            },
            title: "Gün Görünüm",
          ),
          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.week,
            onTap: () {
              setState(() {
                controller.view = CalendarView.week;
              });
            },
            title: "Hafta Görünüm",
          ),
          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.schedule,
            onTap: () {
              setState(() {
                controller.view = CalendarView.schedule;
              });
            },
            title: "Etkinlik Görünümü ",
          ),
          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.timelineDay,
            onTap: () {
              setState(() {
                controller.view = CalendarView.timelineDay;
              });
            },
            title: "Zamanlayıcı Görünüm",
          ),
          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.timelineMonth,
            onTap: () {
              setState(() {
                controller.view = CalendarView.timelineMonth;
              });
            },
            title: "Zamanlayıcı Ay Görünüm",
          ),
          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.timelineWeek,
            onTap: () {
              setState(() {
                controller.view = CalendarView.timelineWeek;
              });
            },
            title: "Zamanlayıcı Hafta Görünüm",
          ),
          PullDownMenuItem.selectable(
            selected: controller.view == CalendarView.timelineWorkWeek,
            onTap: () {
              setState(() {
                controller.view = CalendarView.timelineWorkWeek;
              });
            },
            title: "Zamanlayıcı Çalışma Hafta Görünüm",
          ),
        ],
        position: PullDownMenuPosition.automatic,
        buttonBuilder: (context, showMenu) => GestureDetector(
          behavior: HitTestBehavior.translucent,

          onTap: () {
            showMenu();
          },
          child: Padding(
            padding: const EdgeInsets.only(
              left: 5,
              top: 20,
              bottom: 20,
              right: 5,
            ),
            child: Icon(Icons.more_vert),
          ),
        ),
      );

  Widget builda(params) => Container();
}
