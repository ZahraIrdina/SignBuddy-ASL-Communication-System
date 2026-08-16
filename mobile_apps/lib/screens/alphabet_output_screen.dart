import 'package:flutter/material.dart';

import '../services/nlp_service.dart';
import '../widgets/alphabet_sign_list.dart';

class AlphabetOutputScreen extends StatelessWidget {
  const AlphabetOutputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

    final letters = NlpService().toLetters(text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet Output'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            const Text(
              'Output',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            AlphabetSignList(letters: letters),
          ],
        ),
      ),
    );
  }
}
