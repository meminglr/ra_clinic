import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:ra_clinic/func/utils.dart';

class TrashBinPage extends StatelessWidget {
  const TrashBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<CustomerModel> deletedList = context
        .watch<CustomerProvider>()
        .deletedCustomersList;

    return Scaffold(
      appBar: AppBar(title: const Text("Çöp Kutusu"), centerTitle: true),
      floatingActionButton: deletedList.isNotEmpty
          ? Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'emptyTrash',
                  onPressed: () => _confirmEmptyTrash(context),
                  backgroundColor: Colors.red,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text("Boşalt"),
                ),
                FloatingActionButton.extended(
                  heroTag: 'restoreAll',
                  onPressed: () => _confirmRestoreAll(context),
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.restore_from_trash),
                  label: const Text("Tümünü Geri Yükle"),
                ),
              ],
            )
          : null,
      body: deletedList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Çöp Kutusu Boş",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: deletedList.length,
              itemBuilder: (context, index) {
                final customer = deletedList[index];
                return Slidable(
                  key: Key(customer.customerId),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          context.read<CustomerProvider>().restoreCustomer(
                            customer.customerId,
                          );
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.green.shade100,
                        icon: Icons.restore,
                        label: 'Geri Yükle',
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
                        icon: Icons.delete_forever,
                        label: 'Tamamen Sil',
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ],
                  ),
                  child: Card.filled(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_off_outlined),
                      ),
                      title: Text(
                        customer.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Silinme Tarihi: ${Utils.toDate(customer.lastUpdated ?? DateTime.now())}",
                      ),
                      trailing: IconButton.filled(
                        icon: Icon(
                          Icons.restore_from_trash,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        onPressed: () {
                          context.read<CustomerProvider>().restoreCustomer(
                            customer.customerId,
                          );
                        },
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
        title: const Text("Kalıcı Olarak Sil"),
        content: Text(
          "${customer.name} adlı müşteriyi tamamen silmek istiyor musunuz? Bu işlem geri alınamaz.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<CustomerProvider>().permanentlyDeleteCustomer(
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

  void _confirmEmptyTrash(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Çöp Kutusunu Boşalt"),
        content: const Text(
          "Çöp kutusundaki TÜM müşteriler kalıcı olarak silinecek. Bu işlem geri alınamaz. Emin misiniz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<CustomerProvider>().clearTrash();
              Navigator.pop(ctx);
            },
            child: const Text("Hepsini Sil"),
          ),
        ],
      ),
    );
  }

  void _confirmRestoreAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tümünü Geri Yükle"),
        content: const Text(
          "Çöp kutusundaki tüm müşteriler geri yüklenecek. Onaylıyor musunuz?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("İptal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () {
              context.read<CustomerProvider>().restoreAllTrash();
              Navigator.pop(ctx);
            },
            child: const Text("Geri Yükle"),
          ),
        ],
      ),
    );
  }
}
