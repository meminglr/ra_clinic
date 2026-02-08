import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/calendar/calendar_page.dart';
import 'package:ra_clinic/screens/customers_page.dart';
import 'package:ra_clinic/screens/profile_page.dart';

import 'providers/sync_provider.dart';
import 'providers/user_profile_provider.dart';
import 'screens/complete_profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

int selectedIndex = 0;

class _HomeState extends State<Home> {
  late PageController _pageController;

  final List<Widget> pages = [
    const CostumersPage(),
    const CalendarPage(),
    const SettingsPage(), // Düzeltilmiş: SettingsPage -> ProfilePage
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
    // 1. Kullanıcı ID'sini Provider'a verip sistemi başlatıyoruz
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // initState içinde Provider'a erişirken "listen: false" çok önemlidir.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        context.read<SyncProvider>().init(user.uid);

        // 2. Profil kontrolü yap
        final profileProvider = context.read<UserProfileProvider>();
        await profileProvider.fetchUserProfile(user.uid);

        if (!profileProvider.isProfileComplete) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompleteProfilePage(),
              ),
            );
          }
        }
      });
    }
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
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
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
