import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/detalle/detalle_screen.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';
import 'package:turnos_cancha/features/navegacion/main_shell.dart';

/// Decoración del slot de hora ( key `hora-<HH:MM>` ).
BoxDecoration _decoHora(WidgetTester tester, String hora) {
  final container = tester.widget<Container>(
    find.byKey(ValueKey('hora-$hora')),
  );
  return container.decoration! as BoxDecoration;
}

/// Color del texto de la hora dentro de su slot.
Color _colorHora(WidgetTester tester, String hora) {
  final texto = tester.widget<Text>(
    find.descendant(
      of: find.byKey(ValueKey('hora-$hora')),
      matching: find.byType(Text),
    ),
  );
  return texto.style!.color!;
}

/// Observador que cuenta los push ( Confirmar reserva no navega — RF-03 ).
class _Observer extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

Future<void> _pumpDetalle(WidgetTester tester, Cancha cancha,
    {String fecha = 'Mar, 15 oct'}) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
      MaterialApp(home: DetalleScreen(cancha: cancha, fecha: fecha)));
}

void main() {
  group('DetalleScreen · horarios (RD detalle-horarios §4)', () {
    testWidgets('horarios_muestra_titulo_fecha_y_6_slots', (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);

      expect(find.text('Elegí el horario'), findsOneWidget);
      expect(find.text('Mar, 15 oct'), findsOneWidget);
      for (final hora in [
        '17:00', '18:00', '19:00', '20:00', '21:00', '22:00',
      ]) {
        expect(find.text(hora), findsOneWidget, reason: 'falta el slot $hora');
      }
    });

    testWidgets('horarios_estados_disponible_seleccionado_ocupado',
        (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);

      // Seleccionado ( 19:00 ): primary + hora blanca.
      expect(_decoHora(tester, '19:00').color, AppColors.primary);
      expect(_colorHora(tester, '19:00'), Colors.white);

      // Ocupado ( 21:00 ): #F1F5F9 + hora text2 en Opacity(0.5).
      expect(_decoHora(tester, '21:00').color, const Color(0xFFF1F5F9));
      expect(_colorHora(tester, '21:00'), AppColors.text2);
      final opacidad = find
          .ancestor(
            of: find.descendant(
              of: find.byKey(const ValueKey('hora-21:00')),
              matching: find.byType(Text),
            ),
            matching: find.byType(Opacity),
          )
          .first;
      expect(tester.widget<Opacity>(opacidad).opacity, 0.5);

      // Disponible ( 17:00 ): surface + hora text2 SIN Opacity.
      expect(_decoHora(tester, '17:00').color, AppColors.surface);
      expect(_colorHora(tester, '17:00'), AppColors.text2);
      expect(
          find.descendant(
            of: find.byKey(const ValueKey('hora-17:00')),
            matching: find.byType(Opacity),
          ),
          findsNothing);
    });

    testWidgets('horarios_seleccion_cambia_y_ocupado_no_tappable',
        (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);

      await tester.ensureVisible(find.text('20:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20:00'));
      await tester.pump();
      expect(_decoHora(tester, '20:00').color, AppColors.primary);
      expect(_decoHora(tester, '19:00').color, AppColors.surface,
          reason: 'el anterior se desmarca');

      await tester.ensureVisible(find.text('21:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('21:00'));
      await tester.pump();
      expect(_decoHora(tester, '21:00').color, const Color(0xFFF1F5F9),
          reason: 'el ocupado no reacciona');
      expect(_decoHora(tester, '20:00').color, AppColors.primary,
          reason: 'la selección no cambia');

      await tester.tap(find.text('20:00'));
      await tester.pump();
      expect(_decoHora(tester, '20:00').color, AppColors.primary,
          reason: 'tocar el seleccionado lo mantiene');
    });

    testWidgets('horarios_sin_overflow_375x844_y_chica', (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(MaterialApp(
          home: DetalleScreen(cancha: canchasSimuladas[0])));
      expect(tester.takeException(), isNull);
    });
  });
}
