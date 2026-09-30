import 'package:dio/dio.dart';

import 'storage.dart';

/// Cliente HTTP con interceptor de sesión (Cookie) — ver turnos-futbol.md §5.2.
///
/// En Android emulator la API corre en 10.0.2.2:8000; en dispositivo físico o
/// desktop se puede pisar con --dart-define=API_BASE_URL=http://IP:8000
class ApiClient {
  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await _storage.readSession();
          if (session != null && session.isNotEmpty) {
            options.headers['Cookie'] = session;
          }
          handler.next(options);
        },
      ),
    );
  }

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  final SecureStorage _storage;
  late final Dio _dio;

  Dio get dio => _dio;

  /// Guarda la cookie de sesión que devuelve el backend al loguear.
  Future<void> guardarSesionDe(Response response) async {
    final cookies = response.headers['set-cookie'];
    if (cookies == null || cookies.isEmpty) return;
    final primera = cookies.first;
    final corte = primera.indexOf(';');
    final cookie = corte == -1 ? primera : primera.substring(0, corte);
    if (cookie.startsWith('sessionid=')) {
      await _storage.saveSession(cookie);
    }
  }

  Future<void> cerrarSesion() => _storage.clearSession();

  /// Mensaje de error del backend ({"detalle": ...} o errores de campo).
  static String mensajeDeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        if (data['detalle'] is String) return data['detalle'] as String;
        final buffer = StringBuffer();
        data.forEach((key, value) {
          if (value is List) {
            buffer.writeln(value.join(', '));
          } else {
            buffer.writeln('$key: $value');
          }
        });
        final texto = buffer.toString().trim();
        if (texto.isNotEmpty) return texto;
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'No se pudo conectar con el servidor.';
      }
    }
    return 'Ocurrió un error inesperado.';
  }
}
