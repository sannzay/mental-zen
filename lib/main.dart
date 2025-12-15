import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/insights_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'services/auth_service.dart';
import 'services/cache_service.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  final prefs = await SharedPreferences.getInstance();
  final cache = CacheService(prefs);
  runApp(MyApp(cache: cache));
}

class MyApp extends StatelessWidget {
  final CacheService cache;

  const MyApp({super.key, required this.cache});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
          ),
        ),
        Provider<CacheService>.value(value: cache),
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(context.read<CacheService>()),
        ),
        ChangeNotifierProxyProvider2<AuthProvider, FirestoreService, MoodProvider>(
          create: (context) => MoodProvider(context.read<FirestoreService>()),
          update: (context, auth, firestore, mood) {
            mood ??= MoodProvider(firestore);
            mood.setUser(auth.user?.uid);
            return mood;
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, FirestoreService, JournalProvider>(
          create: (context) => JournalProvider(context.read<FirestoreService>()),
          update: (context, auth, firestore, journal) {
            journal ??= JournalProvider(firestore);
            journal.setUser(auth.user?.uid);
            return journal;
          },
        ),
        ChangeNotifierProxyProvider2<AuthProvider, FirestoreService, ReminderProvider>(
          create: (context) => ReminderProvider(context.read<FirestoreService>()),
          update: (context, auth, firestore, reminder) {
            reminder ??= ReminderProvider(firestore);
            reminder.setUser(auth.user?.uid);
            return reminder;
          },
        ),
        ChangeNotifierProxyProvider2<MoodProvider, JournalProvider, InsightsProvider>(
          create: (context) => InsightsProvider(
            moodProvider: context.read<MoodProvider>(),
            journalProvider: context.read<JournalProvider>(),
          ),
          update: (context, mood, journal, insights) {
            insights ??= InsightsProvider(
              moodProvider: mood,
              journalProvider: journal,
            );
            return insights;
          },
        ),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, theme, _) {
          final isAuthed = auth.user != null;
          return MaterialApp(
            title: 'Mental Zen',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: ThemeData.dark(),
            themeMode: theme.themeMode,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            home: isAuthed ? const MainNavigation() : const LoginScreen(),
          );
        },
      ),
    );
  }
}


