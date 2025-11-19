// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/event_provider.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';

import '../utils.dart';
import 'model/event.dart';

class EventEditinPage extends StatefulWidget {
  final Event? event;
  const EventEditinPage({super.key, this.event});

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
      fromDate = DateTime.now();
      toDate = DateTime.now().add(Duration(hours: 2));
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
      appBar: AppBar(leading: CloseButton(), actions: buildEditingActions()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 30,
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
    ElevatedButton.icon(
      onPressed: () {
        saveForm();
      },
      label: Text("Kaydet"),

      icon: Icon(Icons.check),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
    ),
  ];

  Widget buildTitle() => TextFormField(
    controller: titleController,
    validator: (title) => title!.isEmpty ? "Başlık Giriniz" : null,
    onFieldSubmitted: (_) {},
    style: TextStyle(fontSize: 24),
    decoration: InputDecoration(
      border: UnderlineInputBorder(),
      labelText: "Başlık",
    ),
  );

  Widget buildDateTimePicker() =>
      Column(spacing: 5, children: [buildFrom(), buildTo()]);

  Widget buildFrom() => Column(
    spacing: 5,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Başlangıç"),
      Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: buildFromDate()),
          Expanded(child: buildFromTime()),
        ],
      ),
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

  Widget buildTo() => Column(
    spacing: 5,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Bitiş"),
      Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: buildToDate()),
          Expanded(child: buildToTime()),
        ],
      ),
    ],
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

  Widget buildAllDayCheck() => CheckboxListTile(
    title: Text("Tüm Gün"),
    controlAffinity: ListTileControlAffinity.leading,

    value: isAllDay,
    onChanged: (value) {
      isAllDay = value!;
      setState(() {});
    },
  );

  Widget buildDescription() => TextFormField(
    controller: descriptionController,
    maxLines: null,
    style: TextStyle(fontSize: 24),
    decoration: InputDecoration(
      border: UnderlineInputBorder(),
      labelText: "Açıklama",
    ),
  );

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final event = Event(
        title: titleController.text,
        description: descriptionController.text,
        from: fromDate,
        to: toDate,
      );

      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addEvent(event);
      Navigator.pop(context);
    }
  }
}
