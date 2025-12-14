import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Requested schemes
    final List<FlexScheme> schemes = [
      FlexScheme.shadBlue,
      FlexScheme.shadGreen,
      FlexScheme.shadOrange,
      FlexScheme.shadRed,
      FlexScheme.shadViolet,
      FlexScheme.shadYellow,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tema Ayarları')),
      body: ListView(
        children: [
          // Dark Mode Toggle
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            subtitle: const Text(
              'Uygulamanın temasını karanlık/aydınlık olarak ayarla',
            ),
            secondary: Icon(
              themeProvider.isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
            ),
            value: themeProvider.isDark,
            onChanged: (v) => themeProvider.setDark(v),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tema Rengi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // Scheme Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: schemes.map((scheme) {
                final bool isSelected = themeProvider.scheme == scheme;
                // Get the primary color of the scheme to show as a preview bubble
                // We can use FlexColor.schemes[scheme] to fetch colors but that map might be huge.
                // Alternatively, we can use a small colored container.
                // FlexColor.schemes[scheme]!.light.primary is reliable.
                final Color primaryColor =
                    FlexColor.schemes[scheme]!.light.primary;

                return GestureDetector(
                  onTap: () {
                    themeProvider.setScheme(scheme);
                  },
                  child: Column(
                    spacing: 4,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                      Text(
                        scheme.name.replaceFirst(
                          'shad',
                          '',
                        ), // Simple display name cleanup
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
