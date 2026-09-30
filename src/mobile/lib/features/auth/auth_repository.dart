import '../../core/api_client.dart';
import '../../core/models.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<Usuario> registro({
    required String email,
    required String password,
    String nombre = '',
  }) async {
    final partes = nombre.trim().split(' ');
    final response = await _api.dio.post(
      '/api/auth/registro/',
      data: {
        'email': email,
        'password': password,
        if (partes.isNotEmpty && partes.first.isNotEmpty)
          'first_name': partes.first,
        if (partes.length > 1) 'last_name': partes.sublist(1).join(' '),
      },
    );
    await _api.guardarSesionDe(response);
    return Usuario.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Usuario> login(String email, String password) async {
    final response = await _api.dio.post(
      '/api/auth/login/',
      data: {'email': email, 'password': password},
    );
    await _api.guardarSesionDe(response);
    return Usuario.fromJson(response.data as Map<String, dynamic>);
  }

  /// Usuario actual según la sesión guardada; null si no hay sesión válida.
  Future<Usuario?> me() async {
    try {
      final response = await _api.dio.get('/api/auth/me/');
      return Usuario.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/api/auth/logout/');
    } catch (_) {
      // Aunque falle el request, limpiamos la sesión local.
    }
    await _api.cerrarSesion();
  }
}
