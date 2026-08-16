class HistoryItem {
  final String text;
  final String direction;
  final DateTime time;
  const HistoryItem(
      {required this.text, required this.direction, required this.time});

  Map<String, dynamic> toJson() =>
      {'text': text, 'direction': direction, 'time': time.toIso8601String()};
  factory HistoryItem.fromJson(Map<String, dynamic> j) => HistoryItem(
      text: j['text'],
      direction: j['direction'],
      time: DateTime.parse(j['time']));
}
