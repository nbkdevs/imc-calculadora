import 'dart:convert';

import 'package:imc_calculadora/domain/models/history_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryRepository {
  HistoryRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'imc_history_v1';

  List<HistoryEntry> load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(HistoryEntry entry) async {
    final items = load();
    items.insert(0, entry);
    if (items.length > 100) {
      items.removeRange(100, items.length);
    }
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
