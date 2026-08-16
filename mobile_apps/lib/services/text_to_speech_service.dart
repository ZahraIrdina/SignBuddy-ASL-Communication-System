import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _tts = FlutterTts();

  Future<void> setLanguage(String languageCode) async {
    await _tts.setLanguage(languageCode);
  }

  Future<void> speak(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
