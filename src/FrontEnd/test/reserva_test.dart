import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/mis_reservas/reserva.dart';

void main() {
  group('Reserva (RD mis-reservas-lista §4)', () {
    test('reservas_simuladas_datos_del_mockup', () {
      expect(reservasSimuladas.length, 4);
      expect(reservasSimuladas[0].nombre, 'Elite Arena Central');
      expect(reservasSimuladas[0].fecha, 'Mar, 15 oct 2026');
      expect(reservasSimuladas[0].horario, '19:00 - 20:00');
      expect(reservasSimuladas[0].sector, 'Cancha A (5v5)');
      expect(reservasSimuladas[0].estado, EstadoReserva.confirmada);
      expect(reservasSimuladas[1].nombre, 'Skyline Sports Hub');
      expect(reservasSimuladas[1].fecha, 'Sáb, 19 oct 2026');
      expect(reservasSimuladas[1].horario, '10:00 - 11:30');
      expect(reservasSimuladas[1].sector, 'Cancha principal (7v7)');
      expect(reservasSimuladas[1].estado, EstadoReserva.pendiente);
      expect(reservasSimuladas[2].nombre, 'Cancha Municipal');
      expect(reservasSimuladas[2].horario, '18:00 - 19:00');
      expect(reservasSimuladas[2].sector, 'Cancha B (5v5)');
      expect(reservasSimuladas[2].estado, EstadoReserva.completada);
      expect(reservasSimuladas[3].nombre, 'Elite Arena Central');
      expect(reservasSimuladas[3].fecha, 'Vie, 23 oct 2026');
      expect(reservasSimuladas[3].horario, '20:00 - 21:00');
      expect(reservasSimuladas[3].estado, EstadoReserva.cancelada);
    });

    test('reservas_por_estado', () {
      final proximas = reservasSimuladas
          .where((r) =>
              r.estado == EstadoReserva.confirmada ||
              r.estado == EstadoReserva.pendiente)
          .length;
      expect(proximas, 2);
      expect(
          reservasSimuladas
              .where((r) => r.estado == EstadoReserva.completada)
              .length,
          1);
      expect(
          reservasSimuladas
              .where((r) => r.estado == EstadoReserva.cancelada)
              .length,
          1);
    });

    test('reservas_referencian_assets_de_fotos', () {
      for (final r in reservasSimuladas) {
        expect(r.foto, startsWith('assets/img/canchas/'));
      }
    });
  });
}
