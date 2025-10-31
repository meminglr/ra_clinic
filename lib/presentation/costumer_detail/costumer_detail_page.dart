import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_buttons.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_notes_cards.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_detail_header.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_phone_display.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/no_seans_warning_view.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/seans_list_view.dart';

import '../../screens/edit_costumer_page.dart';

class CostumerDetail extends StatefulWidget {
  final CostumerModel costumer;
  const CostumerDetail({required this.costumer, super.key});

  @override
  State<CostumerDetail> createState() => _CostumerDetailState();
}

class _CostumerDetailState extends State<CostumerDetail> {
  bool isMessageExpanded = false;
  bool isCallExpanded = false;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var phoneIsNotEmpty = widget.costumer.phone!.isNotEmpty;
    var noteIsNotEmpty = widget.costumer.notes!.isNotEmpty;
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(actions: [
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text("Düzenle"),
        icon: const Icon(Icons.edit_outlined),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  CostumerDetailHeader(costumer: widget.costumer),
                  if (phoneIsNotEmpty)
                    CostumerPhoneDisplay(
                      costumer: widget.costumer,
                      messenger: messenger,
                    ),
                  CommunicationButtons(
                    costumer: widget.costumer,
                    isMessageExpanded: isMessageExpanded,
                    isCallExpanded: isCallExpanded,
                    phoneIsNotEmpty: phoneIsNotEmpty,
                    messenger: messenger,
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: CostumerNotesCard(
                costumer: widget.costumer,
                noteIsNotEmpty: noteIsNotEmpty,
              ),
            ),
            if (widget.costumer.seansList!.isEmpty) NoSeansWarning(),

            if (widget.costumer.seansList!.isNotEmpty)
              SeansListView(seansList: widget.costumer.seansList!),
          ],
        ),
      ),
    );
  }
}
