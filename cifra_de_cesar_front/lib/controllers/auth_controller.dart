import 'package:flutter/material.dart';

class AuthController with ChangeNotifier {
  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;

  // Para agora, permite qualquer credencial e retorna true
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _loggedIn = true;
    notifyListeners();
    return _loggedIn;
  }

  void logout() {
    _loggedIn = false;
    notifyListeners();
  }
}
