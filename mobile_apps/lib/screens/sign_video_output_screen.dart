import 'package:flutter/material.dart';

import '../services/sign_video_service.dart';
import '../widgets/sign_video_player.dart';

class SignVideoOutputScreen extends StatelessWidget {
  const SignVideoOutputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = (ModalRoute.of(context)?.settings.arguments as String?) ?? '';

    final videoPath = SignVideoService().videoForWord(text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Output Video'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            if (videoPath != null)
              SignVideoPlayer(path: videoPath)
            else
              const Text('No sign video found for this word.'),
          ],
        ),
      ),
    );
  }
}
