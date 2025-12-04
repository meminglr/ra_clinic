// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:contact_add/contact.dart';
import 'package:contact_add/contact_add.dart';
import 'package:flutter/material.dart';
import 'package:ra_clinic/model/costumer_model.dart';

import '../../../func/communication_helper.dart';

class CommunicationButtons extends StatefulWidget {
  final bool phoneIsNotEmpty;
  final ScaffoldMessengerState messenger;
  final CustomerModel costumer;
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

  @override
  void initState() {
    super.initState();
    _phoneIsNotEmpty = widget.phoneIsNotEmpty;
    _isMessageExpanded = widget.isMessageExpanded;
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
              onPressed: () {
                if (_phoneIsNotEmpty) {
                  CommunicationHelper.makePhoneCall(
                    context,
                    widget.costumer.phone!,
                  );
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
                  _isMessageExpanded ? null : null,
                ),
              ),
              onPressed: () {
                if (_phoneIsNotEmpty) {
                  setState(() {
                    _isMessageExpanded = !_isMessageExpanded;
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
                  _phoneIsNotEmpty ? null : null,
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
                        foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
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
                        foregroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
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
