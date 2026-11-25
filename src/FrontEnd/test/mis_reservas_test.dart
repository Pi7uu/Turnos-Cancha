import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/mis_reservas/mis_reservas_screen.dart';
import 'package:turnos_cancha/features/navegacion/main_shell.dart';

/// Decoración del card de reserva con `key: ValueKey('reserva-<i>')`.
BoxDecoration _decoCard(WidgetTester tester, int i) {
  final container = tester.widget<Container>(
    find.byKey(ValueKey('reserva-$i')),
  );
  return container.decoration! as BoxDecoration;
}

/// Observador que cuenta los push ( los botones de card son inertes ).
class _Observer extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

Future<void> _pumpReservas(WidgetTester tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: MisReservasScreen()));
}

void main() {
  group('MisReservasScreen (RD mis-reservas-lista §4)', () {
    testWidgets('mis_reservas_muestra_header_y_3_pestanas', (tester) async {
      await _pumpReservas(tester);

      expect(find.text('Mis reservas'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
      expect(find.text('Próximas'), findsOneWidget);
      expect(find.text('Completadas'), findsOneWidget);
      expect(find.text('Canceladas'), findsOneWidget);
      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
    });

    testWidgets('pestanas_estado_activo', (tester) async {
      await _pumpReservas(tester);

      final labelProximas = tester.widget<Text>(find.text('Próximas'));
      expect(labelProximas.style!.color, AppColors.primary);
      expect(labelProximas.style!.fontWeight, FontWeight.w600);
      for (final label in ['Completadas', 'Canceladas']) {
        final t = tester.widget<Text>(find.text(label));
        expect(t.style!.color, AppColors.text2);
        expect(t.style!.fontWeight, FontWeight.w500);
      }

      // Subrayado: container de la pestaña activa con primary; los otros
      // transparentes.
      BoxDecoration subrayado(String slug) => tester
          .widget<Container>(
            find.descendant(
              of: find.byKey(ValueKey('pestana-$slug')),
              matching: find.byType(Container),
            ),
          )
          .decoration! as BoxDecoration;
      expect(subrayado('proximas').color, AppColors.primary);
      expect(subrayado('completadas').color, Colors.transparent);
      expect(subrayado('canceladas').color, Colors.transparent);
    });

    testWidgets('proximas_muestra_las_cards_del_mockup', (tester) async {
      await _pumpReservas(tester);

      // Card 0: Elite CONFIRMADA con Ver QR.
      expect(find.text('Mar, 15 oct 2026'), findsOneWidget);
      expect(find.text('CONFIRMADA'), findsOneWidget);
      expect(find.text('19:00 - 20:00'), findsOneWidget);
      expect(find.text('Cancha A (5v5)'), findsOneWidget);
      expect(find.text('Ver QR'), findsOneWidget);

      // Card 1: Skyline PENDIENTE con Confirmar.
      expect(find.text('Sáb, 19 oct 2026'), findsOneWidget);
      expect(find.text('PENDIENTE'), findsOneWidget);
      expect(find.text('10:00 - 11:30'), findsOneWidget);
      expect(find.text('Cancha principal (7v7)'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      expect(find.text('Cancelar reserva'), findsNWidgets(2));
      expect(find.text('HORARIO'), findsNWidgets(2));
      expect(find.text('CANCHA'), findsNWidgets(2));
    });

    testWidgets('cambiar_pestana_muestra_su_lista', (tester) async {
      await _pumpReservas(tester);

      await tester.tap(find.text('Completadas'));
      await tester.pumpAndSettle();
      expect(find.text('Cancha Municipal'), findsOneWidget);
      expect(find.text('COMPLETADA'), findsOneWidget);
      expect(find.text('18:00 - 19:00'), findsOneWidget);
      expect(find.text('Elite Arena Central'), findsNothing,
          reason: 'las Próximas no se muestran');
      final labelCompletadas = tester.widget<Text>(find.text('Completadas'));
      expect(labelCompletadas.style!.color, AppColors.primary);
      final labelProximas = tester.widget<Text>(find.text('Próximas'));
      expect(labelProximas.style!.color, AppColors.text2,
          reason: 'Próximas vuelve a inactiva');

      await tester.tap(find.text('Canceladas'));
      await tester.pumpAndSettle();
      expect(find.text('CANCELADA'), findsOneWidget);
      expect(find.text('Vie, 23 oct 2026'), findsOneWidget);
      expect(find.text('20:00 - 21:00'), findsOneWidget);
    });

    testWidgets('cards_estilos_del_mockup', (tester) async {
      await _pumpReservas(tester);

      // Card: surface, radio 16, borde border 1px.
      final deco = _decoCard(tester, 0);
      expect(deco.color, AppColors.surface);
      expect(deco.borderRadius, BorderRadius.circular(16));
      expect(deco.border!.top.color, AppColors.border);
      expect(deco.border!.top.width, 1);

      // Foto 48×48 en ClipRRect radio 10.
      final foto = find.descendant(
        of: find.byKey(const ValueKey('reserva-0')),
        matching: find.byType(Image),
      );
      expect(tester.getSize(foto), const Size(48, 48));
      final clip = find.ancestor(of: foto, matching: find.byType(ClipRRect)).first;
      expect(
          (tester.widget<ClipRRect>(clip).borderRadius as BorderRadius).topLeft,
          const Radius.circular(10));

      // Nombre / fecha.
      final nombre = tester.widget<Text>(find.text('Elite Arena Central'));
      expect(nombre.style!.fontSize, 15);
      expect(nombre.style!.fontWeight, FontWeight.w700);
      expect(nombre.style!.color, AppColors.text);
      final fecha = tester.widget<Text>(find.text('Mar, 15 oct 2026'));
      expect(fecha.style!.fontSize, 13);
      expect(fecha.style!.color, AppColors.text2);

      // Badge CONFIRMADA.
      final badge = find
          .ancestor(
            of: find.text('CONFIRMADA'),
            matching: find.byType(Container),
          )
          .first;
      final decoBadge =
          tester.widget<Container>(badge).decoration! as BoxDecoration;
      expect(decoBadge.color, AppColors.primary);
      expect(decoBadge.borderRadius, BorderRadius.circular(6));
      expect(tester.widget<Container>(badge).padding,
          const EdgeInsets.symmetric(vertical: 5, horizontal: 9));
      final textoBadge = tester.widget<Text>(find.text('CONFIRMADA'));
      expect(textoBadge.style!.fontSize, 10);
      expect(textoBadge.style!.fontWeight, FontWeight.w700);
      expect(textoBadge.style!.letterSpacing, 0.5);
      expect(textoBadge.style!.color, Colors.white);

      // Labels y valores del detalle ( acotados al card 0 ).
      final card0 = find.byKey(const ValueKey('reserva-0'));
      for (final label in ['HORARIO', 'CANCHA']) {
        final t = tester.widget<Text>(
          find.descendant(of: card0, matching: find.text(label)),
        );
        expect(t.style!.fontSize, 10);
        expect(t.style!.fontWeight, FontWeight.w600);
        expect(t.style!.letterSpacing, 1);
        expect(t.style!.color, AppColors.text2);
      }
      final valor = tester.widget<Text>(find.text('19:00 - 20:00'));
      expect(valor.style!.fontSize, 17);
      expect(valor.style!.fontWeight, FontWeight.w700);
      expect(valor.style!.color, AppColors.text);

      // Botones.
      final cancelar = find
          .ancestor(
            of: find.text('Cancelar reserva'),
            matching: find.byType(Container),
          )
          .first;
      final decoCancelar =
          tester.widget<Container>(cancelar).decoration! as BoxDecoration;
      expect(decoCancelar.color, AppColors.surface);
      expect(decoCancelar.borderRadius, BorderRadius.circular(10));
      expect(tester.widget<Container>(cancelar).padding,
          const EdgeInsets.all(12));
      final verQr = find
          .ancestor(
            of: find.text('Ver QR'),
            matching: find.byType(Container),
          )
          .first;
      final decoQr =
          tester.widget<Container>(verQr).decoration! as BoxDecoration;
      expect(decoQr.color, AppColors.primary);
      expect(decoQr.borderRadius, BorderRadius.circular(10));
    });

    testWidgets('botones_de_las_cards_son_inertes', (tester) async {
      final observer = _Observer();
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const MisReservasScreen(),
      ));
      final pushesIniciales = observer.pushes;

      await tester.tap(find.text('Cancelar reserva').first);
      await tester.pump();
      await tester.tap(find.text('Ver QR'));
      await tester.pumpAndSettle();

      expect(observer.pushes, pushesIniciales,
          reason: 'los botones de las cards son inertes (RF-03)');
      expect(find.text('Mis reservas'), findsOneWidget);
    });

    testWidgets('mis_reservas_volver_cambia_al_tab_inicio', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      await tester.tap(find.text('Mis reservas'));
      await tester.pumpAndSettle();
      expect(find.text('Elite Arena Central'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Volver'));
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
          reason: 'el tab Inicio está activo');
      expect(find.byKey(const ValueKey('placeholder-inicio')), findsOneWidget);
    });

    testWidgets('mis_reservas_sin_overflow_375x844_y_chica', (tester) async {
      await _pumpReservas(tester);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(const MaterialApp(home: MisReservasScreen()));
      expect(tester.takeException(), isNull);
    });
  });
}
