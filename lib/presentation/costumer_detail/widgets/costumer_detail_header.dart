import 'package:flutter/material.dart';
import 'package:ra_clinic/presentation/costumer_detail/costumer_detail_page.dart';

class CostumerDetailHeader extends StatelessWidget {
  const CostumerDetailHeader({super.key, required this.widget});
  final CostumerDetail widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage("assets/avatar.png"),
        ),
        Text(
          " ${widget.costumer.name} ",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}