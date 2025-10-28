import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/model/seans_model.dart';

class CostumerDetail extends StatefulWidget {
  CostumerModel costumer;
  CostumerDetail({required this.costumer, super.key});

  @override
  State<CostumerDetail> createState() => _CostumerDetailState();
}

class _CostumerDetailState extends State<CostumerDetail> {
  List<SeansModel> _seansList = [];
  bool _messageExpanded = false;
  DateTime now = DateTime.now();

  _makePhoneCall(String phoneNumber) async {
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }

  @override
  void initState() {
    super.initState();
    _seansList = widget.costumer.seansList ?? [];
  }

  @override
  Widget build(BuildContext context) {
    var phoneIsNotEmpty = widget.costumer.phone!.isNotEmpty;
    var noteIsNotEmpty = widget.costumer.notes!.isNotEmpty;
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Düzenle"),
        icon: const Icon(Icons.edit_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage("assets/avatar.png"),
                  ),
                  Text(
                    " ${widget.costumer.name} ",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  if (phoneIsNotEmpty)
                    GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.costumer.phone.toString()),
                        );
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          SnackBar(content: Text("No kopyalandı")),
                        );
                      },
                      child: Text(
                        "No: ${widget.costumer.phone}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonalIcon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            phoneIsNotEmpty ? null : Colors.grey.shade300,
                          ),
                        ),
                        onPressed: () {
                          if (phoneIsNotEmpty) {
                            _makePhoneCall(widget.costumer.phone!);
                          } else {
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(content: Text("Numara yok")),
                            );
                          }
                        },
                        icon: Icon(Icons.phone_outlined),
                        label: Text("Ara"),
                      ),
                      FilledButton.tonalIcon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            phoneIsNotEmpty ? null : Colors.grey.shade300,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if (phoneIsNotEmpty) {
                              _messageExpanded = !_messageExpanded;
                            } else {
                              messenger.hideCurrentSnackBar();
                              messenger.showSnackBar(
                                SnackBar(content: Text("Numara yok")),
                              );
                            }
                          });
                        },
                        icon: Icon(Icons.message_outlined),
                        label: Text("Mesaj"),
                      ),

                      FilledButton.tonalIcon(
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            phoneIsNotEmpty ? null : Colors.grey.shade300,
                          ),
                        ),
                        onPressed: () {
                          if (phoneIsNotEmpty) {
                          } else {
                            messenger.hideCurrentSnackBar();
                            messenger.showSnackBar(
                              SnackBar(content: Text("Numara yok")),
                            );
                          }
                        },
                        icon: Icon(Icons.person_add_alt),
                        label: Text("Ekle"),
                      ),
                    ],
                  ),

                  AnimatedSize(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _messageExpanded
                        ? Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: () {},
                                icon: Icon(Icons.message_outlined),
                                label: Text("Kısa Mesaj"),
                                style: ButtonStyle(
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.orange,
                                  ),
                                ),
                              ),

                              FilledButton.tonalIcon(
                                onPressed: () {},
                                icon: Icon(Icons.message_outlined),
                                label: Text("Whastapp"),
                                style: ButtonStyle(
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.white,
                                  ),
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Card.filled(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(" ${widget.costumer.startDateString} "),
                      if (noteIsNotEmpty)
                        Text(
                          "Not: ${widget.costumer.notes} ",
                          style: TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_seansList.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                      Text(
                        "Seans yok",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_seansList.isNotEmpty)
              SliverList.builder(
                itemCount: _seansList.length,
                itemBuilder: (context, index) {
                  SeansModel seans = _seansList[index];

                  return Column(
                    children: [
                      seans.isDeleted
                          ? FilledButton.tonal(
                              onPressed: () {},
                              child: Text("${seans.seansCount}. seans yok"),
                            )
                          : Card.filled(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.green.shade100,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 16,
                                  bottom: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${seans.seansCount}. Seans·",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          seans.startDateString,
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),

                                    _seansList[index].seansNote != null
                                        ? Text("${_seansList[index].seansNote}")
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
