import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guardado seguro de la sesión (cookie de Django) — ver turnos-futbol.md §5.2.
class SecureStorage {
  static const _sessionKey = 'session_cookie';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession(String cookie) =>
      _storage.write(key: _sessionKey, value: cookie);

  Future<String?> readSession() => _storage.read(key: _sessionKey);

  Future<void> clearSession() => _storage.delete(key: _sessionKey);
}
