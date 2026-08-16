import 'package:flutter/material.dart';

import '../services/text_to_speech_service.dart';

class DeafToHearingResultScreen extends StatelessWidget {
  const DeafToHearingResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final result =
        (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detection Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Detected Sign',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              result,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  TextToSpeechService().speak(result);
                },
                icon: const Icon(Icons.volume_up),
                label: const Text('Speak Result'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
