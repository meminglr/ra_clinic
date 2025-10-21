import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/screens/add_costumer_page.dart';

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
      CupertinoPageRoute(builder: (builder) => const AddCostumerPage()),
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
        child: ListView.builder(
          itemCount: costumersList.length,
          itemBuilder: (itemBuilder, index) {
            CostumerModel item = costumersList[index];
            return Card(
              child: Column(
                children: [
                  Text(item.name),
                  Text(item.phone),
                  Text("Kayıt Tarihi: ${item.startDate}"),
                  Text("Not: ${item.notes ?? "Yok"}"),
                  Text("Seans Sayısı: ${item.seansList?.length ?? 0}"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
