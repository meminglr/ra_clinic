import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/calendar/calendar_widgets/event_dialogs.dart';
import 'package:ra_clinic/calendar/event_editin_page.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';
import 'package:ra_clinic/calendar/model/schedule_data_source.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/event_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../constants/app_constants.dart';
import '../services/sync_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController _calendarController = CalendarController();
  DateTime? selectedDate;
  SyncService? _syncService;
  StreamSubscription? _internetSubscription;

  @override
  void initState() {
    // TODO: implement initState
    _initSyncSystem();
    super.initState();
  }

  void _initSyncSystem() {
    // 1. Mevcut kullanıcının ID'sini al
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _syncService = SyncService(user.uid);

      // A. Uygulama açılır açılmaz bir kere PUSH yap (Bekleyenleri gönder)
      _syncService!.syncLocalToRemote();

      // B. Firebase'i dinlemeye başla (PULL)
      _syncService!.startListeningToRemoteChanges();

      // C. İnternet gidip gelirse otomatik PUSH tetikle
      _internetSubscription = Connectivity().onConnectivityChanged.listen((
        result,
      ) {
        if (result != ConnectivityResult.none) {
          print("🌐 İnternet geldi, sync tetikleniyor...");
          _syncService!.syncLocalToRemote();
        }
      });

      // D. Kullanıcı bir veri kaydettiğinde (Hive değiştiğinde) anında PUSH yap
      Hive.box<Schedule>("scheduleBox").listenable().addListener(() {
        // Buraya bir "Throttle" (yavaşlatma) koymak iyi olabilir ama şimdilik direkt çağıralım
        _syncService!.syncLocalToRemote();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _calendarController.dispose();
    _syncService?.stopListening();
    _internetSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);

    final events = context.watch<EventProvider>().events;
    Offset touchPosition = Offset.zero;
    return Scaffold(
      appBar: AppBar(title: Text("Takvim"), centerTitle: true, actions: []),
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
            SegmentedButton<CalendarView>(
              // 1. Controller'daki mevcut görünümü alıyoruz.
              // Not: .view null olabileceği için varsayılan olarak 'month' veriyoruz.
              selected: <CalendarView>{
                _calendarController.view ?? CalendarView.month,
              },

              // 2. Seçim değiştiğinde controller'ı güncelliyoruz.
              onSelectionChanged: (Set<CalendarView> newSelection) {
                setState(() {
                  // Seçilen yeni görünümü controller'a atıyoruz.
                  // Bu işlem takvimin de görünümünü değiştirecektir.
                  _calendarController.view = newSelection.first;
                });
              },

              // 3. Segment (Buton) Tanımları
              segments: const <ButtonSegment<CalendarView>>[
                ButtonSegment<CalendarView>(
                  value: CalendarView.month,
                  label: Text('Ay'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment<CalendarView>(
                  value: CalendarView.week,
                  label: Text('Hafta'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment<CalendarView>(
                  value: CalendarView.day,
                  label: Text('Gün'),
                  icon: Icon(Icons.calendar_view_day),
                ),
                ButtonSegment<CalendarView>(
                  value: CalendarView.schedule,
                  label: Text('Etkinlik'),
                  icon: Icon(
                    Icons.view_agenda_outlined,
                  ), // Ajanda/Liste görünümü için uygun ikon
                ),
              ],

              // İsteğe bağlı görsel ayarlar
              showSelectedIcon: false,
              style: ButtonStyle(
                // Yatay ve dikey boşlukları minimuma indirir (-4 en sıkı ayardır)
                visualDensity: const VisualDensity(horizontal: 0, vertical: 0),

                // İç padding'i sıfırlar veya çok azaltır
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),

            Expanded(
              child: Listener(
                onPointerDown: (PointerDownEvent event) {
                  touchPosition = event.position;
                },
                child: SfCalendar(
                  headerStyle: CalendarHeaderStyle(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),

                  controller: _calendarController,
                  view: CalendarView.month,
                  dataSource: ScheduleDataSource(events),
                  initialSelectedDate: DateTime.now(),
                  firstDayOfWeek: 1,
                  showCurrentTimeIndicator: true,
                  showDatePickerButton: true,
                  showNavigationArrow: true,
                  showTodayButton: true,

                  onSelectionChanged: (calendarSelectionDetails) {
                    if (calendarSelectionDetails.date != null) {
                      selectedDate = calendarSelectionDetails.date!;
                    }
                  },
                  monthViewSettings: const MonthViewSettings(
                    monthCellStyle: MonthCellStyle(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    showAgenda: true,
                    agendaViewHeight: 275,
                    appointmentDisplayCount: 3,
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                  ),
                  allowDragAndDrop: true,
                  onDragEnd: _onDragEnd,
                  allowAppointmentResize: true,
                  onAppointmentResizeStart: resizeStart,
                  onAppointmentResizeUpdate: resizeUpdate,
                  onAppointmentResizeEnd: resizeEnd,
                  // 2. ADIM: Uzun basıldığında yakalanan pozisyonu kullan
                  onLongPress: (CalendarLongPressDetails details) {
                    final calendarView = _calendarController.view;
                    if (details.targetElement == CalendarElement.appointment &&
                            calendarView == CalendarView.month ||
                        calendarView == CalendarView.schedule) {
                      final Schedule tappedEvent = details.appointments![0];
                      showPullDownMenu(
                        routeTheme: PullDownMenuRouteTheme(
                          backgroundColor: AppConstants.dropDownButtonsColor(
                            context,
                          ),
                        ),
                        context: context,
                        // Yakalanan _touchPosition değişkenini burada kullanıyoruz
                        position: Rect.fromCenter(
                          center: touchPosition,
                          width: 0,
                          height: 0,
                        ),
                        items: [
                          PullDownMenuItem(
                            onTap: () {
                              EventDialogsWidgets.showEditingPage(
                                tappedEvent,
                                context,
                              );
                            },
                            title: "Düzenle",
                            icon: Icons.edit,
                          ),
                          PullDownMenuItem(
                            onTap: () {
                              eventProvider.deleteEvent(tappedEvent.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Etkinlik silindi'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            title: "Sil",
                            isDestructive: true,
                            icon: Icons.delete,
                          ),
                        ],
                      );
                    }
                  },
                  onTap: (calendarTapDetails) {
                    // Etkinliğe tıklandıysa detayları göster
                    if (calendarTapDetails.targetElement ==
                        CalendarElement.appointment) {
                      final Schedule tappedEvent =
                          calendarTapDetails.appointments![0];
                      // EventDialogsWidgets.showEventDetailsDialog(
                      //   context,
                      //   tappedEvent,
                      // );
                      EventDialogsWidgets.showEditingPage(tappedEvent, context);
                    }
                    // Boş tarihe tıklandıysa yeni etkinlik ekle
                  },
                ),
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
  ) {}

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

  Widget buildCalendarViewOptions(
    CalendarController controller,
  ) => PullDownButton(
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
      PullDownMenuItem(
        onTap: () {
          Provider.of<EventProvider>(context, listen: false).clearLocalData();
        },
        title: "Tüm Etkinlikleri Sil",
      ),
    ],
    position: PullDownMenuPosition.automatic,
    buttonBuilder: (context, showMenu) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showMenu();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 20, bottom: 20, right: 5),
        child: Icon(Icons.more_vert),
      ),
    ),
  );
}
