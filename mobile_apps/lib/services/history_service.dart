import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const _key = 'history';
  Future<List<HistoryItem>> getHistory() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_key) ?? []).map((e) => HistoryItem.fromJson(jsonDecode(e))).toList();
  }
  Future<void> add(HistoryItem item) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_key) ?? [];
    list.insert(0, jsonEncode(item.toJson()));
    await p.setStringList(_key, list.take(50).toList());
  }
  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_key);
}
