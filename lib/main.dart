import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:money_milestone/app/routes.dart';
import 'package:money_milestone/utils/notificationService.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz_zone;
import 'package:money_milestone/cubits/currencyCubit.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/firebase_options.dart';
import 'package:money_milestone/utils/adService.dart';
import 'package:money_milestone/utils/supabaseConfig.dart';
import 'package:money_milestone/utils/analyticsService.dart';
import 'package:money_milestone/utils/sessionTracker.dart';
import 'package:money_milestone/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_milestone/cubits/themeCubit.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //initialize firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  //initialize supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
  );

  //initialize Hive
  Hive.init((await getApplicationDocumentsDirectory()).path);
  await HiveRepository.init();

  // Initialize timezone for scheduled notifications
  tz.initializeTimeZones();
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz_zone.setLocalLocation(tz_zone.getLocation(timeZoneName));

  // Initialize notification service
  await NotificationService.instance.init();

  // Initialize AdMob and pre-load interstitial ad
  await MobileAds.instance.initialize();
  AdService.instance.initialize();

  // Register session tracker (listens for background resumes)
  SessionTracker.instance.init();

  runApp(
    ClarityWidget(
      app: const MyApp(),
      clarityConfig: ClarityConfig(
        projectId: 'xlbgbpk1mh',
        logLevel: LogLevel.None,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
            create: (_) => CurrencyCubit(UserRepository())
              ..loadCurrency()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final isDarkMode = context.read<ThemeCubit>().isDarkMode;

          // Shared text theme using DM Sans — premium financial-app feel
          final lightText = GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme);
          final darkText = GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme);

          const seedColor = Color(0xff6C47FF); // electric indigo

          return MaterialApp(
            title: Constant.appName,
            onGenerateRoute: Routes.onGeneratedRoute,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // ── Firebase Analytics: auto-tracks screen views ──────────────
            navigatorObservers: [AnalyticsService.observer],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.light,
                primary: seedColor,
                secondary: const Color(0xffF5A623),
                surface: const Color(0xffF0F2FF),
              ),
              textTheme: lightText,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xffF0F2FF),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleTextStyle: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff0D0F1E),
                ),
                iconTheme: const IconThemeData(color: Color(0xff0D0F1E)),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: seedColor,
                brightness: Brightness.dark,
                primary: seedColor,
                secondary: const Color(0xffF5A623),
                surface: const Color(0xff0B0F1A),
              ),
              textTheme: darkText,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xff0B0F1A),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                titleTextStyle: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xffF1F3FF),
                ),
                iconTheme: const IconThemeData(color: Color(0xffF1F3FF)),
              ),
            ),
            debugShowCheckedModeBanner: false,
            builder: (final context, final widget) => widget!,
          );
        },
      ),
    );
  }
}



