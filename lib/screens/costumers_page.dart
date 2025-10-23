import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/screens/add_costumer_page.dart';
import 'package:ra_clinic/screens/costumer_detail_page.dart';

class Costumers extends StatefulWidget {
  const Costumers({super.key});

  @override
  State<Costumers> createState() => _CostumersState();
}

class _CostumersState extends State<Costumers> {
  List<CostumerModel> costumersList = [];

  void navigateToAddCostumerPage() async {
    final CostumerModel? newCostumer = await Navigator.push<CostumerModel>(
      context,
      CupertinoPageRoute(builder: (builder) => const AddCostumerPage2()),
    );

    if (newCostumer != null) {
      setState(() {
        costumersList.add(newCostumer);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Yeni müşteri eklendi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          /*   Navigator.push(
            context,
            CupertinoPageRoute(builder: (builder) => const AddCostumerPage()),
          );*/
          navigateToAddCostumerPage();
        },
        label: const Text("Müşteri Ekle"),
        icon: const Icon(Icons.add),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            itemCount: costumersList.length,
            itemBuilder: (itemBuilder, index) {
              CostumerModel item = costumersList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (builder) => CostumerDetail(costumer: item),
                    ),
                  );
                },
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
                        /*  CircleAvatar(
                          backgroundColor: Colors.indigo.shade600,
                          radius: 30,
                          backgroundImage: AssetImage(item.profileImage),
                        ),*/
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${item.name}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text("${item.startDateString}"),
                              Text(
                                "Seans Sayısı: ${item.seansList?.length ?? 0}",
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FilledButton.icon(
                                onPressed: () {},
                                label: Text("Ara"),
                                icon: Icon(Icons.phone_outlined),
                              ),
                              FilledButton.icon(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Colors.green.shade600,
                                  ),
                                ),
                                onPressed: () {},
                                label: Text("Düzenle"),
                                icon: Icon(Icons.edit_outlined),
                              ),
                            ],
                          ),
                        ),
                      ],
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
