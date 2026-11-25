import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:turnos_cancha/core/api/api_client.dart';

void main() {
  group('ApiClient (RD api-auth §4)', () {
    test('login_ok_devuelve_usuario_y_guarda_cookie', () async {
      http.BaseRequest? visto;
      final api = ApiClient(
        baseUrl: 'http://api.test',
        client: MockClient((request) async {
          visto = request;
          return http.Response(
            '{"id": 1, "email": "a@b.com", "nombre": "Ana"}',
            200,
            headers: {'set-cookie': 'sessionid=abc123; Path=/; HttpOnly'},
          );
        }),
      );

      final u = await api.login('a@b.com', 'clave');

      expect(u.email, 'a@b.com');
      expect(u.nombre, 'Ana');
      expect(visto!.url.toString(), 'http://api.test/api/auth/login/');
      expect((visto as http.Request).body, contains('a@b.com'));

      // La cookie guardada viaja en los requests siguientes.
      await api.perfil();
      // ( ver perfil_usa_cookie_de_sesion abajo — aquí solo la sesión nace )
    });

    test('perfil_usa_cookie_de_sesion', () async {
      http.BaseRequest? visto;
      final api = ApiClient(
        baseUrl: 'http://api.test',
        client: MockClient((request) async {
          if (request.url.path.endsWith('login/')) {
            return http.Response(
              '{"id": 1, "email": "a@b.com", "nombre": "Ana"}',
              200,
              headers: {'set-cookie': 'sessionid=abc123; Path=/; HttpOnly'},
            );
          }
          visto = request;
          return http.Response('{"id": 1, "email": "a@b.com", "nombre": "Ana"}', 200);
        }),
      );

      await api.login('a@b.com', 'clave');
      await api.perfil();

      expect(visto!.headers['Cookie'], contains('sessionid=abc123'));
    });

    test('login_error_401_toma_el_mensaje_del_servidor', () async {
      final api = ApiClient(
        baseUrl: 'http://api.test',
        client: MockClient((request) async => http.Response(
              '{"error": "Email o contraseña incorrectos."}',
              401,
            )),
      );

      await expectLater(
        api.login('a@b.com', 'mala'),
        throwsA(isA<ApiException>().having(
            (e) => e.mensaje, 'mensaje', 'Email o contraseña incorrectos.')),
      );
    });

    test('registro_error_400_toma_el_mensaje_del_servidor', () async {
      final api = ApiClient(
        baseUrl: 'http://api.test',
        client: MockClient((request) async => http.Response(
              '{"error": "Ya existe una cuenta con ese email."}',
              400,
            )),
      );

      await expectLater(
        api.registro('a@b.com', 'clave'),
        throwsA(isA<ApiException>().having(
            (e) => e.mensaje, 'mensaje', 'Ya existe una cuenta con ese email.')),
      );
    });

    test('error_de_red_mensaje_es', () async {
      final api = ApiClient(
        baseUrl: 'http://api.test',
        client: MockClient((request) async {
          throw const SocketException('sin red');
        }),
      );

      await expectLater(
        api.login('a@b.com', 'clave'),
        throwsA(isA<ApiException>().having((e) => e.mensaje, 'mensaje',
            'No se pudo conectar. Intentá de nuevo.')),
      );
    });

    test('logout_llama_al_endpoint', () async {
      http.BaseRequest? visto;
      final api = ApiClient(
        baseUrl: 'http://api.test',
        client: MockClient((request) async {
          visto = request;
          return http.Response('', 204);
        }),
      );

      await api.logout();
      expect(visto!.url.toString(), 'http://api.test/api/auth/logout/');
    });
  });
}
