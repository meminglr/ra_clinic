import 'package:flutter/material.dart';
import 'package:ra_clinic/model/costumer_model.dart';
class CostumerDetailHeader extends StatelessWidget {
  const CostumerDetailHeader({super.key, required this.costumer});
  final CostumerModel costumer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage("assets/avatar.png"),
        ),
        Text(
          " ${costumer.name} ",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
