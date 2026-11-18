import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';
import 'package:turnos_cancha/features/reserva/reserva_exitosa_screen.dart';

/// Observador que cuenta los push ( Ver mis reservas navega — RF-02 ).
class _Observer extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

Future<void> _pumpReserva(WidgetTester tester,
    {Cancha? cancha, String fecha = 'Mar, 15 oct', String hora = '19:00'}) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: ReservaExitosaScreen(
      cancha: cancha ?? canchasSimuladas[0],
      fecha: fecha,
      hora: hora,
    ),
  ));
}

/// El texto del N° de orden renderizado ( formato `#GB-######` ).
String _orden(WidgetTester tester) {
  final textos = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .where((d) => d.startsWith('#GB-'));
  return textos.single;
}

void main() {
  group('ReservaExitosaScreen (RD reserva-exitosa §4)', () {
    testWidgets('reserva_exitosa_muestra_titulo_descripcion_y_card',
        (tester) async {
      await _pumpReserva(tester);

      expect(find.text('¡Reserva exitosa!'), findsOneWidget);
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
      expect(
          find.text(
              'Tu cancha Elite Arena Central quedó reservada para el 15 de octubre a las 19:00.'),
          findsOneWidget);
      expect(find.text('N° DE ORDEN'), findsOneWidget);
      expect(RegExp(r'^#GB-\d{6}$').hasMatch(_orden(tester)), isTrue,
          reason: 'el orden tiene formato #GB-######');
      expect(find.text('ESTADO DE PAGO'), findsOneWidget);
      expect(find.text('PAGADO'), findsOneWidget);
      expect(find.text('PRECIO TOTAL'), findsOneWidget);
      expect(find.text(r'$45.00'), findsOneWidget);
      expect(find.text('Te enviamos la confirmación a tu email registrado.'),
          findsOneWidget);
      expect(find.text('Ver mis reservas'), findsOneWidget);
      expect(find.text('Volver al inicio'), findsOneWidget);
    });

    testWidgets('reserva_exitosa_descripcion_con_datos_de_la_reserva',
        (tester) async {
      await _pumpReserva(tester,
          cancha: canchasSimuladas[1], fecha: 'Mié, 16 oct', hora: '20:00');

      expect(
          find.text(
              'Tu cancha Skyline Sports Hub quedó reservada para el 16 de octubre a las 20:00.'),
          findsOneWidget);
      expect(find.text(r'$60.00'), findsOneWidget);
    });

    testWidgets('reserva_exitosa_card_estilos', (tester) async {
      await _pumpReserva(tester);

      for (final label in ['N° DE ORDEN', 'ESTADO DE PAGO', 'PRECIO TOTAL']) {
        final t = tester.widget<Text>(find.text(label));
        expect(t.style!.fontSize, 11);
        expect(t.style!.fontWeight, FontWeight.w600);
        expect(t.style!.letterSpacing, 1);
        expect(t.style!.color, AppColors.text2);
      }

      final orden = tester.widget<Text>(find.text(_orden(tester)));
      expect(orden.style!.fontSize, 15);
      expect(orden.style!.fontWeight, FontWeight.w600);
      expect(orden.style!.color, AppColors.text);

      // Píldora PAGADO: primarySoft, radio 8, padding 4/9, texto 11 w600 primary.
      final pill = find
          .ancestor(
            of: find.text('PAGADO'),
            matching: find.byType(Container),
          )
          .first;
      final decoPill =
          tester.widget<Container>(pill).decoration! as BoxDecoration;
      expect(decoPill.color, AppColors.primarySoft);
      expect(decoPill.borderRadius, BorderRadius.circular(8));
      expect(tester.widget<Container>(pill).padding,
          const EdgeInsets.symmetric(vertical: 4, horizontal: 9));
      final textoPill = tester.widget<Text>(find.text('PAGADO'));
      expect(textoPill.style!.fontSize, 11);
      expect(textoPill.style!.fontWeight, FontWeight.w600);
      expect(textoPill.style!.color, AppColors.primary);

      final monto = tester.widget<Text>(find.text(r'$45.00'));
      expect(monto.style!.fontSize, 20);
      expect(monto.style!.fontWeight, FontWeight.w700);
      expect(monto.style!.color, AppColors.primary);

      // Card: surface, radio 16, borde border 1px.
      final card = find
          .ancestor(
            of: find.text('N° DE ORDEN'),
            matching: find.byType(Container),
          )
          .first;
      final decoCard =
          tester.widget<Container>(card).decoration! as BoxDecoration;
      expect(decoCard.color, AppColors.surface);
      expect(decoCard.borderRadius, BorderRadius.circular(16));
      expect(decoCard.border!.top.color, AppColors.border);
      expect(decoCard.border!.top.width, 1);
    });

    testWidgets('reserva_exitosa_orden_distinto_entre_reservas', (tester) async {
      await _pumpReserva(tester);
      final primero = _orden(tester);
      expect(RegExp(r'^#GB-\d{6}$').hasMatch(primero), isTrue);

      await _pumpReserva(tester);
      final segundo = _orden(tester);
      expect(RegExp(r'^#GB-\d{6}$').hasMatch(segundo), isTrue);
      expect(segundo, isNot(primero),
          reason: 'cada reserva tiene su propio N° de orden');
    });

    testWidgets('reserva_exitosa_ver_mis_reservas_abre_el_tab', (tester) async {
      final observer = _Observer();
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: ReservaExitosaScreen(
          cancha: canchasSimuladas[0],
          fecha: 'Mar, 15 oct',
          hora: '19:00',
        ),
      ));
      final pushesIniciales = observer.pushes;

      await tester.tap(find.text('Ver mis reservas'));
      await tester.pumpAndSettle();

      expect(observer.pushes, greaterThan(pushesIniciales),
          reason: 'Ver mis reservas navega');
      expect(find.byKey(const ValueKey('placeholder-mis-reservas')),
          findsOneWidget,
          reason: 'el shell abre con el tab Mis reservas activo');
      final deco = tester
          .widget<Container>(
            find
                .descendant(
                  of: find.byKey(const ValueKey('tab-misReservas')),
                  matching: find.byType(Container),
                )
                .first,
          )
          .decoration! as BoxDecoration;
      expect(deco.color, AppColors.primarySoft);
    });

    testWidgets('reserva_exitosa_sin_overflow_375x844_y_chica', (tester) async {
      await _pumpReserva(tester);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(MaterialApp(
        home: ReservaExitosaScreen(
          cancha: canchasSimuladas[0],
          fecha: 'Mar, 15 oct',
          hora: '19:00',
        ),
      ));
      expect(tester.takeException(), isNull);
    });
  });
}
