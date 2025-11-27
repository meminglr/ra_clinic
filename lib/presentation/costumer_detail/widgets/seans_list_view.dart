import 'package:flutter/material.dart';
import 'package:ra_clinic/model/seans_model.dart';

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
    );
  }
}
