import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Single JSON blob persistence — simple and sufficient for a single-device,
/// no-backend app with a modest amount of data. [AppState] owns the actual
/// shape of the JSON; this class only knows how to get bytes in and out of
/// disk.
class LocalStore {
  LocalStore._();
  static const _key = 'cepte_staj_state_v1';

  static Future<void> save(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(json));
  }

  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
