import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/app_icon.png', height: 150),
                    const SizedBox(height: 20),
                    const Text('SignBuddy',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.teal)),
                    const Text('Version 1.0.0'),
                    const SizedBox(height: 20),
                    const Text(
                        'A smart two-way communication system that breaks the barrier between deaf-mute and hearing people.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    const Text('Made with ❤️ for everyone')
                  ]))));
}
