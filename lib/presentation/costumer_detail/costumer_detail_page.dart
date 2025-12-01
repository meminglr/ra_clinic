import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_buttons.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_notes_cards.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_detail_header.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_phone_display.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/no_seans_warning_view.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/seans_list_view.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/tab_bar.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';

import '../../constants/app_constants.dart';
import '../../func/communication_helper.dart';
import '../../screens/costumer_updating.dart';

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
          return CostumerUpdating(costumer: costumer);
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
      // appBar: AppBar(
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //       child: Row(
      //         spacing: 12,
      //         children: [
      //           GestureDetector(
      //             onTap: () {
      //               context.read<CostumerProvider>().deleteCostumer(
      //                 widget.index,
      //               );
      //               Navigator.pop(context);
      //               messenger.showSnackBar(
      //                 const SnackBar(content: Text("Müşteri silindi")),
      //               );
      //             },
      //             child: Icon(Icons.delete_outline, size: 30),
      //           ),

      //           PullDownButton(
      //             routeTheme: PullDownMenuRouteTheme(
      //               backgroundColor: AppConstants.dropDownButtonsColor(context),
      //             ),
      //             itemBuilder: (context) => [
      //               PullDownMenuItem(
      //                 onTap: () {
      //                   navigateToEditCostumerPage(
      //                     widget.index,
      //                     currentCostumer,
      //                   );
      //                 },
      //                 title: 'Düzenle',
      //                 icon: Icons.edit_outlined,
      //               ),
      //               PullDownMenuItem(
      //                 onTap: () {
      //                   CommunicationHelper.shareCostumer(currentCostumer);
      //                 },
      //                 title: 'Paylaş',
      //                 icon: Icons.share_outlined,
      //               ),
      //             ],
      //             position: PullDownMenuPosition.automatic,
      //             buttonBuilder: (context, showMenu) => GestureDetector(
      //               behavior: HitTestBehavior.translucent,

      //               onTap: () {
      //                 showMenu();
      //               },
      //               child: Icon(Icons.more_vert, size: 30),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToEditCostumerPage(widget.index, currentCostumer);
        },
        label: const Text("Düzenle"),
        icon: const Icon(Icons.edit_outlined),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            pinned: true,
            snap: false,
            floating: true,
            expandedHeight: 200,
            titleSpacing: 30,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding: EdgeInsets.only(bottom: 10),
              background: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  color: Theme.of(context).colorScheme.secondaryFixedDim,
                ),
              ),
              title: Text(
                currentCostumer.name,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  spacing: 12,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<CostumerProvider>().deleteCostumer(
                          widget.index,
                        );
                        Navigator.pop(context);
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Müşteri silindi")),
                        );
                      },
                      child: Icon(Icons.delete_outline, size: 30),
                    ),

                    PullDownButton(
                      routeTheme: PullDownMenuRouteTheme(
                        backgroundColor: AppConstants.dropDownButtonsColor(
                          context,
                        ),
                      ),
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          onTap: () {
                            navigateToEditCostumerPage(
                              widget.index,
                              currentCostumer,
                            );
                          },
                          title: 'Düzenle',
                          icon: Icons.edit_outlined,
                        ),
                        PullDownMenuItem(
                          onTap: () {
                            CommunicationHelper.shareCostumer(currentCostumer);
                          },
                          title: 'Paylaş',
                          icon: Icons.share_outlined,
                        ),
                      ],
                      position: PullDownMenuPosition.automatic,
                      buttonBuilder: (context, showMenu) => GestureDetector(
                        behavior: HitTestBehavior.translucent,

                        onTap: () {
                          showMenu();
                        },
                        child: Icon(Icons.more_vert, size: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Column(
                children: [
                  // CostumerDetailHeader(costumer: currentCostumer),
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CostumerNotesCard(
                costumer: currentCostumer,
                noteIsNotEmpty: noteIsNotEmpty,
              ),
            ),
          ),
          if (currentCostumer.seansList.isEmpty) NoSeansWarning(),

          if (currentCostumer.seansList.isNotEmpty)
            SeansListView(seansList: currentCostumer.seansList),
            
        ],
      ),
    );
  }
}
