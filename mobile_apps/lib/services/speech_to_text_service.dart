import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<String> listen() async {
    final available = await _speech.initialize();

    if (!available) {
      return '';
    }

    String resultText = '';

    await _speech.listen(
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        resultText = result.recognizedWords;
      },
    );

    await Future.delayed(const Duration(seconds: 6));
    await _speech.stop();

    return resultText;
  }
}
