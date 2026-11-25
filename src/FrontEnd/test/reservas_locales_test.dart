import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/mis_reservas/reserva.dart';
import 'package:turnos_cancha/features/mis_reservas/reservas_locales.dart';

void main() {
  setUp(resetReservas);

  group('reservasLocales (RD mis-reservas-acciones RF-02)', () {
    test('store_arranca_sembrado', () {
      expect(reservasLocales.length, 4);
      expect(reservasLocales[0].nombre, 'Elite Arena Central');
      expect(reservasLocales[0].estado, EstadoReserva.confirmada);
      expect(reservasLocales[1].estado, EstadoReserva.pendiente);
    });

    test('registrar_reserva_agrega_al_inicio', () {
      final nueva = Reserva(
        nombre: 'Elite Arena Central',
        foto: 'assets/img/canchas/elite_arena.jpg',
        fecha: 'Mié, 16 oct 2026',
        horario: '20:00 - 21:00',
        sector: 'Cancha A (5v5)',
        estado: EstadoReserva.confirmada,
        tieneQr: true,
      );
      registrarReserva(nueva);
      expect(reservasLocales.length, 5);
      expect(reservasLocales.first.horario, '20:00 - 21:00');
    });

    test('cancelar_reserva_cambia_estado', () {
      final elite = reservasLocales[0];
      cancelarReserva(elite);
      expect(reservasLocales[0].estado, EstadoReserva.cancelada);
      expect(reservasLocales[0].nombre, 'Elite Arena Central');
    });

    test('confirmar_reserva_cambia_estado', () {
      final skyline = reservasLocales[1];
      confirmarReserva(skyline);
      expect(reservasLocales[1].estado, EstadoReserva.confirmada);
      expect(reservasLocales[1].nombre, 'Skyline Sports Hub');
    });

    test('reset_vuelve_a_la_semilla', () {
      registrarReserva(Reserva(
        nombre: 'X',
        foto: 'assets/img/canchas/elite_arena.jpg',
        fecha: 'f',
        horario: 'h',
        sector: 's',
        estado: EstadoReserva.confirmada,
        tieneQr: true,
      ));
      resetReservas();
      expect(reservasLocales.length, 4);
      expect(reservasLocales.first.nombre, 'Elite Arena Central');
    });
  });
}
