import 'package:flutter/material.dart';
import 'package:ra_clinic/calendar/calendar_page.dart';
import 'package:ra_clinic/screens/costumers_page.dart';
import 'package:ra_clinic/screens/profile_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // PageController'ı tanımlayın.
  late PageController _pageController;

  // Sayfa içeriğini tutan listeniz.
  final List<Widget> pages = [
    const Costumers(),
    const CalendarPage(),
    const SettingsPage(),
  ];

  // Seçili sayfanın indeksi.
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Controller'ı başlangıç indeksi ile başlatın.
    _pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    // Controller'ı temizlemeyi unutmayın.
    _pageController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
    });

    // *** Burası anahtar noktadır! ***
    // Tıklandığında PageView'e o sayfaya animasyonlu olarak (kayarak) gitmesini söyler.
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300), // Kayma süresi (300ms ideal)
      curve: Curves.easeInOutCubicEmphasized, // Yumuşak geçiş eğrisi
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // *** Sayfaların Kayarak Göründüğü Kısım: PageView ***
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),

        // Kullanıcı parmağıyla kaydırdığında alttaki navigasyon barını günceller.
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: pages,
        // İsteğe bağlı: Kaydırmayı sadece butonlara kısıtlamak için:
        // physics: const NeverScrollableScrollPhysics(),
      ),

      // *** Navigasyon Butonları Kısım: NavigationBar ***
      bottomNavigationBar: NavigationBar(
        onDestinationSelected:
            _onDestinationSelected, // Güncellediğimiz fonksiyona bağlandı
        selectedIndex: selectedIndex,
        // PageView'e geçişi PageController yönettiği için buradaki animationDuration'ı kaldırabiliriz veya düşük tutabiliriz.
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
    );
  }
}
