import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/core/estados.dart';
import 'package:turnos_cancha/core/fechas.dart';

void main() {
  group('fechas', () {
    test('toIso / fromIso son inversas', () {
      const iso = '2026-09-23';
      expect(toIso(fromIso(iso)), iso);
    });

    test('fechaLarga formatea en español', () {
      expect(fechaLarga('2026-09-23'), 'miércoles 23 de septiembre de 2026');
    });

    test('fechaCorta formatea dd/mm/aaaa', () {
      expect(fechaCorta('2026-09-05'), '05/09/2026');
    });

    test('sumarDias cruza mes y año', () {
      expect(sumarDias('2026-12-31', 1), '2027-01-01');
      expect(sumarDias('2026-01-01', -1), '2025-12-31');
    });
  });

  group('estados', () {
    test('color de cada estado es distinto', () {
      final estados = ['PENDIENTE', 'CONFIRMADA', 'VENCIDA', 'CANCELADA'];
      final colores = estados.map(colorEstado).toSet();
      expect(colores.length, estados.length);
    });

    test('etiqueta va en mayúsculas', () {
      expect(etiquetaEstado('pendiente'), 'PENDIENTE');
    });
  });
}
