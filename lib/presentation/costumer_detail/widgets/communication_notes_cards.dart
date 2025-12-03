import 'package:flutter/material.dart';
import 'package:ra_clinic/func/utils.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          Card.filled(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(" ${Utils.toDate(costumer.startDate)} "),
            ),
          ),
          if (noteIsNotEmpty)
            Card.filled(
              color: Colors.orange.withAlpha(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Text(
                  "Not: ${costumer.notes} ",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
