import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_buttons.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_notes_cards.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_phone_display.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/no_seans_warning_view.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/seans_list_view.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';

import '../../constants/app_constants.dart';
import '../../func/communication_helper.dart';
import '../../screens/costumer_updating.dart';

class CostumerDetail2 extends StatefulWidget {
  final int index;
  const CostumerDetail2({required this.index, super.key});

  @override
  State<CostumerDetail2> createState() => _CostumerDetail2State();
}

class _CostumerDetail2State extends State<CostumerDetail2> {
  bool isMessageExpanded = false;
  bool isCallExpanded = false;

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
      if (mounted) {
        context.read<CostumerProvider>().editCostumer(index, modifiedCostumer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Değişiklikler kaydedildi")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider'dan veriyi alırken hata almamak için var kontrolü
    final provider = context.watch<CostumerProvider>();
    if (widget.index >= provider.costumersList.length) {
      return const SizedBox(); // Silinme durumunda hata vermemesi için
    }

    CostumerModel currentCostumer = provider.costumersList[widget.index];
    var phoneIsNotEmpty = currentCostumer.phone?.isNotEmpty ?? false;
    var noteIsNotEmpty = currentCostumer.notes?.isNotEmpty ?? false;
    final messenger = ScaffoldMessenger.of(context);

    // 1. ADIM: DefaultTabController ile sarmala (2 Sekme: Seanslar ve Notlar)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigateToEditCostumerPage(widget.index, currentCostumer);
          },
          label: const Text("Düzenle"),
          icon: const Icon(Icons.edit_outlined),
        ),
        // 2. ADIM: NestedScrollView kullanımı
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // --- Müşteri Adı ve AppBar ---
              musteriAdiAppBar(context, currentCostumer, messenger),

              // --- İletişim Bilgileri ve Butonlar (Scroll ile yukarı gider) ---
              communicationButtons(phoneIsNotEmpty, currentCostumer, messenger),

              // --- 3. ADIM: Sticky TabBar (Yapışkan Tab) ---
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(text: "Seanslar", icon: Icon(Icons.list_alt)),
                      Tab(
                        text: "Medya",
                        icon: Icon(Icons.photo_library_outlined),
                      ),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          // 4. ADIM: Tab İçerikleri
          // ...
          body: TabBarView(
            children: [
              // --- SEKME 1: SEANSLAR ---
              CustomScrollView(
                key: const PageStorageKey<String>('seanslar'),
                slivers: [
                  if (currentCostumer.seansList.isEmpty)
                    // NoSeansWarning normal bir Column/Container ise Adapter içinde kalmalı
                    SliverToBoxAdapter(child: NoSeansWarning())
                  else
                    // DÜZELTME: Adapter kaldırıldı, direkt listeye eklendi.
                    SeansListView(seansList: currentCostumer.seansList),

                  // Listenin en altına boşluk eklemek için (FAB butonu kapatmasın diye)
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),

              // --- SEKME 2: NOTLAR ---
              // (Burası aynı kalabilir)
              SingleChildScrollView(
                key: const PageStorageKey<String>('medya'),
                // ...
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter communicationButtons(
    bool phoneIsNotEmpty,
    CostumerModel currentCostumer,
    ScaffoldMessengerState messenger,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Column(
          children: [
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  SliverAppBar musteriAdiAppBar(
    BuildContext context,
    CostumerModel currentCostumer,
    ScaffoldMessengerState messenger,
  ) {
    return SliverAppBar(
      elevation: 0,
      pinned: true,
      floating: true,
      expandedHeight: 200,
      titleSpacing: 30,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 10),
        background: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            color: AppConstants.sliverAppBarFlexColor(context),
          ),
        ),
        title: Text(
          currentCostumer.name,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                  context.read<CostumerProvider>().deleteCostumer(widget.index);
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    const SnackBar(content: Text("Müşteri silindi")),
                  );
                },
                child: const Icon(Icons.delete_outline, size: 30),
              ),
              PullDownButton(
                routeTheme: PullDownMenuRouteTheme(
                  backgroundColor: AppConstants.dropDownButtonsColor(context),
                ),
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    onTap: () {
                      navigateToEditCostumerPage(widget.index, currentCostumer);
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
                  onTap: showMenu,
                  child: const Icon(Icons.more_vert, size: 30),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Yardımcı Sınıf: TabBar'ın Sticky olması için gerekli ---
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Arka plan rengi
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
