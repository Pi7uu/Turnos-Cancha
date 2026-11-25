/// Cliente HTTP de la API REST ( RD `docs/HistRequerimientos/api-auth.md` ).
///
/// Sesión por cookie `sessionid` ( Django ): el cliente la guarda del header
/// `set-cookie` y la manda en los siguientes requests. En la web la cookie la
/// maneja el navegador ( `set-cookie` no llega a Dart ) — documentado en el
/// spec. Los errores se traducen a [ApiException] con el mensaje en español
/// del servidor ( o `No se pudo conectar. Intentá de nuevo.` ante errores de
/// red ).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Error de la API con mensaje listo para mostrar ( siempre en español ).
class ApiException implements Exception {
  ApiException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Usuario devuelto por los endpoints de auth ( jamás incluye contraseña ).
class UsuarioApi {
  const UsuarioApi({required this.id, required this.email, required this.nombre});

  factory UsuarioApi.fromJson(Map<String, dynamic> json) {
    return UsuarioApi(
      id: json['id'] as int,
      email: json['email'] as String,
      nombre: (json['nombre'] as String?) ?? '',
    );
  }

  final int id;
  final String email;
  final String nombre;
}

class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? defaultBaseUrl;

  /// Default: emulador Android apunta a `10.0.2.2`; web/desktop a localhost.
  static String get defaultBaseUrl =>
      kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';

  final String baseUrl;
  final http.Client _client;

  /// Cookie de sesión ( `sessionid=...` ) para los requests siguientes.
  String? _cookie;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Cookie': ?_cookie,
      };

  Future<UsuarioApi> login(String email, String password) {
    return _auth('login/', {'email': email, 'password': password});
  }

  Future<UsuarioApi> registro(String email, String password, {String? nombre}) {
    return _auth('registro/', {
      'email': email,
      'password': password,
      if (nombre != null && nombre.isNotEmpty) 'nombre': nombre,
    });
  }

  Future<void> logout() async {
    await _post('logout/', {});
  }

  Future<UsuarioApi> perfil() async {
    final json = await _get('perfil/');
    return UsuarioApi.fromJson(json);
  }

  Future<UsuarioApi> _auth(String path, Map<String, dynamic> body) async {
    final json = await _post(path, body);
    return UsuarioApi.fromJson(json);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/api/auth/$path');
    try {
      final r = await _client.post(url, headers: _headers, body: jsonEncode(body));
      _guardarCookie(r);
      return _procesar(r);
    } on SocketException {
      throw ApiException('No se pudo conectar. Intentá de nuevo.');
    } on http.ClientException {
      throw ApiException('No se pudo conectar. Intentá de nuevo.');
    }
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final url = Uri.parse('$baseUrl/api/auth/$path');
    try {
      final r = await _client.get(url, headers: _headers);
      _guardarCookie(r);
      return _procesar(r);
    } on SocketException {
      throw ApiException('No se pudo conectar. Intentá de nuevo.');
    } on http.ClientException {
      throw ApiException('No se pudo conectar. Intentá de nuevo.');
    }
  }

  void _guardarCookie(http.Response r) {
    final setCookie = r.headers['set-cookie'];
    if (setCookie == null) return;
    final match = RegExp(r'sessionid=([^;]+)').firstMatch(setCookie);
    if (match != null) {
      _cookie = 'sessionid=${match.group(1)}';
    }
  }

  Map<String, dynamic> _procesar(http.Response r) {
    final cuerpo = r.body.isEmpty ? <String, dynamic>{} : jsonDecode(r.body);
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return cuerpo is Map<String, dynamic> ? cuerpo : <String, dynamic>{};
    }
    final error = (cuerpo is Map<String, dynamic> ? cuerpo['error'] : null)
        as String?;
    throw ApiException(error ?? 'Ocurrió un error. Intentá de nuevo.');
  }
}
