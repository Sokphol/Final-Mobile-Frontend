import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  const LocalStorageService();

  Future<Object?> readJson(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(key);
    return value == null ? null : jsonDecode(value);
  }

  Future<void> writeJson(String key, Object value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, jsonEncode(value));
  }
}
