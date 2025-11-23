import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/calendar/calendar_widgets/event_dialogs.dart';
import 'package:ra_clinic/calendar/event_editin_page.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';
import 'package:ra_clinic/calendar/model/schedule_data_source.dart';
import 'package:ra_clinic/providers/event_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController _calendarController = CalendarController();
  DateTime? selectedDate;

  @override
  void dispose() {
    super.dispose();
    _calendarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
    return Scaffold(
      appBar: AppBar(
        title: Text("Takvim"),
        centerTitle: true,
        actions: [buildCalendarViewOptions(_calendarController)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // EventDialogsWidgets.showAddEventDialog(
          //   context,
          //   selectedDate ?? DateTime.now(),
          // );
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => EventEditinPage(selectedDate: selectedDate!),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text("Etkinlik Ekle"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SfCalendar(
                controller: _calendarController,
                view: CalendarView.month,
                dataSource: ScheduleDataSource(events),
                initialSelectedDate: DateTime.now(),
                firstDayOfWeek: 1,
                showCurrentTimeIndicator: false,
                onSelectionChanged: (calendarSelectionDetails) {
                  if (calendarSelectionDetails.date != null) {
                    selectedDate = calendarSelectionDetails.date!;
                  }
                },
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                  appointmentDisplayCount: 3,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                ),
                allowDragAndDrop: true,
                onDragEnd: _onDragEnd,
                allowAppointmentResize: true,
                onAppointmentResizeStart: resizeStart,
                onAppointmentResizeUpdate: resizeUpdate,
                onAppointmentResizeEnd: resizeEnd,
                onLongPress: (calendarLongPressDetails) {
                  if (calendarLongPressDetails.targetElement ==
                      CalendarElement.calendarCell) {
                    EventDialogsWidgets.showAddEventDialog(
                      context,
                      calendarLongPressDetails.date!,
                    );
                  }
                },
                onTap: (calendarTapDetails) {
                  // Etkinliğe tıklandıysa detayları göster
                  if (calendarTapDetails.targetElement ==
                      CalendarElement.appointment) {
                    final Schedule tappedEvent =
                        calendarTapDetails.appointments![0];
                    EventDialogsWidgets.showEventDetailsDialog(
                      context,
                      tappedEvent,
                    );
                  }
                  // Boş tarihe tıklandıysa yeni etkinlik ekle
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDragEnd(appointmentDragEndDetails) {
    final events = Provider.of<EventProvider>(context, listen: false).events;
    final dragedItem = appointmentDragEndDetails.appointment as Schedule;
    final originItem = events.firstWhere(
      (element) => element.id == dragedItem.id,
    );
    Duration diff = originItem.endDate.difference(originItem.startDate);
    dragedItem.startDate = appointmentDragEndDetails.droppingTime!;
    dragedItem.endDate = appointmentDragEndDetails.droppingTime!.add(diff);

    Provider.of<EventProvider>(context, listen: false).updateEvent(dragedItem);
    setState(() {});
  }

  void resizeStart(
    AppointmentResizeStartDetails appointmentResizeStartDetails,
  ) {
    print('Resize başladı');
  }

  void resizeUpdate(
    AppointmentResizeUpdateDetails appointmentResizeUpdateDetails,
  ) {
    // Resize sırasında yapılacak işlemler
  }

  void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
    final resizedEvent = appointmentResizeEndDetails.appointment as Schedule;

    if (appointmentResizeEndDetails.startTime != null) {
      resizedEvent.startDate = appointmentResizeEndDetails.startTime!;
    }

    if (appointmentResizeEndDetails.endTime != null) {
      resizedEvent.endDate = appointmentResizeEndDetails.endTime!;
    }

    Provider.of<EventProvider>(
      context,
      listen: false,
    ).updateEvent(resizedEvent);

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Etkinlik güncellendi'),
        duration: Duration(seconds: 1),
      ),
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
}
