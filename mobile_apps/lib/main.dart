import 'package:flutter/material.dart';

import 'screens/alphabet_output_screen.dart';
import 'screens/deaf_to_hearing_result_screen.dart';
import 'screens/deaf_to_hearing_screen.dart';
import 'screens/hearing_to_deaf_result_screen.dart';
import 'screens/hearing_to_deaf_screen.dart';
import 'screens/sign_video_output_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/about_screen.dart';
import 'screens/quick_phrases_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/app_routes.dart';

void main() {
  runApp(const SignBuddyApp());
}

class SignBuddyApp extends StatelessWidget {
  const SignBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
      ),
      initialRoute: AppRoutes.hearingToDeaf,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.deafToHearing: (_) => const DeafToHearingScreen(),
        AppRoutes.hearingToDeaf: (_) => const HearingToDeafScreen(),
        AppRoutes.deafResult: (_) => const DeafToHearingResultScreen(),
        AppRoutes.hearingResult: (_) => const HearingToDeafResultScreen(),
        AppRoutes.signVideoOutput: (_) => const SignVideoOutputScreen(),
        AppRoutes.alphabetOutput: (_) => const AlphabetOutputScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.phrases: (_) => const QuickPhrasesScreen(),
        AppRoutes.alphabet: (_) => const AlphabetOutputScreen(),
        AppRoutes.history: (_) => const HistoryScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
