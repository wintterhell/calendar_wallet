import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_snapshot.dart';
import 'seed.dart';

class LocalStore {
  LocalStore(this._prefs);

  static const _key = 'calendar_wallet_v1';
  final SharedPreferences _prefs;

  AppSnapshot load() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return const AppSnapshot(templates: defaultTemplates, days: {});
    }
    try {
      return AppSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSnapshot(templates: defaultTemplates, days: {});
    }
  }

  Future<void> save(AppSnapshot snapshot) {
    return _prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }
}
