import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/mis_reservas/mis_reservas_screen.dart';
import 'package:turnos_cancha/features/mis_reservas/reservas_locales.dart';
import 'package:turnos_cancha/features/navegacion/main_shell.dart';

Future<void> _pumpReservas(WidgetTester tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: MisReservasScreen()));
}

void main() {
  setUp(resetReservas);

  group('Acciones de Mis reservas (RD mis-reservas-acciones RF-01/04)', () {
    testWidgets('accion_cancelar_mueve_a_canceladas', (tester) async {
      await _pumpReservas(tester);

      await tester.tap(find.text('Cancelar reserva').first);
      await tester.pumpAndSettle();

      // Elite desaparece de Próximas ( queda Skyline ).
      expect(find.text('Elite Arena Central'), findsNothing);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);

      await tester.tap(find.text('Canceladas'));
      await tester.pumpAndSettle();
      expect(find.text('Elite Arena Central'), findsNWidgets(2),
          reason: 'la semilla Vie 23 + la recién cancelada Mar 15');
      expect(find.text('CANCELADA'), findsNWidgets(2));
    });

    testWidgets('accion_confirmar_cambia_estado', (tester) async {
      await _pumpReservas(tester);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('PENDIENTE'), findsNothing);
      expect(find.text('CONFIRMADA'), findsNWidgets(2),
          reason: 'Skyline pasa a confirmada ( junto a la semilla Elite )');
      expect(find.text('Ver QR'), findsOneWidget,
          reason: 'Skyline tiene QR: aparece su botón');
    });

    testWidgets('ver_qr_abre_dialogo_y_cierra', (tester) async {
      await _pumpReservas(tester);

      // Confirmar Skyline para tener un Ver QR.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver QR'));
      await tester.pumpAndSettle();

      expect(find.text('Tu QR'), findsOneWidget);
      expect(find.text('Mostrá este código en la entrada.'), findsOneWidget);
      expect(find.byIcon(LucideIcons.qrCode), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('qr-cerrar')));
      await tester.pumpAndSettle();
      expect(find.text('Tu QR'), findsNothing);
    });

    testWidgets('variante_sin_qr', (tester) async {
      await _pumpReservas(tester);

      // Elite Mar 15 (tieneQr: false) es confirmada: solo Cancelar reserva.
      final cardElite = find.byKey(const ValueKey('reserva-0'));
      expect(
          find.descendant(of: cardElite, matching: find.text('Ver QR')),
          findsNothing,
          reason: 'confirmada sin QR no muestra Ver QR (frame 08)');
      expect(
          find.descendant(
              of: cardElite, matching: find.text('Cancelar reserva')),
          findsOneWidget);
    });

    testWidgets('pestana_vacia_muestra_estado_vacio', (tester) async {
      await _pumpReservas(tester);

      // Cancelar las 2 de Próximas → la pestaña queda vacía.
      await tester.tap(find.text('Cancelar reserva').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar reserva').first);
      await tester.pumpAndSettle();

      expect(find.text('No tenés reservas'), findsOneWidget);
      expect(
          find.text(
              'Cuando reserves una cancha va a aparecer acá. ¡Buscá la tuya y empezá a jugar!'),
          findsOneWidget);
      expect(find.byIcon(LucideIcons.calendarDays), findsOneWidget);
      expect(find.text('Explorar canchas'), findsOneWidget);
    });

    testWidgets('explorar_canchas_cambia_al_inicio', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      await tester.tap(find.text('Mis reservas'));
      await tester.pumpAndSettle();
      // Vaciar Próximas.
      await tester.tap(find.text('Cancelar reserva').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar reserva').first);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('explorar-canchas')));
      await tester.pumpAndSettle();

      final deco = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byKey(const ValueKey('tab-inicio')),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(deco.color, AppColors.primarySoft,
          reason: 'Explorar canchas cambia al tab Inicio');
      expect(find.byKey(const ValueKey('placeholder-inicio')), findsOneWidget);
    });
    testWidgets('flujo_exitoso_registra_en_próximas', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      // Inicio → Elite → elegir 20:00 → Confirmar → éxito → Ver mis reservas.
      await tester.ensureVisible(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('20:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20:00'));
      await tester.pump();
      await tester.tap(find.text('Confirmar reserva'));
      await tester.pumpAndSettle();
      expect(find.text('¡Reserva exitosa!'), findsOneWidget);
      expect(
          find.text(
              'Tu cancha Elite Arena Central quedó reservada para el 15 de octubre a las 20:00.'),
          findsOneWidget,
          reason: 'la hora seleccionada llegó a la reserva');

      await tester.tap(find.text('Ver mis reservas'));
      await tester.pumpAndSettle();
      expect(find.text('Próximas'), findsOneWidget,
          reason: 'Ver mis reservas abrió el tab');

      expect(find.text('20:00 - 21:00'), findsOneWidget,
          reason: 'la reserva creada aparece en Próximas');
      expect(find.text('Cancha A (5v5)'), findsNWidgets(2),
          reason: 'la semilla Mar 15 + la creada');
      expect(find.text('CONFIRMADA'), findsNWidgets(2));
      expect(find.text('Ver QR'), findsOneWidget,
          reason: 'las reservas del flujo tienen QR');
    });

    testWidgets('flujo_error_no_registra', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      // Elite 18:00 ( conflicto ) → error → Ver mis reservas.
      await tester.ensureVisible(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('18:00'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18:00'));
      await tester.pump();
      await tester.tap(find.text('Confirmar reserva'));
      await tester.pumpAndSettle();
      expect(find.text('No se pudo completar la reserva'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('error-volver')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mis reservas'));
      await tester.pumpAndSettle();

      // Solo las 2 semillas ( sin nueva ).
      expect(find.text('19:00 - 20:00'), findsOneWidget);
      expect(find.text('10:00 - 11:30'), findsOneWidget);
      expect(find.text('20:00 - 21:00'), findsNothing,
          reason: 'el camino de error no registra');
    });
  });
}
