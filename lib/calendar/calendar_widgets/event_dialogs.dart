import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/calendar/event_editin_page.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';
import 'package:ra_clinic/providers/event_provider.dart';

class EventDialogsWidgets {
  static void showAddEventDialog(BuildContext context, DateTime selectedDate) {
    final TextEditingController titleController = TextEditingController();
    TimeOfDay startTime = TimeOfDay.now();
    TimeOfDay endTime = TimeOfDay(
      hour: TimeOfDay.now().hour + 1,
      minute: TimeOfDay.now().minute,
    );
    DateTime eventDate = selectedDate;
    bool isAllDay = false;
    Color selectedColor = Colors.blue;
    bool isColorsExpand = false;

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                spacing: 8,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text('Yeni Etkinlik Ekle'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Başlık
                    TextField(
                      controller: titleController,
                      style: TextStyle(fontSize: 30),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 50),
                        hintText: "Başlık",
                        border: InputBorder.none,
                      ),
                    ),
                    // Tüm Gün Seçeneği
                    Card(
                      child: SwitchListTile(
                        secondary: Icon(Icons.access_time_filled),
                        title: Text('Tüm Gün'),
                        subtitle: Text('Etkinlik tüm gün sürecek'),
                        value: isAllDay,
                        onChanged: (value) {
                          setState(() {
                            isAllDay = value;
                          });
                        },
                      ),
                    ),
                    // Başlangıç Saati - sadece tüm gün değilse göster
                    if (!isAllDay) ...[
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text('Tarih'),
                          subtitle: Text(
                            '${eventDate.day}/${eventDate.month}/${eventDate.year}',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: eventDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                eventDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                      // Tarih Seçimi
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.access_time, color: Colors.green),
                          title: Text('Başlangıç Saati'),
                          subtitle: Text('${startTime.format(context)}'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (picked != null) {
                              setState(() {
                                startTime = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],

                    // Bitiş Saati - sadece tüm gün değilse göster
                    if (!isAllDay) ...[
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.access_time, color: Colors.red),
                          title: Text('Bitiş Saati'),
                          subtitle: Text('${endTime.format(context)}'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (picked != null) {
                              setState(() {
                                endTime = picked;
                              });
                            }
                          },
                        ),
                      ),
                      // Renk Seçimi
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
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.palette,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          Text(
                                            'Renk Seçimi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () => setState(() {
                                          isColorsExpand = !isColorsExpand;
                                        }),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.palette,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Renk Seçimi',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                                      color:
                                                          selectedColor == color
                                                          ? Colors.black
                                                          : Colors.transparent,
                                                      width: 3,
                                                    ),
                                                  ),
                                                  child: selectedColor == color
                                                      ? Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('İptal'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lütfen etkinlik başlığı girin'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Yeni etkinlik oluştur
                    final newEvent = Schedule(
                      id: DateTime.now().millisecondsSinceEpoch,
                      name: titleController.text,
                      color: Colors.blue,
                      startDate: DateTime(
                        eventDate.year,
                        eventDate.month,
                        eventDate.day,
                        startTime.hour,
                        startTime.minute,
                      ),
                      endDate: DateTime(
                        eventDate.year,
                        eventDate.month,
                        eventDate.day,
                        endTime.hour,
                        endTime.minute,
                      ),
                      isAllDay: false,
                    );

                    // Provider'a ekle
                    Provider.of<EventProvider>(
                      context,
                      listen: false,
                    ).addEvent(newEvent);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Etkinlik başarıyla eklendi'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: Icon(Icons.save),
                  label: Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Etkinlik Detaylarını Gösterme Dialog'u
  static void showEventDetailsDialog(BuildContext context, Schedule event) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.event, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarih Bilgisi
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text('Tarih'),
                    subtitle: Text(
                      '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),

                // Saat Bilgileri
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Başlangıç',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Bitiş',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${event.endDate.hour.toString().padLeft(2, '0')}:${event.endDate.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showDeleteConfirmDialog(context, event);
              },
              icon: Icon(Icons.delete, color: Colors.red),
              label: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (builder) => EventEditinPage(
                      selectedDate: event.startDate,
                      event: event,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.edit),
              label: Text('Düzenle'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  // Silme Onay Dialog'u
  static void showDeleteConfirmDialog(BuildContext context, Schedule event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Etkinliği Sil'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bu etkinliği silmek istediğinizden emin misiniz?'),
              SizedBox(height: 12),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<EventProvider>(
                  context,
                  listen: false,
                ).deleteEvent(event.id.toString());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Etkinlik silindi'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              icon: Icon(Icons.delete),
              label: Text('Sil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
