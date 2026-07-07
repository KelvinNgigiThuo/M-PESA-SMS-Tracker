import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'screens/setup_screen.dart';
import 'screens/onboarding_screen.dart';

class DhahiriApp extends StatelessWidget {
  final Widget home;

  const DhahiriApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dhahiri',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A3C34)),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: home,
      routes: {
        '/dashboard': (_) => const MainShell(),
        '/setup': (_) => const SetupScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
      },
    );
  }
}