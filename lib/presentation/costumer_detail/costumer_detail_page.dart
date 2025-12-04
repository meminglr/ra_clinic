import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
// Proje importlarınızın doğru olduğundan emin olun
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

class CostumerDetail extends StatefulWidget {
  final int index;
  const CostumerDetail({required this.index, super.key});

  @override
  State<CostumerDetail> createState() => _CostumerDetailState();
}

class _CostumerDetailState extends State<CostumerDetail> {
  bool isMessageExpanded = false;
  bool isCallExpanded = false;

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
      if (mounted) {
        context.read<CustomerProvider>().editCustomer(modifiedCostumer);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Değişiklikler kaydedildi")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    // Silinme durumunda index hatası almamak için güvenlik kontrolü
    if (widget.index >= provider.customersList.length) {
      return const SizedBox();
    }

    CustomerModel currentCostumer = provider.customersList[widget.index];
    var phoneIsNotEmpty = currentCostumer.phone?.isNotEmpty ?? false;
    var noteIsNotEmpty = currentCostumer.notes?.isNotEmpty ?? false;
    final messenger = ScaffoldMessenger.of(context);

    return DefaultTabController(
      length: 2, // Seanslar ve Notlar/Medya olmak üzere 2 sekme
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigateToEditCostumerPage(widget.index, currentCostumer);
          },
          label: const Text("Düzenle"),
          icon: const Icon(Icons.edit_outlined),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              // 1. Müşteri Adı ve Üst Bar
              musteriAdiAppBar(context, currentCostumer, messenger),

              // 2. İletişim Butonları (Scroll ile yukarı gider)
              communicationButtons(phoneIsNotEmpty, currentCostumer, messenger),
              SliverToBoxAdapter(
                child: CostumerNotesCard(
                  costumer: currentCostumer,
                  noteIsNotEmpty: noteIsNotEmpty,
                ),
              ),

              // 3. Yapışkan TabBar
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Theme.of(
                      context,
                    ).colorScheme.primary, // Aktif renk
                    unselectedLabelColor: Colors.grey, // Pasif renk
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: "Seanslar", icon: Icon(Icons.list_alt)),
                      Tab(
                        text: "Notlar & Medya",
                        icon: Icon(Icons.note_alt_outlined),
                      ),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // --- SEKME 1: SEANSLAR ---
              CustomScrollView(
                key: const PageStorageKey<String>('seanslar'),
                slivers: [
                  if (currentCostumer.seansList.isEmpty)
                    // NoSeansWarning normal bir Widget olduğu için Adapter içinde olmalı
                    NoSeansWarning()
                  else
                    // DÜZELTME: SeansListView zaten Sliver olduğu için Adapter kaldırıldı!
                    SeansListView(seansList: currentCostumer.seansList),

                  // FAB butonunun altında içerik kalmasın diye boşluk
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),

              // --- SEKME 2: NOTLAR VE MEDYA ---
              CustomScrollView(
                key: const PageStorageKey<String>('medya'),
                slivers: [
                  // İçerik normal widgetlardan oluştuğu için Adapter kullanıyoruz
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          CostumerNotesCard(
                            costumer: currentCostumer,
                            noteIsNotEmpty: noteIsNotEmpty,
                          ),
                          // İleride buraya medya galerisi ekleyebilirsiniz
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Yardımcı Widget Metodları ---

  SliverToBoxAdapter communicationButtons(
    bool phoneIsNotEmpty,
    CustomerModel currentCostumer,
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
          ],
        ),
      ),
    );
  }

  SliverAppBar musteriAdiAppBar(
    BuildContext context,
    CustomerModel currentCostumer,
    ScaffoldMessengerState messenger,
  ) {
    return SliverAppBar(
      elevation: 0,
      pinned: true,
      floating: true,
      expandedHeight: 200,
      titleSpacing: 30,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 10),
        background: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            // color: AppConstants.sliverAppBarFlexColor(context), // Renk sabitiniz varsa bunu açın
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest, // Yedek renk
          ),
        ),
        title: Text(
          currentCostumer.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
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
                  context.read<CustomerProvider>().deleteCustomer(
                    currentCostumer.customerId,
                  );
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

// --- TabBar Delegate Sınıfı ---
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
      child: Material(
        // Material widget'ı, TabBar'ın text renklerini ve
        // tıklama efektini düzgün göstermesi için gereklidir.
        color: Colors.transparent,
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
