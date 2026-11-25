/// Mock del backend `/api/auth/` para los tests de widgets ( RD api-auth ).
///
/// Replica el comportamiento de la API real: normaliza el email ( trim +
/// minúsculas ), siembra el usuario `igpi7uu@gmail.com`/`igpi7uu`, devuelve
/// los mensajes en español y maneja la sesión con cookie.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:turnos_cancha/core/api/api_client.dart';

class UsuarioMock {
  UsuarioMock({required this.nombre, required this.password});

  String nombre;
  String password;
}

class ApiMock {
  ApiMock() {
    reiniciar();
  }

  /// Usuarios del mock por email normalizado ( para asserts de los tests ).
  final Map<String, UsuarioMock> usuarios = {};

  /// Email con sesión iniciada ( `null` sin sesión ).
  String? sesion;

  void reiniciar() {
    usuarios
      ..clear()
      ..['igpi7uu@gmail.com'] = UsuarioMock(nombre: 'Pitu', password: 'igpi7uu');
    sesion = null;
  }

  ApiClient client() => ApiClient(
        baseUrl: 'http://api.test',
        client: MockClient(_handler),
      );

  Future<http.Response> _handler(http.Request request) async {
    final path = request.url.path;
    final body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;
    final email = ((body['email'] ?? '') as String).trim().toLowerCase();
    final password = (body['password'] ?? '') as String;

    if (path.endsWith('login/')) {
      final u = usuarios[email];
      if (u == null || u.password != password) {
        return _json({'error': 'Email o contraseña incorrectos.'}, 401);
      }
      sesion = email;
      return _json(_usuario(email, u), 200, conSesion: true);
    }
    if (path.endsWith('registro/')) {
      if (usuarios.containsKey(email)) {
        return _json({'error': 'Ya existe una cuenta con ese email.'}, 400);
      }
      final nombre =
          ((body['nombre'] ?? '') as String).trim().isEmpty ? email.split('@').first : ((body['nombre'] ?? '') as String).trim();
      usuarios[email] = UsuarioMock(nombre: nombre, password: password);
      sesion = email;
      return _json(_usuario(email, usuarios[email]!), 201, conSesion: true);
    }
    if (path.endsWith('logout/')) {
      sesion = null;
      return http.Response('', 204);
    }
    if (path.endsWith('perfil/')) {
      final u = sesion == null ? null : usuarios[sesion];
      if (u == null) return http.Response('', 401);
      return _json(_usuario(sesion!, u), 200);
    }
    return http.Response('', 404);
  }

  Map<String, dynamic> _usuario(String email, UsuarioMock u) =>
      {'id': 1, 'email': email, 'nombre': u.nombre};

  http.Response _json(Map<String, dynamic> body, int status,
      {bool conSesion = false}) {
    return http.Response(
      jsonEncode(body),
      status,
      headers: {
        if (conSesion) 'set-cookie': 'sessionid=mock; Path=/; HttpOnly',
      },
    );
  }
}
