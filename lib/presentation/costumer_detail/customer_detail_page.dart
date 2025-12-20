import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/providers/auth_provider.dart';
import 'package:ra_clinic/services/webdav_service.dart';
// Proje importlarınızın doğru olduğundan emin olun
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_buttons.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/communication_notes_cards.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_phone_display.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/customer_files_widget.dart';

import 'package:ra_clinic/presentation/costumer_detail/widgets/costumer_financials_widget.dart';
import 'package:ra_clinic/providers/customer_provider.dart';

import '../../constants/app_constants.dart';
import '../../func/communication_helper.dart';
import '../../screens/customer_updating.dart';
import 'package:ra_clinic/presentation/costumer_detail/widgets/seans_manager_view.dart';

class CostumerDetail extends StatefulWidget {
  final String customerId;
  const CostumerDetail({required this.customerId, super.key});

  @override
  State<CostumerDetail> createState() => _CostumerDetailState();
}

class _CostumerDetailState extends State<CostumerDetail> {
  bool isMessageExpanded = false;
  bool isCallExpanded = false;

  void navigateToEditCostumerPage(CustomerModel costumer) async {
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

    CustomerModel? currentCostumerNullable;
    try {
      currentCostumerNullable = provider.customersList.firstWhere(
        (c) => c.customerId == widget.customerId,
      );
    } catch (e) {
      return const SizedBox();
    }

    final CustomerModel currentCostumer = currentCostumerNullable;
    var phoneIsNotEmpty = currentCostumer.phone?.isNotEmpty ?? false;
    var noteIsNotEmpty = currentCostumer.notes?.isNotEmpty ?? false;
    final messenger = ScaffoldMessenger.of(context);

    return DefaultTabController(
      length: 3, // Seanslar, Hesap, Medya olmak üzere 3 sekme
      child: Scaffold(
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
                        text: "Hesap",
                        icon: Icon(Icons.account_balance_wallet_outlined),
                      ),
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
          body: TabBarView(
            children: [
              // --- SEKME 1: SEANSLAR ---
              SeansManagerView(customer: currentCostumer),

              // --- SEKME 2: HESAP (FİNANSAL) ---
              CustomScrollView(
                key: const PageStorageKey<String>('hesap'),
                slivers: [
                  SliverToBoxAdapter(
                    child: FinancialSummaryCard(customer: currentCostumer),
                  ),
                  FinancialsSliverList(customer: currentCostumer),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                ],
              ),

              // --- SEKME 3: MEDYA ---
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
                      child: CustomerFilesWidget(
                        customerId: currentCostumer.customerId,
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
      automaticallyImplyLeading: false,
      leading: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      elevation: 0,
      pinned: true,
      floating: true,
      expandedHeight: MediaQuery.sizeOf(context).width,
      titleSpacing: 30,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 10),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            if (currentCostumer.profileImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: CachedNetworkImage(
                  imageUrl: context.read<WebDavService>().getFileUrl(
                    "${context.read<FirebaseAuthProvider>().currentUser?.uid}/customers/${currentCostumer.customerId}/${currentCostumer.profileImageUrl}",
                  ),
                  httpHeaders: context.read<WebDavService>().getAuthHeaders(),
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const SizedBox(),
                ),
              ),
          ],
        ),
        title: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Text(
            currentCostumer.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
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
                  navigateToEditCostumerPage(currentCostumer);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.edit_outlined, size: 25),
                  ),
                ),
              ),
              PullDownButton(
                routeTheme: PullDownMenuRouteTheme(
                  backgroundColor: AppConstants.dropDownButtonsColor(context),
                ),
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    onTap: () {
                      context.read<CustomerProvider>().archiveCustomer(
                        currentCostumer.customerId,
                      );
                      Navigator.pop(context);
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Müşteri arşivlendi")),
                      );
                    },
                    title: 'Arşive Ekle',
                    icon: Icons.archive_outlined,
                  ),
                  PullDownMenuItem(
                    onTap: () {
                      context.read<CustomerProvider>().deleteCustomer(
                        currentCostumer.customerId,
                      );
                      Navigator.pop(context);
                      messenger.showSnackBar(
                        const SnackBar(content: Text("Müşteri silindi")),
                      );
                    },
                    isDestructive: true,
                    title: 'Sil',
                    icon: Icons.delete_outline,
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.more_vert, size: 30),
                    ),
                  ),
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
