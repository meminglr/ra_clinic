import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:ra_clinic/func/utils.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final Set<String> _selectedCustomerIds = {};

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
  Widget build(BuildContext context) {
    List<CustomerModel> archivedList = context
        .watch<CustomerProvider>()
        .archivedCustomersList;

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text("${_selectedCustomerIds.length} Seçildi")
            : const Text("Arşiv Kutusu"),
        centerTitle: true,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.unarchive_outlined),
                  tooltip: 'Seçilenleri Çıkar',
                  onPressed: () => _confirmUnarchiveSelected(context),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Seçilenleri Sil',
                  onPressed: () => _confirmDeleteSelected(context),
                ),
              ]
            : null,
      ),
      floatingActionButton: !_isSelectionMode && archivedList.isNotEmpty
          ? Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'deleteAllArchive',
                  onPressed: () => _confirmMoveAllToTrash(context),
                  backgroundColor: Colors.red,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text("Hepsini Sil"),
                ),
                FloatingActionButton.extended(
                  heroTag: 'unarchiveAll',
                  onPressed: () => _confirmUnarchiveAll(context),
                  backgroundColor: Colors.blue,
                  icon: const Icon(Icons.unarchive_outlined),
                  label: const Text("Tümünü Çıkar"),
                ),
              ],
            )
          : null,
      body: archivedList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.archive_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Arşiv Kutusu Boş",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: archivedList.length,
              itemBuilder: (context, index) {
                final customer = archivedList[index];
                final isSelected = _selectedCustomerIds.contains(
                  customer.customerId,
                );

                return GestureDetector(
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      _toggleSelection(customer.customerId);
                    }
                  },
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleSelection(customer.customerId);
                    }
                  },
                  child: Slidable(
                    key: Key(customer.customerId),
                    enabled: !_isSelectionMode,
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            context.read<CustomerProvider>().unarchiveCustomer(
                              customer.customerId,
                            );
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.blue.shade100,
                          icon: Icons.unarchive_outlined,
                          label: 'Arşivden Çıkar',
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            _confirmDelete(context, customer);
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
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 10,
                          top: 10,
                          bottom: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Selection Checkbox
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: _isSelectionMode
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : const SizedBox(),
                            ),
                            // Customer Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "Arşivlenme Tarihi: ${Utils.toDate(customer.lastUpdated ?? DateTime.now())}",
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons (Hidden in selection mode)
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: !_isSelectionMode
                                  ? IconButton.filled(
                                      icon: Icon(
                                        Icons.unarchive_outlined,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<CustomerProvider>()
                                            .unarchiveCustomer(
                                              customer.customerId,
                                            );
                                      },
                                    )
                                  : const SizedBox(),
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

  void _confirmDelete(BuildContext context, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sil"),
        content: Text(
          "${customer.name} adlı müşteriyi silmek istiyor musunuz? (Çöp kutusuna taşınır)",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<CustomerProvider>().deleteCustomer(
                customer.customerId,
              );
              Navigator.pop(ctx);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Seçilenleri Sil"),
        content: Text(
          "${_selectedCustomerIds.length} müşteriyi silmek istiyor musunuz? (Çöp kutusuna taşınır)",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<CustomerProvider>().deleteCustomers(
                _selectedCustomerIds.toList(),
              );
              _clearSelection();
              Navigator.pop(ctx);
            },
            child: const Text("Sil"),
          ),
        ],
      ),
    );
  }

  void _confirmUnarchiveSelected(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Seçilenleri Arşivden Çıkar"),
        content: Text(
          "${_selectedCustomerIds.length} müşteriyi arşivden çıkarmak istiyor musunuz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            onPressed: () {
              context.read<CustomerProvider>().unarchiveCustomers(
                _selectedCustomerIds.toList(),
              );
              _clearSelection();
              Navigator.pop(ctx);
            },
            child: const Text("Çıkar"),
          ),
        ],
      ),
    );
  }

  void _confirmMoveAllToTrash(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hepsini Sil"),
        content: const Text(
          "Arşivdeki TÜM müşteriler çöp kutusuna taşınacak. Emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<CustomerProvider>().moveAllArchivedToTrash();
              Navigator.pop(ctx);
            },
            child: const Text("Hepsini Sil"),
          ),
        ],
      ),
    );
  }

  void _confirmUnarchiveAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tümünü Çıkar"),
        content: const Text(
          "Arşivdeki tüm müşteriler arşivden çıkarılacak. Onaylıyor musunuz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            onPressed: () {
              context.read<CustomerProvider>().unarchiveAll();
              Navigator.pop(ctx);
            },
            child: const Text("Çıkar"),
          ),
        ],
      ),
    );
  }
}
