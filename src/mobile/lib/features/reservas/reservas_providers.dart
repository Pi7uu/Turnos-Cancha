import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/models.dart';
import '../auth/auth_providers.dart';

class ReservasRepository {
  ReservasRepository(this._api);

  final ApiClient _api;

  Future<Disponibilidad> disponibilidad(String fecha) async {
    final response = await _api.dio.get(
      '/api/disponibilidad/',
      queryParameters: {'fecha': fecha},
    );
    return Disponibilidad.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Reserva> crear({
    required String tipo,
    required String fecha,
    required String horaInicio,
    String? cancha,
  }) async {
    final response = await _api.dio.post(
      '/api/reservas/',
      data: {
        'tipo': tipo,
        'fecha': fecha,
        'hora_inicio': horaInicio,
        if (cancha != null) 'cancha': cancha,
      },
    );
    return Reserva.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Reserva>> misReservas() async {
    final response = await _api.dio.get('/api/reservas/mias/');
    return (response.data as List)
        .map((r) => Reserva.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<Reserva> confirmar(int id) async {
    final response = await _api.dio.post('/api/reservas/$id/confirmar/');
    return Reserva.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Reserva> cancelar(int id) async {
    final response = await _api.dio.post('/api/reservas/$id/cancelar/');
    return Reserva.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> agenda(String fecha) async {
    final response = await _api.dio.get(
      '/api/admin/agenda/',
      queryParameters: {'fecha': fecha},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['reservas'] as List)
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
  }

  Future<Reserva> reservaManual({
    required String clienteEmail,
    required String tipo,
    required String fecha,
    required String horaInicio,
    String? cancha,
    bool confirmada = true,
  }) async {
    final response = await _api.dio.post(
      '/api/admin/reservas/',
      data: {
        'cliente_email': clienteEmail,
        'tipo': tipo,
        'fecha': fecha,
        'hora_inicio': horaInicio,
        if (cancha != null) 'cancha': cancha,
        'confirmada': confirmada,
      },
    );
    return Reserva.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Usuario>> clientes() async {
    final response = await _api.dio.get('/api/admin/clientes/');
    return (response.data as List)
        .map((u) => Usuario.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<List<Reserva>> reservasDeCliente(int clienteId) async {
    final response = await _api.dio.get('/api/admin/clientes/$clienteId/reservas/');
    return (response.data as List)
        .map((r) => Reserva.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}

final reservasRepositoryProvider = Provider<ReservasRepository>(
  (ref) => ReservasRepository(ref.watch(apiClientProvider)),
);

final disponibilidadProvider =
    FutureProvider.family<Disponibilidad, String>((ref, fecha) {
  return ref.watch(reservasRepositoryProvider).disponibilidad(fecha);
});

final misReservasProvider = FutureProvider<List<Reserva>>((ref) {
  return ref.watch(reservasRepositoryProvider).misReservas();
});

final agendaProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, fecha) {
  return ref.watch(reservasRepositoryProvider).agenda(fecha);
});

final clientesProvider = FutureProvider<List<Usuario>>((ref) {
  return ref.watch(reservasRepositoryProvider).clientes();
});
