import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // listen: true kullanılması, sayfa açıkken tema değişikliklerini anlık yansıtmak içindir
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return ListTile(
                  title: const Text('Giriş Yap / Kayıt Ol'),
                  subtitle: const Text(
                    "Supabase ile kimlik doğrulama işlemleri",
                  ),

                  trailing: FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (builder) => const AuthPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Giriş Yap'),
                  ),
                );
              } else {
                return FilledButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Çıkış Yap'),
                );
              }
            },
          ),

          const SizedBox(height: 10),
          ListTile(
            title: const Text('Karanlık Mod'),
            subtitle: const Text(
              'Uygulamanın temasını karanlık/aydınlık olarak ayarla',
            ),
            trailing: Switch(
              value: themeProvider.isDark,
              onChanged: (v) => themeProvider.setDark(v),
            ),
          ),
        ],
      ),
    );
  }
}
