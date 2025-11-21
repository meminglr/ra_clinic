// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';

import 'package:ra_clinic/providers/event_provider.dart';

import 'model/event.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.event == null) {
      fromDate = widget.selectedDate;
      toDate = fromDate.add(Duration(hours: 2));
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
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          label: Text("Vazgeç"),
          icon: Icon(Icons.close),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
        ),
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
              buildAllDayCheck(),
              buildDescription(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions() => [
    FilledButton.icon(
      onPressed: () {
        saveForm();
      },
      label: Text("Kaydet"),
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

  Widget buildAllDayCheck() => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: GestureDetector(
      onTap: () {
        isAllDay = !isAllDay;
        if (isAllDay) {
          toDate = fromDate;
        }
        setState(() {});
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
                  isAllDay = value;
                  setState(() {});
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
        id: DateTime.now().millisecondsSinceEpoch,
        name: titleController.text,
        color: Colors.green,
        startDate: fromDate,
        endDate: toDate,
        isAllDay: isAllDay,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addEvent(event);
      Navigator.pop(context);
    }
  }
}
