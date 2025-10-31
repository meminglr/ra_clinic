import 'package:flutter/material.dart';
import 'package:ra_clinic/screens/calendar_page.dart';
import 'package:ra_clinic/screens/costumers_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List pages = [Costumers(), Calendar()];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clinic"), centerTitle: true),
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
