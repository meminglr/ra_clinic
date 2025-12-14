import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
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
  DateTimeRange? _selectedDateRange;
  String _sortOption = 'date_desc'; // name_asc, name_desc, date_asc, date_desc

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
    _loadFilters();
    //  _initSyncSystem();
  }

  void _loadFilters() {
    final box = Hive.box('settingsBox');
    setState(() {
      _sortOption = box.get('customer_sort', defaultValue: 'date_desc');

      final start = box.get('customer_date_start');
      final end = box.get('customer_date_end');
      if (start != null && end != null) {
        _selectedDateRange = DateTimeRange(
          start: DateTime.parse(start),
          end: DateTime.parse(end),
        );
      }
    });
  }

  void _saveFilters() {
    final box = Hive.box('settingsBox');
    box.put('customer_sort', _sortOption);
    if (_selectedDateRange != null) {
      box.put(
        'customer_date_start',
        _selectedDateRange!.start.toIso8601String(),
      );
      box.put('customer_date_end', _selectedDateRange!.end.toIso8601String());
    } else {
      box.delete('customer_date_start');
      box.delete('customer_date_end');
    }
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filtrele ve Sırala",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Temizle
                          setModalState(() {
                            _selectedDateRange = null;
                            _sortOption = 'date_desc';
                          });
                          setState(() {});
                          _saveFilters(); // Kaydet
                          Navigator.pop(context);
                        },
                        child: const Text("Temizle"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ExpansionTile(
                    title: const Text(
                      "Tarih Aralığı",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _selectedDateRange == null
                          ? "Tüm Zamanlar"
                          : "${Utils.toDate(_selectedDateRange!.start)} - ${Utils.toDate(_selectedDateRange!.end)}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    childrenPadding: const EdgeInsets.only(bottom: 10),
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: SfDateRangePicker(
                          showTodayButton: true,
                          rangeTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          headerStyle: DateRangePickerHeaderStyle(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerLow,
                          ),
                          selectionShape: DateRangePickerSelectionShape.circle,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          showActionButtons: false,
                          selectionMode: DateRangePickerSelectionMode.range,
                          selectionTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          monthCellStyle: const DateRangePickerMonthCellStyle(),
                          initialSelectedRange: _selectedDateRange != null
                              ? PickerDateRange(
                                  _selectedDateRange!.start,
                                  _selectedDateRange!.end,
                                )
                              : null,
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                                if (args.value is PickerDateRange) {
                                  final range = args.value as PickerDateRange;
                                  if (range.startDate != null &&
                                      range.endDate != null) {
                                    setModalState(() {
                                      _selectedDateRange = DateTimeRange(
                                        start: range.startDate!,
                                        end: range.endDate!,
                                      );
                                    });
                                    setState(() {});
                                    _saveFilters();
                                  }
                                }
                              },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    "Sıralama",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 2,
                    children: [
                      _buildSortChip(setModalState, 'name_asc', 'İsim (A-Z)'),
                      _buildSortChip(setModalState, 'name_desc', 'İsim (Z-A)'),
                    ],
                  ),
                  Wrap(
                    children: [
                      _buildSortChip(
                        setModalState,
                        'date_desc',
                        'Tarih (Yeni)',
                      ),
                      _buildSortChip(setModalState, 'date_asc', 'Tarih (Eski)'),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tamam"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(StateSetter setModalState, String value, String label) {
    return ChoiceChip(
      showCheckmark: false,
      side: BorderSide.none,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.3),
      label: Text(label),
      selected: _sortOption == value,
      onSelected: (bool selected) {
        if (selected) {
          setModalState(() {
            _sortOption = value;
          });
          setState(() {});
          _saveFilters(); // Seçim anında kaydet
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<CustomerModel> allCostumers = context
        .watch<CustomerProvider>()
        .customersList;
    // Listeyi filtrele
    List<CustomerModel> filteredList = allCostumers.where((c) {
      // 1. Arama Filtresi
      bool matchesSearch =
          _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // 2. Tarih Filtresi
      bool matchesDate = true;
      if (_selectedDateRange != null) {
        final start = _selectedDateRange!.start;
        // Bitiş tarihini günün sonuna çekelim ki o günü de kapsasın
        final end = _selectedDateRange!.end
            .add(const Duration(days: 1))
            .subtract(const Duration(milliseconds: 1));

        // Basitçe aralık kontrolü
        matchesDate =
            c.startDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            c.startDate.isBefore(end);
      }

      return matchesSearch && matchesDate;
    }).toList();

    // Listeyi Sırala
    filteredList.sort((a, b) {
      switch (_sortOption) {
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'date_asc':
          return a.startDate.compareTo(b.startDate);
        case 'date_desc':
        default:
          return b.startDate.compareTo(a.startDate);
      }
    });

    List<CustomerModel> costumersList = filteredList;
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
        child: Row(
          children: [
            Expanded(
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
            const SizedBox(width: 10),
            FilledButton.tonal(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).primaryColor.withValues(alpha: 0.1),
                ),
              ),
              onPressed: _showFilterBottomSheet,
              child: Icon(Icons.filter_list),
            ),
          ],
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
