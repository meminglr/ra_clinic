import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/home.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/costumer_provider.dart';

import 'model/seans_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CostumerModelAdapter());
  Hive.registerAdapter(SeansModelAdapter());
  await Hive.openBox<CostumerModel>("costumersBox");
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
