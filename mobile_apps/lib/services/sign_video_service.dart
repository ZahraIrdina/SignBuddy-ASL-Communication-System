class SignVideoService {
  static const String videoFolder = 'assets/signs_videos';

  final Set<String> available = {
    'afraid',
    'afternoon',
    'agree',
    'angry',
    'answer',
    'ask',
    'bathroom',
    'bread',
    'breakfast',
    'brother',
    'camera',
    'can',
    'child',
    'close',
    'coffee',
    'come',
    'computer',
    'correct',
    'daughter',
    'dinner',
    'doctor',
    'drink',
    'eat',
    'email',
    'evening',
    'excited',
    'explain',
    'family',
    'father',
    'food',
    'friend',
    'go',
    'good',
    'goodbye',
    'happy',
    'hello',
    'home',
    'hospital',
    'how',
    'hungry',
    'husband',
    'i',
    'internet',
    'kitchen',
    'know',
    'later',
    'library',
    'like',
    'listen',
    'love',
    'lunch',
    'manager',
    'maybe',
    'me',
    'message',
    'month',
    'morning',
    'mother',
    'nice',
    'night',
    'no',
    'now',
    'nurse',
    'office',
    'open',
    'parents',
    'people',
    'phone',
    'please',
    'police',
    'read',
    'remember',
    'repeat',
    'restaurant',
    'room',
    'run',
    'sad',
    'school',
    'she',
    'shop',
    'show',
    'sister',
    'sit',
    'sleep',
    'son',
    'sorry',
    'speak',
    'stand',
    'start',
    'stop',
    'student',
    'study',
    'sure',
    'talk',
    'tea',
    'teacher',
    'tell',
    'them',
    'they',
    'thirsty',
    'tired',
    'today',
    'tomorrow',
    'understand',
    'university',
    'walk',
    'watch',
    'water',
    'we',
    'week',
    'welcome',
    'what',
    'when',
    'where',
    'which',
    'who',
    'why',
    'wife',
    'work',
    'write',
    'wrong',
    'year',
    'yes',
    'yesterday',
    'you',
  };

  String normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String? videoForWord(String word) {
    final key = normalize(word);

    if (available.contains(key)) {
      return '$videoFolder/$key.mp4';
    }

    return null;
  }

  List<String> wordsFromText(String text) {
    final normalized = normalize(text);

    if (normalized.isEmpty) {
      return [];
    }

    return normalized.split(' ');
  }
}
