import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/detalle/detalle_screen.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';

/// Subtree del ítem de comodidad con `key: ValueKey('comodidad-<slug>')`.
Finder _item(String slug) => find.byKey(ValueKey('comodidad-$slug'));

/// Observador que cuenta los push ( los ítems no son tappable — RF-03 ).
class _Observer extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

Future<void> _pumpDetalle(WidgetTester tester, Cancha cancha) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: DetalleScreen(cancha: cancha)));
}

void main() {
  group('DetalleScreen · comodidades (RD detalle-comodidades §4)', () {
    testWidgets('comodidades_muestra_titulo_y_5_items_con_iconos',
        (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);

      expect(find.text('Comodidades'), findsOneWidget);
      for (final par in [
        ['Duchas', 'duchas'],
        ['Estac.', 'estac'],
        ['Aire a/c', 'aire-ac'],
        ['Agua', 'agua'],
        ['WiFi', 'wifi'],
      ]) {
        expect(find.text(par[0]), findsOneWidget, reason: 'falta ${par[0]}');
      }
      // Cada glyph DENTRO de su ítem ( no cruzados ).
      expect(
          find.descendant(
              of: _item('duchas'), matching: find.byIcon(LucideIcons.showerHead)),
          findsOneWidget);
      expect(
          find.descendant(
              of: _item('estac'), matching: find.byIcon(LucideIcons.squareParking)),
          findsOneWidget);
      expect(
          find.descendant(
              of: _item('aire-ac'), matching: find.byIcon(LucideIcons.snowflake)),
          findsOneWidget);
      expect(
          find.descendant(
              of: _item('agua'), matching: find.byIcon(LucideIcons.droplet)),
          findsOneWidget);
      expect(
          find.descendant(
              of: _item('wifi'), matching: find.byIcon(LucideIcons.wifi)),
          findsOneWidget);
    });

    testWidgets('comodidades_estados_disponible_y_no_disponible',
        (tester) async {
      // Elite: los 5 disponibles — círculo surface, sin Opacity.
      await _pumpDetalle(tester, canchasSimuladas[0]);
      for (final slug in ['duchas', 'estac', 'aire-ac', 'agua', 'wifi']) {
        final circulo = find
            .descendant(
              of: _item(slug),
              matching: find.byType(Container),
            )
            .first;
        final deco =
            tester.widget<Container>(circulo).decoration! as BoxDecoration;
        expect(deco.color, AppColors.surface, reason: '$slug disponible');
      }
      expect(find.byType(Opacity), findsNothing,
          reason: 'sin atenuados en Elite');

      // Skyline: Estac. y WiFi no disponibles.
      await _pumpDetalle(tester, canchasSimuladas[1]);
      for (final par in [
        ['estac', LucideIcons.squareParking],
        ['wifi', LucideIcons.wifi],
      ]) {
        final circulo = find
            .descendant(
              of: _item(par[0] as String),
              matching: find.byType(Container),
            )
            .first;
        final deco =
            tester.widget<Container>(circulo).decoration! as BoxDecoration;
        expect(deco.color, const Color(0xFFF1F5F9), reason: '${par[0]} off');
        final opacidad = find
            .ancestor(
              of: find.descendant(
                  of: _item(par[0] as String),
                  matching: find.byIcon(par[1] as IconData)),
              matching: find.byType(Opacity),
            )
            .first;
        expect(tester.widget<Opacity>(opacidad).opacity, 0.45);
        final labelOpacidad = find
            .ancestor(
              of: find.descendant(
                  of: _item(par[0] as String), matching: find.byType(Text)),
              matching: find.byType(Opacity),
            )
            .first;
        expect(tester.widget<Opacity>(labelOpacidad).opacity, 0.5);
      }
      // Duchas sigue disponible en Skyline.
      final circuloDuchas = find
          .descendant(
            of: _item('duchas'),
            matching: find.byType(Container),
          )
          .first;
      expect(
          (tester.widget<Container>(circuloDuchas).decoration! as BoxDecoration)
              .color,
          AppColors.surface);

      // Municipal: los 5 disponibles.
      await _pumpDetalle(tester, canchasSimuladas[2]);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('comodidades_aviso_solo_si_hay_no_disponibles', (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[1]);

      expect(find.text('Estacionamiento y WiFi no disponibles hoy'),
          findsOneWidget);
      final info = tester.widget<Icon>(find.byIcon(LucideIcons.info));
      expect(info.size, 14);
      expect(info.color, const Color(0xFFF59E0B));
      final texto = tester
          .widget<Text>(find.text('Estacionamiento y WiFi no disponibles hoy'));
      expect(texto.style!.fontSize, 12);
      expect(texto.style!.fontWeight, FontWeight.w500);
      expect(texto.style!.color, const Color(0xFFF59E0B));

      await _pumpDetalle(tester, canchasSimuladas[0]);
      expect(find.text('Estacionamiento y WiFi no disponibles hoy'),
          findsNothing);
      await _pumpDetalle(tester, canchasSimuladas[2]);
      expect(find.text('Estacionamiento y WiFi no disponibles hoy'),
          findsNothing);
    });

    testWidgets('sobre_muestra_titulo_y_parrafo', (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);

      final titulo = tester.widget<Text>(find.text('Sobre esta cancha'));
      expect(titulo.style!.fontSize, 17);
      expect(titulo.style!.fontWeight, FontWeight.w700);
      expect(titulo.style!.color, AppColors.text);

      final parrafo = tester.widget<Text>(
        find.textContaining('Césped sintético de grado profesional'),
      );
      expect(parrafo.style!.fontSize, 14);
      expect(parrafo.style!.color, AppColors.text2);
      expect(parrafo.style!.height, 1.55);
    });

    testWidgets('comodidades_no_son_tapables', (tester) async {
      final observer = _Observer();
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: DetalleScreen(cancha: canchasSimuladas[0]),
      ));
      final pushesIniciales = observer.pushes;

      await tester.tap(find.text('Duchas'));
      await tester.pumpAndSettle();

      expect(observer.pushes, pushesIniciales,
          reason: 'los ítems son indicadores, no tappable (RF-03)');
      expect(find.text('Comodidades'), findsOneWidget);
    });

    testWidgets('comodidades_sin_overflow_375x844_y_chica', (tester) async {
      await _pumpDetalle(tester, canchasSimuladas[0]);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(
          MaterialApp(home: DetalleScreen(cancha: canchasSimuladas[0])));
      expect(tester.takeException(), isNull);
    });
  });
}
