import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/constants/app_constants.dart';
import 'package:ra_clinic/func/communication_helper.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/costumer_detail_page.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';
import 'package:ra_clinic/func/utils.dart';
import 'costumer_updating.dart';

class CostumersPage extends StatefulWidget {
  const CostumersPage({super.key});

  @override
  State<CostumersPage> createState() => _CostumersPageState();
}

class _CostumersPageState extends State<CostumersPage> {
  @override
  void initState() {
    super.initState();
    //  _initSyncSystem();
  }

  void navigateToAddCostumerPage() async {
    final CustomerModel? newCostumer = await Navigator.push<CustomerModel>(
      context,
      CupertinoPageRoute(builder: (builder) => CostumerUpdating()),
    );
    if (newCostumer != null) {
      context.read<CustomerProvider>().addCustomer(newCostumer);
    }
  }

  void navigateToEditCostumerPage(int index, CustomerModel costumer) async {
    final CustomerModel? modifiedCostumer = await Navigator.push<CustomerModel>(
      context,
      CupertinoPageRoute(
        builder: (builder) {
          return CostumerUpdating(costumer: costumer);
        },
      ),
    );

    if (modifiedCostumer != null) {
      context.read<CustomerProvider>().editCustomer(modifiedCostumer);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Değişiklikler kaydedildi")));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<CustomerModel> costumersList = context
        .watch<CustomerProvider>()
        .customersList;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAddCostumerPage();
        },
        label: const Text("Müşteri Ekle"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            buildAppBar(),
            costumersList.isEmpty ? buildNoCustomer() : buildSearchCustomer(),

            buildCustomerList(costumersList),
          ],
        ),
      ),
    );
  }

  SliverAppBar buildAppBar() {
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: true,
      expandedHeight: 130.0,
      flexibleSpace: const FlexibleSpaceBar(
        centerTitle: true,
        title: Text('Müşteriler'),
      ),
    );
  }

  SliverToBoxAdapter buildNoCustomer() {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 100),
          Text(
            "Henüz eklenmiş bir müşteri yok.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  SliverPadding buildSearchCustomer() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      sliver: SliverToBoxAdapter(
        child: TextField(
          focusNode: FocusNode(),
          decoration: InputDecoration(hintText: 'Müşteri Ara...'),
        ),
      ),
    );
  }

  SliverPadding buildCustomerList(List<CustomerModel> costumersList) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverList.builder(
        itemCount: costumersList.length,
        itemBuilder: (context, index) {
          // itemBuilder ismini context olarak düzelttim (standart kullanım)
          CustomerModel item = costumersList[index];
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
              key: Key(item.customerId),
              endActionPane: ActionPane(
                dismissible: DismissiblePane(
                  onDismissed: () {
                    context.read<CustomerProvider>().deleteCustomer(
                      item.customerId,
                    );
                  },
                ),
                motion: const StretchMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      context.read<CustomerProvider>().deleteCustomer(
                        item.customerId,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(Utils.toDate(item.startDate)),
                          Text("Seans Sayısı: ${item.seansList.length}"),
                        ],
                      ),
                      Row(
                        children: [
                          FilledButton(
                            style: const ButtonStyle(
                              padding: WidgetStatePropertyAll(EdgeInsets.zero),
                              minimumSize: WidgetStatePropertyAll(Size(40, 40)),
                              shape: WidgetStatePropertyAll(CircleBorder()),
                            ),
                            onPressed: () {
                              CommunicationHelper.makePhoneCall(
                                context,
                                item.phone!,
                              );
                            },
                            child: const Icon(Icons.phone_outlined),
                          ),
                          FilledButton(
                            style: const ButtonStyle(
                              padding: WidgetStatePropertyAll(EdgeInsets.zero),
                              minimumSize: WidgetStatePropertyAll(Size(40, 40)),
                              shape: WidgetStatePropertyAll(CircleBorder()),
                            ),
                            onPressed: () {
                              CommunicationHelper.openSmsApp(
                                context,
                                item.phone!,
                              );
                            },
                            child: const Icon(Icons.message_outlined),
                          ),
                          PullDownButton(
                            routeTheme: PullDownMenuRouteTheme(
                              backgroundColor:
                                  AppConstants.dropDownButtonsColor(context),
                            ),
                            itemBuilder: (context) => [
                              PullDownMenuItem(
                                onTap: () {
                                  // Slidable'ı programatik olarak açıp silme işlemi
                                  final slidable = Slidable.of(context);
                                  slidable?.openEndActionPane(
                                    duration: Durations.long1,
                                  );

                                  // Biraz bekleyip dismiss animasyonunu tetikle
                                  Future.delayed(Durations.medium3, () {
                                    if (context.mounted) {
                                      context
                                          .read<CustomerProvider>()
                                          .deleteCustomer(item.customerId);
                                    }
                                  });
                                },
                                title: 'Sil',
                                isDestructive: true,
                                iconColor: Colors.red,
                                icon: Icons.delete_outline,
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  navigateToEditCostumerPage(index, item);
                                },
                                title: 'Düzenle',
                                icon: Icons.edit_outlined,
                              ),
                              PullDownMenuItem(
                                onTap: () {
                                  CommunicationHelper.shareCostumer(item);
                                },
                                title: 'Paylaş',
                                icon: Icons.share_outlined,
                              ),
                            ],
                            position: PullDownMenuPosition.automatic,
                            buttonBuilder: (context, showMenu) =>
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: showMenu,
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                      left: 5,
                                      top: 20,
                                      bottom: 20,
                                      right: 5,
                                    ),
                                    child: Icon(Icons.more_vert),
                                  ),
                                ),
                          ),
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
    );
  }
}
