import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiNetworkException implements Exception {
  const ApiNetworkException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

class ApiClient {
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client = http.Client();
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) => _enviar(
        () => _client.get(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _headers,
        ),
      );

  Future<dynamic> post(String path, {Object? body}) => _enviar(
        () => _client.post(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _headers,
          body: body,
        ),
      );

  Future<dynamic> put(String path, {Object? body}) => _enviar(
        () => _client.put(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _headers,
          body: body,
        ),
      );

  Future<dynamic> delete(String path) => _enviar(
        () => _client.delete(
          Uri.parse('${ApiConstants.baseUrl}$path'),
          headers: _headers,
        ),
      );

  Future<dynamic> _enviar(Future<http.Response> Function() peticion) async {
    try {
      return _handle(await peticion().timeout(_timeout));
    } on TimeoutException {
      throw const ApiNetworkException(
        'El servidor tardó demasiado en responder. Revisá tu conexión e intentá de nuevo.',
      );
    } on http.ClientException {
      throw const ApiNetworkException(
        'No hay conexión a internet. Revisá tu conexión e intentá de nuevo.',
      );
    }
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