import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/catalog_api.dart';

class AuthController extends ChangeNotifier {
  AuthController({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const _accessTokenKey = 'sonicflow.auth.accessToken';
  static const _userKey = 'sonicflow.auth.user';

  final http.Client _client;
  final bool _ownsClient;

  String? _accessToken;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _accessToken != null && _user != null;
  String? get accessToken => _accessToken;
  Map<String, dynamic>? get user => _user;
  String? get userStorageScope {
    if (!isAuthenticated) return null;
    final id = _user?['id']?.toString().trim();
    if (id != null && id.isNotEmpty) return id;
    final email = _user?['email']?.toString().trim().toLowerCase();
    return email == null || email.isEmpty ? null : email;
  }

  Future<void> hydrate() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedUser = preferences.getString(_userKey);
    final accessToken = preferences.getString(_accessTokenKey);
    if (encodedUser == null || accessToken == null) return;

    _user = jsonDecode(encodedUser) as Map<String, dynamic>;
    _accessToken = accessToken;
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _authenticate('login', {
      'email': email.trim(),
      'password': password,
    });
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _authenticate('register', {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    });
  }

  Future<void> _authenticate(
    String endpoint,
    Map<String, String> credentials,
  ) async {
    final response = await _client
        .post(
          Uri.parse('$apiBaseUrl/auth/$endpoint'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(credentials),
        )
        .timeout(const Duration(seconds: 15));

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        payload['success'] != true) {
      throw AuthException(
        payload['message'] as String? ?? 'Authentication failed.',
      );
    }

    final data = payload['data'] as Map<String, dynamic>;
    final accessToken = data['access_token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    if (accessToken == null || user == null) {
      throw const FormatException(
        'The authentication response is missing its user or access token.',
      );
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, accessToken);
    await preferences.setString(_userKey, jsonEncode(user));
    _accessToken = accessToken;
    _user = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_userKey);
    _accessToken = null;
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    if (_ownsClient) _client.close();
    super.dispose();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
