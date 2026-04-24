import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../api/auth_api.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('cronos_token');
    final userJson = prefs.getString('cronos_user');
    if (userJson != null && _token != null) {
      _user = User.fromJson(jsonDecode(userJson));
      _isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<void> setAuth(User user, String token) async {
    _user = user;
    _token = token;
    _isAuthenticated = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cronos_token', token);
    await prefs.setString('cronos_user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cronos_token');
    await prefs.remove('cronos_user');
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await AuthApi.login({'email': email, 'password': password});
    final data = res.data['data'];
    final user = User.fromJson(data['user']);
    final token = data['token'] as String;
    await setAuth(user, token);
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> form) async {
    final res = await AuthApi.register(form);
    final data = res.data['data'];
    final user = User.fromJson(data['user']);
    final token = data['token'] as String;
    await setAuth(user, token);
    return data;
  }

  String get dashboardRoute {
    if (_user == null) return '/login';
    return _user!.role == 'admin' ? '/admin' : '/${_user!.role}';
  }
}
