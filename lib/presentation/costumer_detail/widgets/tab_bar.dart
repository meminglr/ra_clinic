import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: CustomScrollTabOrnegi()));
}

class CustomScrollTabOrnegi extends StatelessWidget {
  const CustomScrollTabOrnegi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // DefaultTabController yine gerekli (veya custom controller)
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          // 1. Kısım: Başlık ve TabBar (Scroll ile hareket eden kısım)
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: const Text('Profil Sayfası'),
                expandedHeight: 200.0, // Başlığın açık halinin yüksekliği
                floating: false,
                pinned: true, // ÖNEMLİ: TabBar'ın yukarıda sabit kalması için true olmalı
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    "https://picsum.photos/600/400",
                    fit: BoxFit.cover,
                  ),
                ),
                // TabBar'ı SliverAppBar'ın altına ekliyoruz
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(icon: Icon(Icons.grid_on), text: "Gönderiler"),
                    Tab(icon: Icon(Icons.favorite), text: "Beğeniler"),
                    Tab(icon: Icon(Icons.info), text: "Hakkında"),
                  ],
                ),
              ),
            ];
          },
          // 2. Kısım: Tab İçerikleri
          body: TabBarView(
            children: [
              // İçeriklerin de scroll edilebilir olması gerekir (ListView, GridView vb.)
              _listeOlustur("Gönderi", Colors.blue[100]!),
              _listeOlustur("Beğeni", Colors.red[100]!),
              const Center(child: Text("Hakkında Sayfası")),
            ],
          ),
        ),
      ),
    );
  }

  // Örnek içerik listesi üreten yardımcı metod
  Widget _listeOlustur(String baslik, Color renk) {
    // CustomScrollView içinde performans için ListView.builder kullanılır
    // Ancak NestedScrollView içinde olduğumuz için özel bir anahtar kelimeye gerek yok,
    // direkt ListView kullanabiliriz, NestedScrollView bunu algılar.
    return ListView.builder(
      // Bu padding, listenin TabBar'ın altında kalmamasını garantiye alır (bazen gerekir)
      padding: EdgeInsets.zero, 
      itemCount: 30,
      itemBuilder: (context, index) {
        return Container(
          height: 50,
          margin: const EdgeInsets.all(8),
          color: renk,
          alignment: Alignment.center,
          child: Text('$baslik $index'),
        );
      },
    );
  }
}