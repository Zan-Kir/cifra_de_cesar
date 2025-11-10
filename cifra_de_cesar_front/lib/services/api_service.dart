import 'dart:async';
// dart:convert not needed in mock service
import 'dart:math';

import 'package:flutter/foundation.dart';
import '../utils/cesar.dart';

/// Serviço de API fictício (mock) para uso local.
/// Substitua as implementações por chamadas reais HTTP quando tiver o backend.
class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  // Controle interno para simular usuários/tokens e hashes armazenados
  final Map<String, Map<String, dynamic>> _sessions = {}; // token -> {username}
  final Map<String, Map<String, dynamic>> _hashStore = {}; // hash -> {ciphertext, shift, used}

  final Random _rnd = Random.secure();

  String _randomAlnum(int len) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()_+-=[]{}|;:,.<>?';
    final sb = StringBuffer();
    for (var i = 0; i < len; i++) {
      sb.write(chars[_rnd.nextInt(chars.length)]);
    }
    return sb.toString();
  }

  Future<String> login(String username, String password) async {
    // simula delay de rede
    await Future.delayed(const Duration(milliseconds: 400));
    // Em modo mock, aceitamos qualquer credencial e retornamos um token JWT falso
    final token = 'mock_${_randomAlnum(28)}';
    _sessions[token] = {'username': username, 'createdAt': DateTime.now().toIso8601String()};
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ApiService] login mock: token=$token');
    }
    return token;
  }

  Future<void> logout(String token) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _sessions.remove(token);
  }

  bool _validateToken(String? token) {
    if (token == null) return false;
    return _sessions.containsKey(token);
  }

  /// Simula o endpoint /encrypt: recebe texto e shift, retorna hash armazenado.
  Future<String> encrypt(String? token, String text, int shift) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_validateToken(token)) {
      throw Exception('Unauthorized');
    }
    final ciphertext = Cesar.encode(text, shift);
    // gerar hash seguro
    final hash = _randomAlnum(24);
    _hashStore[hash] = {
      'ciphertext': ciphertext,
      'shift': shift,
      'used': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ApiService] encrypt mock: hash=$hash ciphertext=$ciphertext shift=$shift');
    }
    return hash;
  }

  /// Simula o endpoint /decrypt: recebe hash, valida se existe e não foi usado, marca usado e retorna texto claro.
  /// Simula o endpoint /decrypt: recebe hash e opcionalmente a mensagem cifrada
  /// Se mensagem cifrada for fornecida, valida que bate com o armazenado.
  Future<String> decrypt(String? token, String hash, [String? ciphertextProvided]) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_validateToken(token)) {
      throw Exception('Unauthorized');
    }
    final entry = _hashStore[hash];
    if (entry == null) {
      throw Exception('Hash not found');
    }
    if (entry['used'] == true) {
      throw Exception('Hash already used');
    }
    final ciphertext = entry['ciphertext'] as String;
    final shift = entry['shift'] as int;
    // Se o usuário forneceu um ciphertext, valide se igual ao armazenado
    if (ciphertextProvided != null && ciphertextProvided != ciphertext) {
      throw Exception('Ciphertext does not match the stored value for this hash');
    }
    final plain = Cesar.decode(ciphertext, shift);
    // marca como usado
    entry['used'] = true;
    entry['usedAt'] = DateTime.now().toIso8601String();
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ApiService] decrypt mock: hash=$hash -> plain=$plain');
    }
    return plain;
  }
}
