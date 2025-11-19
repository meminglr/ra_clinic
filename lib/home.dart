import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';
import 'package:ra_clinic/calendar/calendar_page.dart';
import 'package:ra_clinic/screens/costumers_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List pages = [Costumers(), CalendarPage()];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,

        title: InkWell(
          onTap: () {
            context.read<CostumerProvider>().addCostumer(
              CostumerModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: "Test Müşteri",
                phone: "05536834049",
                startDate: DateTime.now(),
                startDateString: DateTime.now().toString(),
                seansList: [],
                notes: "Yeni Gelen Müşteri",
              ),
            );
          },
          child: const Text("Clinic"),
        ),
        centerTitle: true,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) => {
          setState(() {
            selectedIndex = value;
          }),
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Müşteriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Takvim',
          ),
        ],
      ),

      body: pages[selectedIndex],
    );
  }
}
