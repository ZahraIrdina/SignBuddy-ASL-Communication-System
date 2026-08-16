import 'package:flutter/material.dart';

import '../services/speech_to_text_service.dart';
import '../utils/app_routes.dart';
import '../widgets/custom_button.dart';
import '../widgets/mic_button.dart';

class HearingToDeafScreen extends StatefulWidget {
  const HearingToDeafScreen({super.key});

  @override
  State<HearingToDeafScreen> createState() => _HearingToDeafScreenState();
}

class _HearingToDeafScreenState extends State<HearingToDeafScreen> {
  final TextEditingController _textController = TextEditingController();
  final SpeechToTextService _speechService = SpeechToTextService();

  bool _isListening = false;

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    final result = await _speechService.listen();

    setState(() {
      _isListening = false;
    });

    if (result.trim().isNotEmpty) {
      _textController.text = result.toUpperCase();
    } else {
      _showMessage(
          'No speech detected. Please try again or type your message.');
    }
  }

  void _showSign() {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      _showMessage('Please speak or type a message first.');
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.hearingResult,
      arguments: text.toUpperCase(),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hearing → Deaf-Mute'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MicButton(
              listening: _isListening,
              onTap: _isListening ? () {} : _startListening,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Or type your message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Show Sign',
              icon: Icons.back_hand,
              onTap: _showSign,
            ),
          ],
        ),
      ),
    );
  }
}
