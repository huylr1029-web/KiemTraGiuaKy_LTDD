import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config_url.dart';
/// Tuan 7 - Buoc 5, SUA LOI: ban goc khong gan Authorization header
/// nen API co [Authorize] luon tra 401. Ban nay tu gan Bearer token.
class ApiClient {
  String get baseUrl => ConfigUrl.baseUrl;
  Future<Map<String, String>> _headers([Map<String, String>? extra]) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token', ...?extra};
  }
  Future<http.Response> get(String endpoint) async => http.get(Uri.parse('$baseUrl$endpoint'), headers: await _headers());
  Future<http.Response> post(String endpoint, {dynamic body}) async => http.post(Uri.parse('$baseUrl$endpoint'), headers: await _headers(), body: jsonEncode(body));
  Future<http.Response> put(String endpoint, {dynamic body}) async => http.put(Uri.parse('$baseUrl$endpoint'), headers: await _headers(), body: jsonEncode(body));
  Future<http.Response> delete(String endpoint) async => http.delete(Uri.parse('$baseUrl$endpoint'), headers: await _headers());
}
