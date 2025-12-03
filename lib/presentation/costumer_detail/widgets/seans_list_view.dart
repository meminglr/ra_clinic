import 'package:flutter/material.dart';
import 'package:ra_clinic/model/seans_model.dart';
import 'package:ra_clinic/func/utils.dart';

class SeansListView extends StatelessWidget {
  const SeansListView({super.key, required List<SeansModel> seansList})
    : _seansList = seansList;

  final List<SeansModel> _seansList;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: _seansList.length,
      itemBuilder: (context, index) {
        SeansModel seans = _seansList[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              seans.isDeleted
                  ? FilledButton.tonal(
                      onPressed: () {},
                      child: Text("${seans.seansCount}. seans yok"),
                    )
                  : Card.filled(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

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
                                        Utils.toDate(seans.startDate),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Text(seans.seansNote ?? ""),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
