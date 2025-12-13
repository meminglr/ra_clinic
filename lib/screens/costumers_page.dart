import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:ra_clinic/constants/app_constants.dart';
import 'package:ra_clinic/func/communication_helper.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/presentation/costumer_detail/costumer_detail_page.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:ra_clinic/func/utils.dart';
import 'costumer_updating.dart';

class CostumersPage extends StatefulWidget {
  const CostumersPage({super.key});

  @override
  State<CostumersPage> createState() => _CostumersPageState();
}

class _CostumersPageState extends State<CostumersPage> {
  final Set<String> _selectedCustomerIds = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";

  bool get _isSelectionMode => _selectedCustomerIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedCustomerIds.contains(id)) {
        _selectedCustomerIds.remove(id);
      } else {
        _selectedCustomerIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCustomerIds.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    //  _initSyncSystem();
  }

  void navigateToAddCostumerPage() async {
    _searchFocusNode.unfocus();
    final CustomerModel? newCostumer = await Navigator.push<CustomerModel>(
      context,
      CupertinoPageRoute(builder: (builder) => CostumerUpdating()),
    );
    if (newCostumer != null) {
      context.read<CustomerProvider>().addCustomer(newCostumer);
    }
  }

  void navigateToEditCostumerPage(int index, CustomerModel costumer) async {
    _searchFocusNode.unfocus();
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
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<CustomerModel> allCostumers = context
        .watch<CustomerProvider>()
        .customersList;
    List<CustomerModel> costumersList = _searchQuery.isEmpty
        ? allCostumers
        : allCostumers
              .where(
                (c) =>
                    c.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
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
            buildSearchCustomer(),
            if (costumersList.isNotEmpty)
              buildCustomerList(costumersList)
            else if (_searchQuery.isNotEmpty)
              buildNoSearchResults()
            else
              buildNoCustomer(),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter buildNoSearchResults() {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            '"$_searchQuery" bulunamadı.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _shareSelected(List<CustomerModel> allCustomers) {
    final selectedItems = allCustomers
        .where((c) => _selectedCustomerIds.contains(c.customerId))
        .toList();
    if (selectedItems.isNotEmpty) {
      CommunicationHelper.shareCustomers(selectedItems);
    }
  }

  void _confirmDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Seçilenleri Sil"),
        content: Text(
          "${_selectedCustomerIds.length} müşteriyi silmek istediğinize emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CustomerProvider>().deleteCustomers(
                _selectedCustomerIds.toList(),
              );
              _clearSelection();
            },
            child: const Text("Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  SliverAppBar buildAppBar() {
    return SliverAppBar(
      leading: _isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: _clearSelection,
            )
          : null,
      actions: _isSelectionMode
          ? [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.black87),
                onPressed: () {
                  final allCustomers = context
                      .read<CustomerProvider>()
                      .customersList;
                  _shareSelected(allCustomers);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmDeleteSelected(context),
              ),
            ]
          : null,
      pinned: true,
      snap: false,
      floating: true,
      expandedHeight: 130.0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: _isSelectionMode
            ? Text(
                "${_selectedCustomerIds.length} Seçildi",
                style: TextStyle(color: Colors.black87, fontSize: 18),
              )
            : Text('Müşteriler'),
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
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Müşteri Ara...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = "";
                      });
                    },
                  )
                : null,
          ),
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
          CustomerModel item = costumersList[index];
          final isSelected = _selectedCustomerIds.contains(item.customerId);

          return GestureDetector(
            onLongPress: () {
              // Uzun basınca seçim moduna gir ve bu item'ı seç
              if (!_isSelectionMode) {
                _toggleSelection(item.customerId);
              }
            },
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(item.customerId);
                // Eğer seçim modunda son eleman seçimi kaldırılırsa moddan çık
                if (_selectedCustomerIds.isEmpty) {
                  // _clearSelection zaten boşaltıyor ama setState tetiklemek için gerekebilir
                  // şu anki mantıkta _isSelectionMode getter olduğu için
                  // liste boşaldığında UI otomatik güncellenecek (setState _toggleSelection içinde var).
                }
              } else {
                _searchFocusNode.unfocus();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (builder) =>
                        CostumerDetail(customerId: item.customerId),
                  ),
                );
              }
            },
            child: Slidable(
              key: Key(item.customerId),
              enabled: !_isSelectionMode, // Seçim modunda kaydırmayı kapat
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
                      // Seçim Checkbox (Opsiyonel: Sadece modlaysa gösterilebilirdi ama renk değişimi yeterli)
                      if (_isSelectionMode)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),

                      Expanded(
                        child: Column(
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
                      ),
                      // Aksiyon butonları (Arama/Mesaj) - Seçim modunda gizlenebilir veya pasif olabilir
                      // Seçim modundaysak bunları gizlemek daha temiz bir görüntü sağlar
                      if (!_isSelectionMode)
                        Row(
                          children: [
                            FilledButton(
                              style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.zero,
                                ),
                                minimumSize: WidgetStatePropertyAll(
                                  Size(40, 40),
                                ),
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
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.zero,
                                ),
                                minimumSize: WidgetStatePropertyAll(
                                  Size(40, 40),
                                ),
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
                                    Slidable.of(context)?.openEndActionPane(
                                      duration: Durations.long1,
                                    );
                                    Slidable.of(context)?.dismiss(
                                      ResizeRequest(Durations.medium3, () {
                                        context
                                            .read<CustomerProvider>()
                                            .deleteCustomer(item.customerId);
                                      }),
                                    );
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
