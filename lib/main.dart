import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/home.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CostumerProvider())],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('tr', 'TR'), // 🌍 Türkçe dil ayarı
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
