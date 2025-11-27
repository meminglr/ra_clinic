import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/func/communication_helper.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';
import 'package:ra_clinic/screens/add_costumer_page.dart';
import 'package:ra_clinic/presentation/costumer_detail/costumer_detail_page.dart';
import 'package:ra_clinic/screens/edit_costumer_page.dart';

import 'costumer_updating.dart';

class Costumers extends StatefulWidget {
  const Costumers({super.key});

  @override
  State<Costumers> createState() => _CostumersState();
}

class _CostumersState extends State<Costumers> {
  void navigateToAddCostumerPage() async {
    final CostumerModel? newCostumer = await Navigator.push<CostumerModel>(
      context,
      CupertinoPageRoute(builder: (builder) => CostumerUpdating()),
    );

    if (newCostumer != null) {
      context.read<CostumerProvider>().addCostumer(newCostumer);
    }
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
    List<CostumerModel> costumersList = context
        .watch<CostumerProvider>()
        .costumersList;
    return Scaffold(
      appBar: AppBar(title: Text("Müşteriler"), actions: [Icon(Icons.search)]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAddCostumerPage();
        },
        label: const Text("Müşteri Ekle"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: costumersList.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_outlined, size: 100),
                  Text(
                    "Henüz eklenmiş bir müşteri yok.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: costumersList.length,
                  itemBuilder: (itemBuilder, index) {
                    CostumerModel item = costumersList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (builder) => CostumerDetail(index: index),
                          ),
                        );
                      },
                      child: Slidable(
                        key: Key(item.id),

                        endActionPane: ActionPane(
                          dismissible: DismissiblePane(
                            onDismissed: () {
                              context.read<CostumerProvider>().deleteCostumer(
                                index,
                              );
                            },
                          ),
                          motion: StretchMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                context.read<CostumerProvider>().deleteCostumer(
                                  index,
                                );
                              },
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.red.shade100,
                              icon: Icons.delete_outline,

                              label: 'Sil',

                              borderRadius: BorderRadius.circular(20),
                            ),
                          ],
                        ),
                        child: Card.filled(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(item.startDateString),
                                    Text(
                                      "Seans Sayısı: ${item.seansList.length}",
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    FilledButton(
                                      style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                          EdgeInsets.zero,
                                        ),
                                        minimumSize: WidgetStatePropertyAll(
                                          Size(40, 40),
                                        ),
                                        shape: WidgetStatePropertyAll(
                                          CircleBorder(),
                                        ),
                                      ),
                                      onPressed: () {
                                        CommunicationHelper.makePhoneCall(
                                          context,
                                          item.phone!,
                                        );
                                      },
                                      child: Icon(Icons.phone_outlined),
                                    ),
                                    FilledButton(
                                      style: ButtonStyle(
                                        padding: WidgetStatePropertyAll(
                                          EdgeInsets.zero,
                                        ),
                                        minimumSize: WidgetStatePropertyAll(
                                          Size(40, 40),
                                        ),
                                        shape: WidgetStatePropertyAll(
                                          CircleBorder(),
                                        ),
                                      ),
                                      onPressed: () {
                                        CommunicationHelper.openSmsApp(
                                          context,
                                          item.phone!,
                                        );
                                      },
                                      child: Icon(Icons.message_outlined),
                                    ),

                                    PullDownButton(
                                      routeTheme: PullDownMenuRouteTheme(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                      itemBuilder: (context) => [
                                        PullDownMenuItem(
                                          onTap: () {
                                            Slidable.of(
                                              context,
                                            )?.openEndActionPane(
                                              duration: Durations.long1,
                                            );
                                            Slidable.of(context)?.dismiss(
                                              ResizeRequest(
                                                Durations.medium3,
                                                () {
                                                  context
                                                      .read<CostumerProvider>()
                                                      .deleteCostumer(index);
                                                },
                                              ),
                                            );
                                          },
                                          title: 'Sil',
                                          isDestructive: true,
                                          iconColor: Colors.red,
                                          icon: Icons.delete_outline,
                                        ),
                                        PullDownMenuItem(
                                          onTap: () {
                                            navigateToEditCostumerPage(
                                              index,
                                              item,
                                            );
                                          },
                                          title: 'Düzenle',
                                          icon: Icons.edit_outlined,
                                        ),
                                        PullDownMenuItem(
                                          onTap: () {
                                            CommunicationHelper.shareCostumer(
                                              item,
                                            );
                                          },
                                          title: 'Paylaş',
                                          icon: Icons.share_outlined,
                                        ),
                                      ],
                                      position: PullDownMenuPosition.automatic,
                                      buttonBuilder: (context, showMenu) =>
                                          GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,

                                            onTap: () {
                                              showMenu();
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 5,
                                                top: 20,
                                                bottom: 20,
                                                right: 5,
                                              ),
                                              child: Icon(Icons.more_vert),
                                            ),
                                          ),
                                    ),
                                    /*     GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTapDown: (TapDownDetails details) async {
                                  final tapPosition = details.globalPosition;
                        
                                  final position = Rect.fromLTWH(
                                    tapPosition.dx,
                                    tapPosition.dy,
                                    -5,
                                    10,
                                  );
                        
                                  await showPullDownMenu(
                                    context: context,
                                    items: [
                                      PullDownMenuItem(
                                        onTap: () {
                                          context
                                              .read<CostumerProvider>()
                                              .deleteCostumer(index);
                                        },
                                        title: 'Sil',
                                        isDestructive: true,
                        
                                        iconColor: Colors.red,
                                        icon: CupertinoIcons.delete,
                                      ),
                                      PullDownMenuItem(
                                        onTap: () {
                                          navigateToEditCostumerPage(
                                            index,
                                            item,
                                          );
                                        },
                                        title: 'Düzenle',
                                        icon: CupertinoIcons.pencil,
                                      ),
                                      PullDownMenuItem(
                                        onTap: () {},
                                        title: 'Paylaş',
                                        icon: CupertinoIcons.share,
                                      ),
                                    ],
                                    position: position,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5,
                                    top: 20,
                                    bottom: 20,
                                    right: 5,
                                  ),
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                           */
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
