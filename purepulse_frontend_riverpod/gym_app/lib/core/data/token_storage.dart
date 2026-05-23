// Package imports:
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyToken = 'purepulse_auth_token';
  static const String _keyUser = 'purepulse_user_session';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  Future<void> saveUserSession(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, json.encode(userJson));
  }

  Future<Map<String, dynamic>?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyUser);
    if (jsonStr == null) return null;
    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}
