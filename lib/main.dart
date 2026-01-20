import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart';
import 'routes/app_router.dart';

// Initialize local notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Initialize notifications
  await _initializeNotifications();

  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings darwinInitializationSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInitializationSettings,
    iOS: darwinInitializationSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return MaterialApp.router(
            title: 'UniVibe',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(
                const TextTheme(
                  bodyLarge: TextStyle(color: Color(0xFF1F2937)),
                  bodyMedium: TextStyle(color: Color(0xFF374151)),
                  bodySmall: TextStyle(color: Color(0xFF6B7280)),
                  labelLarge: TextStyle(color: Color(0xFF1F2937)),
                  labelMedium: TextStyle(color: Color(0xFF374151)),
                  labelSmall: TextStyle(color: Color(0xFF6B7280)),
                  headlineLarge: TextStyle(color: Color(0xFF1F2937)),
                  headlineMedium: TextStyle(color: Color(0xFF1F2937)),
                  headlineSmall: TextStyle(color: Color(0xFF374151)),
                  titleLarge: TextStyle(color: Color(0xFF1F2937)),
                  titleMedium: TextStyle(color: Color(0xFF374151)),
                  titleSmall: TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              tabBarTheme: const TabBarThemeData(
                labelColor: Color(0xFF6366F1),
                unselectedLabelColor: Color(0xFF4B5563),
                indicatorColor: Color(0xFF6366F1),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.dark,
              ),
              textTheme: GoogleFonts.interTextTheme(
                const TextTheme(
                  bodyLarge: TextStyle(color: Color(0xFFF3F4F6)),
                  bodyMedium: TextStyle(color: Color(0xFFE5E7EB)),
                  bodySmall: TextStyle(color: Color(0xFFD1D5DB)),
                  labelLarge: TextStyle(color: Color(0xFFF3F4F6)),
                  labelMedium: TextStyle(color: Color(0xFFE5E7EB)),
                  labelSmall: TextStyle(color: Color(0xFFD1D5DB)),
                  headlineLarge: TextStyle(color: Color(0xFFF3F4F6)),
                  headlineMedium: TextStyle(color: Color(0xFFE5E7EB)),
                  headlineSmall: TextStyle(color: Color(0xFFE5E7EB)),
                  titleLarge: TextStyle(color: Color(0xFFF3F4F6)),
                  titleMedium: TextStyle(color: Color(0xFFE5E7EB)),
                  titleSmall: TextStyle(color: Color(0xFFD1D5DB)),
                ),
              ),
              appBarTheme: AppBarTheme(
                elevation: 0,
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                titleTextStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              tabBarTheme: const TabBarThemeData(
                labelColor: Color(0xFF6366F1),
                unselectedLabelColor: Color(0xFFD1D5DB),
                indicatorColor: Color(0xFF6366F1),
              ),
              scaffoldBackgroundColor: const Color(0xFF111827),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1F2937),
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color(0xFF1F2937),
              ),
            ),
            themeMode: settingsProvider.themeMode,
            routerDelegate: appRouter.routerDelegate,
            routeInformationParser: appRouter.routeInformationParser,
            routeInformationProvider: appRouter.routeInformationProvider,
          );
        },
      ),
    );
  }
}
