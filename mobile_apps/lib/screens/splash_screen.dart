import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.tealDark, AppColors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/app_icon.png', height: 140),
              const SizedBox(height: 20),
              const Text(
                'SignBuddy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Smart Two-Way Communication\nFor Everyone',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
