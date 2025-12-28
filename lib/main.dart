import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_provider.dart';
import 'features/coins/data/coins_provider.dart';
import 'features/home/data/surveys_provider.dart';
import 'features/leaderboard/data/leaderboard_provider.dart';
import 'features/profile/data/profile_provider.dart';
import 'features/redemption/data/redemption_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await StorageService.init();

  // Initialize notifications
  await NotificationService.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PaidSurveysApp());
}

class PaidSurveysApp extends StatefulWidget {
  const PaidSurveysApp({super.key});

  @override
  State<PaidSurveysApp> createState() => _PaidSurveysAppState();
}

class _PaidSurveysAppState extends State<PaidSurveysApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  void _toggleTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final savedTheme = await StorageService.getThemeMode();
    final savedLocale = await StorageService.getLocale();
    setState(() {
      _themeMode = savedTheme;
      _locale = savedLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CoinsProvider()),
        ChangeNotifierProvider(create: (_) => SurveysProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => RedemptionProvider()),
        Provider.value(value: _toggleTheme),
        Provider.value(value: _setLocale),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
