import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ra_clinic/model/costumer_model.dart';

class CostumerPhoneDisplay extends StatelessWidget {
  final ScaffoldMessengerState messenger;
  final CustomerModel costumer;
  const CostumerPhoneDisplay({
    required this.costumer,
    required this.messenger,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: costumer.phone.toString()));
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(SnackBar(content: Text("No kopyalandı")));
      },
      child: Text("No: ${costumer.phone}", style: TextStyle(fontSize: 18)),
    );
  }
}
