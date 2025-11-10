import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/cesar.dart';
import '../services/api_service.dart';

class CesarController with ChangeNotifier {
  String _input = '';
  int _shift = 3;
  String _result = '';
  String? _lastHash;
  final _storage = const FlutterSecureStorage();

  String get input => _input;
  int get shift => _shift;
  String get result => _result;
  String? get lastHash => _lastHash;

  void setInput(String v) {
    _input = v;
    notifyListeners();
  }

  void setShift(int v) {
    _shift = v;
    notifyListeners();
  }

  /// Local encrypt (sem backend) — mantém compatibilidade
  void encrypt() {
    _result = Cesar.encode(_input, _shift);
    notifyListeners();
  }

  /// Local decrypt (sem backend)
  void decrypt() {
    _result = Cesar.decode(_input, _shift);
    notifyListeners();
  }

  /// Encrypt via API (mock). Retorna e salva o hash gerado pelo servidor mock.
  Future<void> encryptRemote() async {
    final token = await _storage.read(key: AuthTokenKey);
    try {
      final hash = await ApiService.instance.encrypt(token, _input, _shift);
      _lastHash = hash;
      // Também armazenar o resultado localmente para mostrar
      _result = Cesar.encode(_input, _shift);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Decrypt via API (mock) usando hash.
  Future<void> decryptRemoteByHash(String hash, [String? ciphertext]) async {
    final token = await _storage.read(key: AuthTokenKey);
    try {
      final plain = await ApiService.instance.decrypt(token, hash, ciphertext);
      _result = plain;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clear() {
    _input = '';
    _result = '';
    _shift = 3;
    _lastHash = null;
    notifyListeners();
  }
}

// Chave usada internamente para ler token (mesma key do AuthController)
const String AuthTokenKey = 'jwt_token_mock';
