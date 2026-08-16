class NlpService {
  List<String> toLetters(String text) {
    return text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '').split('');
  }
}
