import 'package:flutter/material.dart';
import 'package:lotto_app/pages/login.dart';
import 'package:lotto_app/pages/home.dart';
import 'package:lotto_app/pages/adminpages/admin1.dart';
import 'package:lotto_app/pages/reg.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String admin = '/admin';
  static const String register = '/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const loginPage(),
          settings: settings,
        );
      case home:
        final token = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => HomePage(token: token),
          settings: settings,
        );
      case admin:
        final token = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => Admin1(token: token),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const loginPage(),
          settings: settings,
        );
    }
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      login,
      (route) => false,
    );
  }

  static void navigateToHome(BuildContext context, String token) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      home,
      (route) => false,
      arguments: token,
    );
  }

  static void navigateToAdmin(BuildContext context, String token) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      admin,
      (route) => false,
      arguments: token,
    );
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }
}
