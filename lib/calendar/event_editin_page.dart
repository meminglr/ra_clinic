// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';

import 'package:ra_clinic/providers/event_provider.dart';

class EventEditinPage extends StatefulWidget {
  final Schedule? event;
  final DateTime selectedDate;

  const EventEditinPage({Key? key, this.event, required this.selectedDate})
    : super(key: key);

  @override
  State<EventEditinPage> createState() => _EventEditinPageState();
}

class _EventEditinPageState extends State<EventEditinPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isAllDay = false;

  late DateTime fromDate;
  late DateTime toDate;

  Color selectedColor = Colors.blue;
  bool isColorsExpand = false;

  @override
  void initState() {
    super.initState();
    if (widget.event == null) {
      fromDate = widget.selectedDate;
      toDate = fromDate.add(Duration(hours: 2));
    }
    if (widget.event != null) {
      final event = widget.event!;
      titleController.text = event.name;
      descriptionController.text = event.description!;
      fromDate = event.startDate;
      toDate = event.endDate;
      selectedColor = event.color;
      isAllDay = event.isAllDay;
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        actions: buildEditingActions(),
        actionsPadding: EdgeInsets.only(right: 10),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTitle(),
              buildDateTimePicker(),

              //buildAllDayCheck(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 5,

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(flex: 2, child: buildPullDownColorPicker()),
                    Expanded(flex: 3, child: buildAllDay2()),
                  ],
                ),
              ),
              buildDescription(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions() => [
    if (widget.event != null)
      FilledButton(
        onPressed: () {
          deleteEvent();
        },
        style: FilledButton.styleFrom(backgroundColor: Colors.red),
        child: Icon(Icons.delete_outline),
      ),
    SizedBox(width: 3),
    widget.event == null
        ? FilledButton.icon(
            onPressed: () {
              saveForm();
            },
            label: Text("Kaydet"),
            icon: Icon(Icons.check),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          )
        : FilledButton.icon(
            onPressed: () {
              updateForm();
            },
            label: Text("Güncelle"),
            icon: Icon(Icons.check),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          ),
  ];

  Widget buildTitle() => TextFormField(
    controller: titleController,
    validator: (title) => title!.isEmpty ? "Başlık Giriniz" : null,
    onFieldSubmitted: (_) {},

    style: TextStyle(fontSize: 50),
    decoration: InputDecoration(hintText: "Başlık", border: InputBorder.none),
  );

  Widget buildDateTimePicker() => Card(
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(children: [buildFrom(), buildTo()]),
    ),
  );

  Widget buildFrom() => Row(
    spacing: 10,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Icon(Icons.alarm_on_outlined, size: 30, color: Colors.green),
      Expanded(flex: 2, child: buildFromDate()),
      Expanded(child: buildFromTime()),
    ],
  );

  Widget buildFromDate() => CupertinoCalendarPickerButton(
    barrierColor: Colors.transparent,
    containerDecoration: PickerContainerDecoration(
      backgroundType: PickerBackgroundType.plainColor,
    ),
    minimumDateTime: fromDate.add(Duration(days: -365)),
    maximumDateTime: fromDate.add(Duration(days: 365)),
    initialDateTime: fromDate,
    onDateSelected: (value) {
      fromDate = value;
      if (fromDate.isAfter(toDate)) {
        toDate = fromDate;
      }
      setState(() {});
    },
    actions: [
      CancelCupertinoCalendarAction(label: 'Vazgeç', onPressed: () {}),
      ConfirmCupertinoCalendarAction(
        label: 'Tamam',
        isDefaultAction: true,
        onPressed: (dateTime) {
          fromDate = dateTime;
          if (fromDate.isAfter(toDate)) {
            toDate = fromDate;
          }
          setState(() {});
        },
      ),
    ],
  );
  Widget buildFromTime() => CupertinoTimePickerButton(
    barrierColor: Colors.transparent,
    initialTime: TimeOfDay.fromDateTime(fromDate),
    containerDecoration: PickerContainerDecoration(
      backgroundType: PickerBackgroundType.plainColor,
    ),
  );

  Widget buildTo() => AnimatedSize(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
    child: isAllDay
        ? SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.alarm_off_outlined,
                  size: 30,
                  color: Colors.redAccent,
                ),
                Expanded(flex: 2, child: buildToDate()),
                Expanded(child: buildToTime()),
              ],
            ),
          ),
  );

  Widget buildToDate() => CupertinoCalendarPickerButton(
    barrierColor: Colors.transparent,
    containerDecoration: PickerContainerDecoration(
      backgroundType: PickerBackgroundType.plainColor,
    ),
    minimumDateTime: toDate.add(Duration(days: -365)),
    maximumDateTime: toDate.add(Duration(days: 365)),
    initialDateTime: toDate,
    onDateSelected: (value) {
      toDate = value;
      setState(() {});
    },
    actions: [
      CancelCupertinoCalendarAction(label: 'Vazgeç', onPressed: () {}),
      ConfirmCupertinoCalendarAction(
        label: 'Tamam',
        isDefaultAction: true,
        onPressed: (dateTime) {
          toDate = dateTime;
          setState(() {});
        },
      ),
    ],
  );
  Widget buildToTime() => CupertinoTimePickerButton(
    barrierColor: Colors.transparent,
    initialTime: TimeOfDay.fromDateTime(toDate),
    containerDecoration: PickerContainerDecoration(
      backgroundType: PickerBackgroundType.plainColor,
    ),
  );

  Widget buildColorPicker() {
    return // Renk Seçimi
    AnimatedSize(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        child: !isColorsExpand
            ? InkWell(
                onTap: () => setState(() {
                  isColorsExpand = !isColorsExpand;
                }),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.palette,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          'Renk Seçimi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        isColorsExpand = !isColorsExpand;
                      }),
                      child: Row(
                        children: [
                          Icon(
                            Icons.palette,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Renk Seçimi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            Colors.blue,
                            Colors.red,
                            Colors.green,
                            Colors.orange,
                            Colors.purple,
                            Colors.pink,
                            Colors.teal,
                            Colors.amber,
                          ].map((color) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == color
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: selectedColor == color
                                    ? Icon(Icons.check, color: Colors.white)
                                    : null,
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildAllDay2() {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      ),
      onPressed: () {
        setState(() {
          isAllDay = !isAllDay;
          if (isAllDay) {
            toDate = DateTime(
              fromDate.year,
              fromDate.month,
              fromDate.day,
              23,
              59,
              59,
              999,
            );
          }
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 5,
        children: [
          Text("Tüm Gün"),
          Switch(
            padding: EdgeInsets.zero,
            value: isAllDay,
            onChanged: (value) {
              setState(() {
                isAllDay = value;
                if (isAllDay) {
                  toDate = DateTime(
                    fromDate.year,
                    fromDate.month,
                    fromDate.day,
                    23,
                    59,
                    59,
                    999,
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildAllDayCheck() => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: GestureDetector(
      onTap: () {
        setState(() {
          isAllDay = !isAllDay;
          if (isAllDay) {
            toDate = DateTime(
              fromDate.year,
              fromDate.month,
              fromDate.day,
              23,
              59,
              59,
              999,
            );
          }
        });
      },
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 5,
            children: [
              Text("Tüm Gün", style: TextStyle(fontSize: 16)),
              Switch(
                value: isAllDay,
                onChanged: (value) {
                  setState(() {
                    isAllDay = value;
                    if (isAllDay) {
                      toDate = DateTime(
                        fromDate.year,
                        fromDate.month,
                        fromDate.day,
                        23,
                        59,
                        59,
                        999,
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget buildDescription() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Card(
      elevation: 0,
      child: TextFormField(
        controller: descriptionController,
        onFieldSubmitted: (_) {},
        maxLines: 8,
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          hintText: "Açıklama",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    ),
  );

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final event = Schedule(
        id: 0,
        name: titleController.text,
        color: selectedColor,
        startDate: fromDate,
        endDate: toDate,
        isAllDay: isAllDay,
        description: descriptionController.text,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addEvent(event);
      Navigator.pop(context);
    }
  }

  Future updateForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final event = Schedule(
        id: 0,
        name: titleController.text,
        color: selectedColor,
        startDate: fromDate,
        endDate: toDate,
        isAllDay: isAllDay,
        description: descriptionController.text,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.updateEvent(event);
      Navigator.pop(context);
    }
  }

  Future deleteEvent() async {
    final event = widget.event;

    final provider = Provider.of<EventProvider>(context, listen: false);
    provider.deleteEvent(event!.id);
    Navigator.pop(context);
  }

  Widget buildPullDownColorPicker() {
    return PullDownButton(
      routeTheme: PullDownMenuRouteTheme(backgroundColor: Colors.white),

      itemBuilder: (_) => [
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.blue;
            });
          },
          selected: selectedColor == Colors.blue,
          title: 'Mavi',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.blue,
        ),
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.red;
            });
          },
          selected: selectedColor == Colors.red,
          title: 'Kırmızı',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.red,
        ),
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.orange;
            });
          },
          selected: selectedColor == Colors.orange,

          title: 'Turuncu',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.orange,
        ),
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.green;
            });
          },
          selected: selectedColor == Colors.green,

          title: 'Yeşil',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.green,
        ),
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.purple;
            });
          },
          selected: selectedColor == Colors.purple,
          title: 'Mor',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.purple,
        ),
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.pink;
            });
          },
          selected: selectedColor == Colors.pink,
          title: 'Pembe',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.pink,
        ),
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.teal;
            });
          },
          selected: selectedColor == Colors.teal,
          title: 'Teal',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.teal,
        ),
        PullDownMenuItem.selectable(
          onTap: () {
            setState(() {
              selectedColor = Colors.amber;
            });
          },
          selected: selectedColor == Colors.amber,
          title: 'Amber',
          icon: CupertinoIcons.circle_fill,
          iconColor: Colors.amber,
        ),
      ],
      buttonBuilder: (context, showMenu) => SizedBox(
        height: 48,
        child: FilledButton.tonalIcon(
          onPressed: showMenu,
          label: Text("Renk Seçimi"),
          icon: const Icon(Icons.color_lens_outlined),
        ),
      ),
    );
  }
}
