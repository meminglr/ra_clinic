import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:ra_clinic/calendar/model/schedule.dart';
import 'package:ra_clinic/firebase_options.dart';
import 'package:ra_clinic/home.dart';
import 'package:ra_clinic/model/costumer_model.dart';
import 'package:ra_clinic/providers/customer_provider.dart';
import 'package:ra_clinic/providers/event_provider.dart';
import 'package:ra_clinic/theme/app_themes.dart';
import 'model/media_model.dart';
import 'model/seans_model.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_profile_provider.dart';
import 'services/webdav_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(SeansModelAdapter());
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(CostumerMediaAdapter());
  await Hive.openBox<CustomerModel>("customersBox");
  await Hive.openBox<Schedule>("scheduleBox");
  await Hive.openBox('settingsBox');
  await initializeDateFormatting('tr_TR', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        Provider<WebDavService>(create: (_) => WebDavService()..init()),
        ChangeNotifierProxyProvider<WebDavService, UserProfileProvider>(
          create: (context) => UserProfileProvider(
            Provider.of<WebDavService>(context, listen: false),
          ),
          update: (context, webDav, previous) =>
              previous ?? UserProfileProvider(webDav),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      locale: const Locale('tr', 'TR'), // 🌍 Türkçe dil ayarı
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SfGlobalLocalizations.delegate,
      ],

      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(themeProvider.scheme),
      darkTheme: AppTheme.dark(themeProvider.scheme),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}
