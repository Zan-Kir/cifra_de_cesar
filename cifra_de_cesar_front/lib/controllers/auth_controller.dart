import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthController with ChangeNotifier {
  bool _loggedIn = false;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token_mock';

  bool get isLoggedIn => _loggedIn;

  /// Faz login utilizando o ApiService (mock). Armazena token no storage seguro.
  Future<bool> login(String username, String password) async {
    try {
      final token = await ApiService.instance.login(username, password);
      await _storage.write(key: _tokenKey, value: token);
      _loggedIn = true;
      notifyListeners();
      return true;
    } catch (_) {
      _loggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      await ApiService.instance.logout(token);
    }
    await _storage.delete(key: _tokenKey);
    _loggedIn = false;
    notifyListeners();
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }
}
