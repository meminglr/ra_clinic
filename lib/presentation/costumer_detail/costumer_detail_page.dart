import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_buttons.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_notes_cards.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_detail_header.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_phone_display.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/no_seans_warning_view.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/seans_list_view.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';

import '../../screens/edit_costumer_page.dart';

class CostumerDetail extends StatefulWidget {
  final int index;
  const CostumerDetail({required this.index, super.key});

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

  void navigateToEditCostumerPage(int index, CostumerModel costumer) async {
    final CostumerModel? modifiedCostumer = await Navigator.push<CostumerModel>(
      context,
      CupertinoPageRoute(
        builder: (builder) {
          return EditCostumerPage(
            costumer: costumer,
            seansList: costumer.seansList ?? [],
          );
        },
      ),
    );

    if (modifiedCostumer != null) {
      context.read<CostumerProvider>().editCostumer(index, modifiedCostumer);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Değişiklikler kaydedildi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    CostumerModel currentCostumer = context
        .watch<CostumerProvider>()
        .costumersList[widget.index];
    var phoneIsNotEmpty = currentCostumer.phone!.isNotEmpty;
    var noteIsNotEmpty = currentCostumer.notes!.isNotEmpty;
    final messenger = ScaffoldMessenger.of(context);

    return Scaffold(
      appBar: AppBar(actions: [
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToEditCostumerPage(widget.index, currentCostumer);
        },
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
                  CostumerDetailHeader(costumer: currentCostumer),
                  if (phoneIsNotEmpty)
                    CostumerPhoneDisplay(
                      costumer: currentCostumer,
                      messenger: messenger,
                    ),
                  CommunicationButtons(
                    costumer: currentCostumer,
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
                costumer: currentCostumer,
                noteIsNotEmpty: noteIsNotEmpty,
              ),
            ),
            if (currentCostumer.seansList!.isEmpty) NoSeansWarning(),

            if (currentCostumer.seansList!.isNotEmpty)
              SeansListView(seansList: currentCostumer.seansList!),
          ],
        ),
      ),
    );
  }
}
