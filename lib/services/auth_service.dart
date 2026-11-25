import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class AuthService {
  static const _sessionKey = 'azienda_loggata';
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  // R1 - Registrazione nuova azienda
  Future<void> registraAzienda({
    required String nomeAzienda,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'nomeAzienda': nomeAzienda,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['errore'] ?? 'Errore durante la registrazione');
    }
  }

  // R2 - Login azienda e salvataggio sessione sul telefono
  Future<Azienda> loginAzienda({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['errore'] ?? 'Email o password non corretti');
    }

    final azienda = Azienda.fromJson(jsonDecode(response.body));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(azienda.toJson()));
    return azienda;
  }

  // Recupera l'azienda eventualmente già loggata
  Future<Azienda?> getAziendaLoggata() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    return Azienda.fromJson(jsonDecode(raw));
  }

  // R3 - Logout azienda
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}