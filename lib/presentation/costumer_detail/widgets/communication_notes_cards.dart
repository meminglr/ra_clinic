import 'package:flutter/material.dart';

import '../../../model/costumer_model.dart';

class CostumerNotesCard extends StatelessWidget {
  const CostumerNotesCard({
    super.key,
    required this.costumer,
    required this.noteIsNotEmpty,
  });

  final CostumerModel costumer;
  final bool noteIsNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(" ${costumer.startDateString} "),
            if (noteIsNotEmpty)
              Text("Not: ${costumer.notes} ", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
