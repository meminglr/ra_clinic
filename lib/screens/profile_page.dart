import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/sync_provider.dart';
import 'package:ra_clinic/providers/theme_provider.dart';

import 'auth_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   _syncService = SyncService(user.uid);

    //   // ÖNCE Listenerları kur (Bunlar bir kere kurulur)
    //   _syncService!.setupHiveListeners();

    //   // SONRA Başlat (Eğer ayar açıksa çalışmaya başlar)
    //   _syncService!.initialize();
    // }
  }

  @override
  Widget build(BuildContext context) {
    // listen: true kullanılması, sayfa açıkken tema değişikliklerini anlık yansıtmak içindir
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          buildAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              // 1. Bölüm: Auth StreamBuilder
              buildAuthStream(),

              const SizedBox(height: 10),

              // 2. Bölüm: Tema Ayarı
              buildThemeTile(themeProvider),
              const Divider(),
              Consumer<SyncProvider>(
                builder: (context, provider, _) {
                  return SwitchListTile(
                    title: const Text("Senkronizasyon"),
                    subtitle: Text(
                      provider.isSyncEnabled
                          ? "Veriler Buluta Yedekleniyor"
                          : "Sadece Cihazda (Offline)",
                    ),
                    secondary: Icon(
                      provider.isSyncEnabled ? Icons.cloud : Icons.cloud_off,
                    ),
                    value: provider.isSyncEnabled,
                    onChanged: (val) {
                      // Provider üzerinden kontrol
                      provider.toggleSync(val);
                    },
                  );
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  SliverAppBar buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Ayarlar'),
        background: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            // color: AppConstants.sliverAppBarFlexColor(context), // Renk sabitiniz varsa bunu açın
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest, // Yedek renk
          ),
        ),
      ),
    );
  }

  StreamBuilder<User?> buildAuthStream() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          context.read<SyncProvider>().syncNow();
          // Kullanıcı giriş yapmamışsa
          return ListTile(
            title: const Text('Giriş Yap / Kayıt Ol'),
            subtitle: const Text("Supabase ile kimlik doğrulama işlemleri"),
            trailing: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (builder) => const AuthPage()),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Giriş Yap'),
            ),
          );
        } else {
          // Kullanıcı giriş yapmışsa
          // Button'un çok geniş durmaması için Padding içine aldım
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: FilledButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.person),
              label: const Text('Çıkış Yap'),
              style: FilledButton.styleFrom(
                backgroundColor:
                    Colors.redAccent, // Çıkış butonu için renk önerisi
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildThemeTile(ThemeProvider themeProvider) {
    return SwitchListTile(
      title: const Text('Karanlık Mod'),
      subtitle: const Text(
        'Uygulamanın temasını karanlık/aydınlık olarak ayarla',
      ),
      secondary: Icon(
        themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
      ),
      value: themeProvider.isDark,
      onChanged: (v) => themeProvider.setDark(v),
    );
  }
}
