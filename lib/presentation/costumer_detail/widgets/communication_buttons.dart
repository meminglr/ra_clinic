// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:contact_add/contact.dart';
import 'package:contact_add/contact_add.dart';
import 'package:flutter/material.dart';
import 'package:ra_clinic/model/costumer_model.dart';

import '../../../func/communication_helper.dart';

class CommunicationButtons extends StatefulWidget {
  final bool phoneIsNotEmpty;
  final ScaffoldMessengerState messenger;
  final CostumerModel costumer;
  final bool isMessageExpanded;
  final bool isCallExpanded;

  const CommunicationButtons({
    super.key,
    required this.costumer,
    required this.isMessageExpanded,
    required this.isCallExpanded,
    required this.phoneIsNotEmpty,
    required this.messenger,
  });

  @override
  State<CommunicationButtons> createState() => _CommunicationButtonsState();
}

class _CommunicationButtonsState extends State<CommunicationButtons> {
  late bool _phoneIsNotEmpty;
  late bool _isMessageExpanded;
  late bool _isCallExpanded;

  @override
  void initState() {
    super.initState();
    _phoneIsNotEmpty = widget.phoneIsNotEmpty;
    _isMessageExpanded = widget.isMessageExpanded;
    _isCallExpanded = widget.isCallExpanded;
  }

  @override
  void didUpdateWidget(covariant CommunicationButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent tarafından gelen değerler değiştiyse senkronize et
    if (oldWidget.phoneIsNotEmpty != widget.phoneIsNotEmpty) {
      _phoneIsNotEmpty = widget.phoneIsNotEmpty;
    }
    if (oldWidget.isMessageExpanded != widget.isMessageExpanded) {
      _isMessageExpanded = widget.isMessageExpanded;
    }
    if (oldWidget.isCallExpanded != widget.isCallExpanded) {
      _isCallExpanded = widget.isCallExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.tonalIcon(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  _isCallExpanded
                      ? Colors.green.shade200
                      : (_phoneIsNotEmpty ? null : Colors.grey.shade300),
                ),
              ),
              onPressed: () {
                if (_phoneIsNotEmpty) {
                  setState(() {
                    _isCallExpanded = !_isCallExpanded;
                    _isMessageExpanded = false;
                  });
                } else {
                  widget.messenger.hideCurrentSnackBar();
                  widget.messenger.showSnackBar(
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
                  _isMessageExpanded
                      ? Colors.green.shade200
                      : (_phoneIsNotEmpty ? null : Colors.grey.shade300),
                ),
              ),
              onPressed: () {
                if (_phoneIsNotEmpty) {
                  setState(() {
                    _isMessageExpanded = !_isMessageExpanded;
                    _isCallExpanded = false;
                  });
                } else {
                  widget.messenger.hideCurrentSnackBar();
                  widget.messenger.showSnackBar(
                    SnackBar(content: Text("Numara yok")),
                  );
                }
              },
              icon: Icon(Icons.message_outlined),
              label: Text("Mesaj"),
            ),

            FilledButton.tonalIcon(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  _phoneIsNotEmpty ? null : Colors.grey.shade300,
                ),
              ),
              onPressed: () {
                if (widget.phoneIsNotEmpty) {
                  try {
                    final Contact contact = Contact(
                      firstname: widget.costumer.name,
                      phone: widget.costumer.phone,
                    );
                    ContactAdd.addContact(contact);
                  } on Exception catch (e) {
                    widget.messenger.hideCurrentSnackBar();
                    widget.messenger.showSnackBar(
                      SnackBar(
                        content: Text("Kişi eklenirken hata oluştu: $e"),
                      ),
                    );
                  }
                } else {
                  widget.messenger.hideCurrentSnackBar();
                  widget.messenger.showSnackBar(
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
          child: _isMessageExpanded
              ? Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        CommunicationHelper.openSmsApp(
                          context,
                          widget.costumer.phone!,
                        );
                      },
                      icon: Icon(Icons.message_outlined),
                      label: Text("Kısa Mesaj"),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(Colors.orange),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        CommunicationHelper.openWhatsApp(
                          context,
                          widget.costumer.phone!,
                        );
                      },
                      icon: Icon(Icons.message_outlined),
                      label: Text("Whastapp"),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(Colors.green),
                      ),
                    ),
                  ],
                )
              : _isCallExpanded
              ? Row(
                  spacing: 5,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        CommunicationHelper.makePhoneCall(
                          context,
                          widget.costumer.phone!,
                        );
                      },
                      icon: Icon(Icons.phone_outlined),
                      label: Text("Normal Arama"),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(Colors.orange),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        CommunicationHelper.makeWhatsAppCall(
                          context,
                          widget.costumer.phone!,
                        );
                      },
                      icon: Icon(Icons.phone_outlined),
                      label: Text("WhatsApp Arama"),
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        backgroundColor: WidgetStatePropertyAll(Colors.green),
                      ),
                    ),
                  ],
                )
              : SizedBox(),
        ),
      ],
    );
  }
}
