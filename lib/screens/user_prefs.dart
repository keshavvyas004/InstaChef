import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static Future<void> saveUser({
    required String name,
    required String dob,
    required String phone,
    required String email,
    required String password,
    required String username,
    String? profileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('dob', dob);
    await prefs.setString('phone', phone);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    await prefs.setString('username', username);
    if (profileImagePath != null) {
      await prefs.setString('profileImage', profileImagePath);
    }
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'dob': prefs.getString('dob'),
      'phone': prefs.getString('phone'),
      'email': prefs.getString('email'),
      'password': prefs.getString('password'),
      'username': prefs.getString('username'),
      'profileImage': prefs.getString('profileImage'),
    };
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
