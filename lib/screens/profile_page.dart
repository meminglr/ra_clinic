import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/sync_provider.dart';
import 'package:ra_clinic/providers/theme_provider.dart';

import '../providers/auth_provider.dart';
import 'auth_page.dart';
import 'theme_settings_page.dart';
import 'trash_bin_page.dart';
import 'archive_page.dart';
import 'complete_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Watch auth state changes directly in the build method or via a consumer/stream builder wrapper
    // Here we use the provider for the current user instance
    final currentUser = context.watch<FirebaseAuthProvider>().currentUser;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          buildAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              // 1. Profil Düzenleme
              if (currentUser != null) ...[
                const SizedBox(height: 10),
                buildProfileTile(context),
              ] else ...[
                // Not logged in: Show Sign In Tile
                buildSignInTile(context),
              ],
              const Divider(),

              // 2. Tema Ayarı
              buildThemeTile(themeProvider),

              const Divider(),
              Consumer<SyncProvider>(
                builder: (context, provider, _) {
                  return buildSyncTile(currentUser, provider);
                },
              ),
              const Divider(),
              buildTrashBinTile(context),
              const Divider(),
              buildArchiveTile(context),

              // 3. Çıkış Yap Butonu (En altta)
              if (currentUser != null) ...[
                const Divider(),
                buildSignOutTile(context),
                const SizedBox(height: 20), // Bottom padding
              ],
            ]),
          ),
        ],
      ),
    );
  }

  SwitchListTile buildSyncTile(User? currentUser, SyncProvider provider) {
    return SwitchListTile(
      title: const Text("Senkronizasyon"),
      subtitle: Text(
        currentUser == null
            ? "Verilerin yedeklenmesi için giriş yapın"
            : provider.isSyncEnabled
            ? "Veriler Buluta Yedekleniyor"
            : "Sadece Cihazda (Offline)",
      ),
      secondary: Icon(
        provider.isSyncEnabled ? Icons.cloud_outlined : Icons.cloud_off,
      ),
      value: provider.isSyncEnabled,
      onChanged: currentUser != null
          ? (val) {
              provider.toggleSync(val);
            }
          : null,
    );
  }

  SliverAppBar buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 150,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text('Ayarlar'),
      ),
    );
  }

  // New method for Sign In tile
  Widget buildSignInTile(BuildContext context) {
    return ListTile(
      title: const Text('Giriş Yap / Kayıt Ol'),
      subtitle: const Text("Verilerinizi yedeklemek için giriş yapın"),
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
  }

  // New method for Sign Out tile
  Widget buildSignOutTile(BuildContext context) {
    return Center(
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.redAccent),
        title: const Text(
          'Çıkış Yap',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () async {
          // Confirm dialog could be added here
          await FirebaseAuth.instance.signOut();
          // UI updates automatically via StreamBuilder/Provider listeners usually,
          // but setState ensures this widget rebuilds if it relies on local state.
          if (mounted) setState(() {});
        },
      ),
    );
  }

  Widget buildThemeTile(ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text('Tema Ayarları'),
      subtitle: const Text('Renk teması ve karanlık mod'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (builder) => const ThemeSettingsPage()),
        );
      },
    );
  }

  Widget buildProfileTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person_pin_circle_outlined),
      title: const Text('Profil Bilgilerim'),
      subtitle: const Text('Ad, soyad ve işletme bilgilerini düzenle'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (builder) => const CompleteProfilePage(isEditMode: true),
          ),
        );
      },
    );
  }

  Widget buildTrashBinTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_outline),
      title: const Text("Çöp Kutusu"),
      subtitle: const Text("Silinen müşterileri yönet"),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (builder) => const TrashBinPage()),
        );
      },
    );
  }

  Widget buildArchiveTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.archive_outlined),
      title: const Text("Arşiv Kutusu"),
      subtitle: const Text("Arşivlenen müşterileri yönet"),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (builder) => const ArchivePage()),
        );
      },
    );
  }
}
