import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';
import 'package:ra_clinic/screens/add_costumer_page.dart';
import 'package:ra_clinic/presentation/costumer_detail/costumer_detail_page.dart';
import 'package:ra_clinic/screens/edit_costumer_page.dart';

class Costumers extends StatefulWidget {
  const Costumers({super.key});

  @override
  State<Costumers> createState() => _CostumersState();
}

class _CostumersState extends State<Costumers> {
  void navigateToAddCostumerPage() async {
    final CostumerModel? newCostumer = await Navigator.push<CostumerModel>(
      context,
      CupertinoPageRoute(builder: (builder) => AddCostumerPage()),
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
          return EditCostumerPage(
            costumer: costumer,
            seansList: costumer.seansList ?? [],
          );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAddCostumerPage();
        },
        label: const Text("Müşteri Ekle"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: Padding(
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
                  key: ValueKey(index),

                  endActionPane: ActionPane(
                    motion: const DrawerMotion(), // Kayma animasyonu
                    children: [
                      SlidableAction(
                        borderRadius: BorderRadius.circular(20),
                        onPressed: (_) {
                          print("Sil");
                        },
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red,
                        icon: Icons.delete_outlined,
                        label: 'Sil',
                      ),
                      SlidableAction(
                        borderRadius: BorderRadius.circular(20),
                        onPressed: (_) {
                          // Düzenleme işlemi
                          print("Düzenle");
                        },
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: 'Düzenle',
                      ),
                    ],
                  ),
                  child: Card.filled(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.green.shade100,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 16,
                      ),
                      child: Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: Column(
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
                                  "Seans Sayısı: ${item.seansList?.length ?? 0}",
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            children: [
                              Row(
                                children: [
                                  FilledButton(
                                    style: ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                        CircleBorder(),
                                      ),
                                    ),
                                    onPressed: () {},
                                    child: Icon(Icons.phone_outlined),
                                  ),
                                  FilledButton(
                                    style: ButtonStyle(
                                      shape: WidgetStatePropertyAll(
                                        CircleBorder(),
                                      ),
                                      backgroundColor: WidgetStatePropertyAll(
                                        Colors.green.shade600,
                                      ),
                                    ),
                                    onPressed: () {
                                      navigateToEditCostumerPage(index, item);
                                    },
                                    child: Icon(Icons.edit_outlined),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}
