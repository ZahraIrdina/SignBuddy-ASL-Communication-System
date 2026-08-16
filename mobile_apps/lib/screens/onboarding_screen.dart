import 'package:flutter/material.dart';

import '../utils/app_routes.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/icons/app_icon.png',
                height: 180,
              ),
              const SizedBox(height: 30),
              const Text(
                'Break Barriers,\nConnect Hearts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'A Smart Two-Way Communication System Between Deaf-Mute and Hearing People.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Continue',
                icon: Icons.arrow_forward,
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.home,
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
