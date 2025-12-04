import 'package:flutter/material.dart';
import 'package:ra_clinic/model/costumer_model.dart';

class CostumerDetailHeader extends StatelessWidget {
  const CostumerDetailHeader({super.key, required this.costumer});
  final CustomerModel costumer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.account_circle, size: 150, color: Colors.grey),
        Text(
          " ${costumer.name} ",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
