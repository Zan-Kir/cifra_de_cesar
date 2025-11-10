import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Serviço de API para comunicação com o backend
class ApiService {
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  // URL base do backend - ajuste conforme necessário
  static const String baseUrl = 'http://192.168.0.244:4000';

  /// Registra um novo usuário
  Future<void> register(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro ao registrar');
    }
  }

  /// Faz login e retorna o token JWT
  Future<String> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro ao fazer login');
    }

    final data = jsonDecode(response.body);
    return data['token'] as String;
  }

  Future<void> logout(String token) async {
    // Logout é apenas local, removendo o token do storage
    if (kDebugMode) {
      print('[ApiService] logout: token removido localmente');
    }
  }

  /// Criptografa um texto e retorna o hash
  Future<String> encrypt(String? token, String text, int shift) async {
    if (token == null) throw Exception('Token não fornecido');

    final url = Uri.parse('$baseUrl/hash/encrypt');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'plaintext': text,
        'shift': shift,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro ao criptografar');
    }

    final data = jsonDecode(response.body);
    if (kDebugMode) {
      print('[ApiService] encrypt: hash=${data['hash']}');
    }
    return data['hash'] as String;
  }

  /// Descriptografa usando um hash
  Future<String> decrypt(String? token, String hash, [String? ciphertextProvided]) async {
    if (token == null) throw Exception('Token não fornecido');

    final url = Uri.parse('$baseUrl/hash/decrypt');
    final body = <String, dynamic>{
      'hash': hash,
    };
    if (ciphertextProvided != null) {
      body['ciphertext'] = ciphertextProvided;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Erro ao descriptografar');
    }

    final data = jsonDecode(response.body);
    if (kDebugMode) {
      print('[ApiService] decrypt: plaintext=${data['plaintext']}');
    }
    return data['plaintext'] as String;
  }
}
