import 'package:flutter/material.dart';

import '../services/nlp_service.dart';
import '../services/sign_video_service.dart';
import '../widgets/alphabet_sign_list.dart';
import '../widgets/sign_video_player.dart';

class HearingToDeafResultScreen extends StatelessWidget {
  const HearingToDeafResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

    final signService = SignVideoService();
    final words = signService.wordsFromText(text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Output'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            const Text(
              'Input Text',
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
            const SizedBox(height: 22),
            if (words.isEmpty)
              const Text('No output available.')
            else
              ...words.map((word) {
                final videoPath = signService.videoForWord(word);

                if (videoPath != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SignVideoPlayer(path: videoPath),
                      ],
                    ),
                  );
                }

                final letters = NlpService().toLetters(word);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$word - Alphabet signs',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AlphabetSignList(letters: letters),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
