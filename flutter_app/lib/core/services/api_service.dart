import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  Future<Map<String, dynamic>> requestEmailOtp({
    required String email,
    String purpose = 'signup',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/email-otp/request'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'purpose': purpose}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String code,
    String purpose = 'signup',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/email-otp/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'purpose': purpose,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> scanEmail(String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/scan/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': content}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> scanUrl(String url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/scan/url'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'url': url}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> checkBreach(String identifier) async {
    final response = await http.post(
      Uri.parse('$baseUrl/breach/check'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getCyberScore() async {
    final response = await http.post(
      Uri.parse('$baseUrl/score'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'password_strength': 90,
        'training_completion': 72,
        'breach_count': 1,
        'risky_clicks': 0,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getAdminMetrics() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/metrics'));
    return jsonDecode(response.body);
  }

  Future<List<Map<String, dynamic>>> getAdminUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/users'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final users = (data['users'] ?? []) as List<dynamic>;
    return users
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
