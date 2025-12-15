import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/journal/journal_screen.dart';
import '../screens/main_navigation.dart';
import '../screens/mood/mood_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String main = '/main';
  static const String home = '/home';
  static const String mood = '/mood';
  static const String journal = '/journal';
  static const String insights = '/insights';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        final auth = context.read<AuthProvider?>();
        final isAuthed = auth?.user != null;
        switch (settings.name) {
          case login:
            return const LoginScreen();
          case register:
            return const RegisterScreen();
          case forgotPassword:
            return const ForgotPasswordScreen();
          case main:
            return _authGuard(isAuthed, const MainNavigation());
          case home:
            return _authGuard(isAuthed, const HomeScreen());
          case mood:
            return _authGuard(isAuthed, const MoodScreen());
          case journal:
            return _authGuard(isAuthed, const JournalScreen());
          case insights:
            return _authGuard(isAuthed, const InsightsScreen());
          case settings:
            return _authGuard(isAuthed, const SettingsScreen());
          default:
            if (isAuthed) {
              return const MainNavigation();
            }
            return const LoginScreen();
        }
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (settings.name == login || settings.name == main) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        }
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  static Widget _authGuard(bool isAuthed, Widget child) {
    if (!isAuthed) {
      return const LoginScreen();
    }
    return child;
  }
}


