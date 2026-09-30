import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/models.dart';
import '../../core/storage.dart';
import 'auth_repository.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(secureStorageProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

/// Sesión actual: Usuario autenticado o null.
class AuthNotifier extends AsyncNotifier<Usuario?> {
  @override
  Future<Usuario?> build() async {
    return ref.read(authRepositoryProvider).me();
  }

  Future<void> login(String email, String password) async {
    state = AsyncData(await ref.read(authRepositoryProvider).login(email, password));
  }

  Future<void> registro({
    required String email,
    required String password,
    String nombre = '',
  }) async {
    state = AsyncData(
      await ref
          .read(authRepositoryProvider)
          .registro(email: email, password: password, nombre: nombre),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Usuario?>(
  AuthNotifier.new,
);

/// Fecha seleccionada en la pantalla de disponibilidad (YYYY-MM-DD).
final fechaSeleccionadaProvider = StateProvider<String>((ref) {
  final ahora = DateTime.now();
  return _iso(ahora);
});

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
