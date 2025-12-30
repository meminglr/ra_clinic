import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/sync_provider.dart';
import 'package:ra_clinic/providers/theme_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ra_clinic/providers/user_profile_provider.dart';
import 'package:ra_clinic/services/webdav_service.dart';

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
    final userProfileProvider = Provider.of<UserProfileProvider>(context);
    final profile = userProfileProvider.profile;
    final webDavService = Provider.of<WebDavService>(context, listen: false);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 250,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Theme.of(context).highlightColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        expandedTitleScale: 1.0,
        title: CollapseAwareTitle(title: profile?.businessName ?? 'Profil'),
        background: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      (profile != null && profile.photoUrl.isNotEmpty)
                      ? CachedNetworkImageProvider(
                          profile.photoUrl,
                          headers: webDavService.getAuthHeaders(),
                        )
                      : null,
                  child: (profile == null || profile.photoUrl.isEmpty)
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                profile != null
                    ? "${profile.firstName} ${profile.lastName}"
                    : "Misafir Kullanıcı",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              if (profile != null && profile.businessName.isNotEmpty)
                Text(
                  profile.businessName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              if (profile == null)
                Text(
                  "Giriş yapın",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
            ],
          ),
        ),
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
            MaterialPageRoute(builder: (builder) => const AuthPage()),
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
          if (context.mounted) {
            Provider.of<UserProfileProvider>(
              context,
              listen: false,
            ).clearProfile();
          }
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
          MaterialPageRoute(builder: (builder) => const ThemeSettingsPage()),
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
          MaterialPageRoute(
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
          MaterialPageRoute(builder: (builder) => const TrashBinPage()),
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
          MaterialPageRoute(builder: (builder) => const ArchivePage()),
        );
      },
    );
  }
}

class CollapseAwareTitle extends StatelessWidget {
  final String title;
  const CollapseAwareTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    if (settings == null) {
      return Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
      );
    }

    final deltaExtent = settings.maxExtent - settings.minExtent;
    final currentExtent = settings.currentExtent;
    // 0.0 = expanded, 1.0 = collapsed
    final t = (1.0 - (currentExtent - settings.minExtent) / deltaExtent).clamp(
      0.0,
      1.0,
    );

    // Fade in when almost collapsed
    double opacity = 0.0;
    if (t > 0.8) {
      opacity = ((t - 0.8) * 5.0).clamp(0.0, 1.0);
    }

    return Opacity(
      opacity: opacity,
      child: Text(
        title,
        style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
      ),
    );
  }
}
