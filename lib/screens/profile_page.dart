import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/providers/theme_provider.dart';

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
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
