import 'package:flutter/material.dart';
import 'package:ra_clinic/calendar/calendar_page.dart';
import 'package:ra_clinic/screens/costumers_page.dart';
import 'package:ra_clinic/screens/costumers_page.dart';
import 'package:ra_clinic/screens/profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController _pageController;

  final List<Widget> pages = [
    const CostumersPage(),
    const CalendarPage(),
    const SettingsPage(), // Düzeltilmiş: SettingsPage -> ProfilePage
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWideScreen = width > 640;

    return Scaffold(
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              onDestinationSelected: _onDestinationSelected,
              selectedIndex: selectedIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.group_outlined),
                  label: 'Müşteriler',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Takvim',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profil',
                ),
              ],
            ),

      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _onDestinationSelected,

              // Leading içeriğini minimal yüksekliğe indiriyoruz
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                  const SizedBox(height: 8),
                ],
              ),

              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: Text('Müşteriler'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: Text('Takvim'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profil'),
                ),
              ],
            ),

          if (isWideScreen) const VerticalDivider(thickness: 1, width: 1),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: isWideScreen ? Axis.vertical : Axis.horizontal,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
