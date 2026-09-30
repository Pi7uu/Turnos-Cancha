import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/agenda_screen.dart';
import '../features/admin/clientes_screen.dart';
import '../features/admin/reserva_manual_screen.dart';
import '../features/auth/auth_providers.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/registro_screen.dart';
import '../features/reservas/disponibilidad_screen.dart';
import '../features/reservas/mis_reservas_screen.dart';
import '../features/reservas/reserva_exito_screen.dart';

/// Rutas protegidas por rol — ver turnos-futbol.md §5.2.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authProvider, (_, __) => refresh.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      if (auth.isLoading) return null; // restaurando sesión

      final logueado = auth.valueOrNull != null;
      final esAdmin = auth.valueOrNull?.esAdmin ?? false;
      final enAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/registro';

      if (!logueado && !enAuth) return '/login';
      if (logueado && enAuth) return '/';
      if (logueado && !esAdmin && state.matchedLocation.startsWith('/admin')) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/registro', builder: (c, s) => const RegistroScreen()),
      GoRoute(
        path: '/',
        builder: (c, s) {
          final admin = ref.read(authProvider).valueOrNull?.esAdmin ?? false;
          return admin ? const AgendaScreen() : const DisponibilidadScreen();
        },
      ),
      GoRoute(path: '/mis-reservas', builder: (c, s) => const MisReservasScreen()),
      GoRoute(
          path: '/reserva-exito', builder: (c, s) => const ReservaExitoScreen()),
      GoRoute(path: '/admin/manual', builder: (c, s) => const ReservaManualScreen()),
      GoRoute(path: '/admin/clientes', builder: (c, s) => const ClientesScreen()),
    ],
  );
});
