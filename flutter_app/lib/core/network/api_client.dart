import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiClient {
  final http.Client _client = http.Client();
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) async {
    final res = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: _headers,
    );
    return _handle(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: _headers,
      body: body,
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await _client.put(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: _headers,
      body: body,
    );
    return _handle(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: _headers,
    );
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 400) {
      final message = decoded is Map ? decoded['message'] : 'Error';
      throw Exception(message);
    }
    return decoded;
  }

  void dispose() => _client.close();
}
