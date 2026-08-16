import 'package:translator/translator.dart';

class TranslationService {
  final translator = GoogleTranslator();

  Future<String> translateText(String text, String targetLanguage) async {
    if (targetLanguage == "en") {
      return text;
    }

    final translation = await translator.translate(
      text,
      from: 'en',
      to: targetLanguage,
    );

    return translation.text;
  }

  Future<String> translateToEnglish(String text, String sourceLanguage) async {
    if (sourceLanguage == "en") {
      return text;
    }

    final translation = await translator.translate(
      text,
      from: sourceLanguage,
      to: 'en',
    );

    return translation.text;
  }
}
