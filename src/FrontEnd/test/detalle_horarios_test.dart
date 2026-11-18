import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/detalle/detalle_screen.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';
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

    testWidgets('barra_muestra_precio_total_y_confirmar', (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);

      final label = tester.widget<Text>(find.text('PRECIO TOTAL'));
      expect(label.style!.fontSize, 11);
      expect(label.style!.fontWeight, FontWeight.w600);
      expect(label.style!.letterSpacing, 1);
      expect(label.style!.color, AppColors.text2);

      final monto = tester.widget<Text>(find.text(r'$45.00'));
      expect(monto.style!.fontSize, 24);
      expect(monto.style!.fontWeight, FontWeight.w700);
      expect(monto.style!.color, AppColors.text);

      final texto = tester.widget<Text>(find.text('Confirmar reserva'));
      expect(texto.style!.fontSize, 15);
      expect(texto.style!.fontWeight, FontWeight.w600);
      expect(texto.style!.color, Colors.white);
      final flecha = tester.widget<Icon>(find.byIcon(LucideIcons.arrowRight));
      expect(flecha.size, 16);
      expect(flecha.color, Colors.white);

      // Barra: surface, borde superior border 1px, padding 16/20.
      final barra = tester.widget<Container>(
        find.byKey(const ValueKey('barra-reserva')),
      );
      final deco = barra.decoration! as BoxDecoration;
      expect(deco.color, AppColors.surface);
      expect(deco.border!.top.color, AppColors.border);
      expect(deco.border!.top.width, 1);
      expect(barra.padding,
          const EdgeInsets.symmetric(vertical: 16, horizontal: 20));

      // Montos por cancha ( precio + '.00' ).
      await _pumpDetalle(tester, canchasSimuladas[1]);
      expect(find.text(r'$60.00'), findsOneWidget);
      await _pumpDetalle(tester, canchasSimuladas[2]);
      expect(find.text(r'$40.00'), findsOneWidget);
    });

    testWidgets('barra_confirmar_abre_reserva_exitosa', (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[1],
          fecha: 'Mié, 16 oct');

      await tester.ensureVisible(find.text('20:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20:00'));
      await tester.pump();
      await tester.tap(find.text('Confirmar reserva'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Tu cancha Skyline Sports Hub quedó reservada para el 16 de octubre a las 20:00.'),
          findsOneWidget,
          reason: 'la pantalla muestra los datos de la reserva');
      expect(find.text(r'$60.00'), findsOneWidget);
    });

    testWidgets('flujo_completo_volver_conserva_estado', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      await tester.enterText(find.byType(TextField), 'futbol');
      await tester.pumpAndSettle();
      await tester.tap(find.text('MIÉ'));
      await tester.pump();
      await tester.ensureVisible(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar reserva'));
      await tester.pumpAndSettle();
      expect(find.text('¡Reserva exitosa!'), findsOneWidget);

      await tester.tap(find.text('Volver al inicio'));
      await tester.pumpAndSettle();

      expect(find.text('futbol'), findsOneWidget,
          reason: 'el buscador conserva su texto');
      final chip = tester.widget<Container>(
        find.byKey(const ValueKey('dia-16')),
      );
      expect((chip.decoration! as BoxDecoration).color, AppColors.primary,
          reason: 'el día seleccionado se conserva');
    });

    testWidgets('flujo_ver_mis_reservas_abre_el_tab', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      await tester.ensureVisible(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar reserva'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver mis reservas'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('placeholder-mis-reservas')),
          findsOneWidget,
          reason: 'el shell abre en el tab Mis reservas');
    });

    testWidgets('horarios_fecha_refleja_el_dia_del_inicio', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      await tester.tap(find.text('MIÉ'));
      await tester.pump();
      await tester.ensureVisible(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();

      expect(find.text('Mié, 16 oct'), findsOneWidget,
          reason: 'la fecha refleja el día elegido en el Inicio');
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
