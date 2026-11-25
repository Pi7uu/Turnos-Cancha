import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';

Future<void> _pumpInicio(WidgetTester tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: InicioScreen()));
}

void main() {
  group('Filtrado del Inicio (RD inicio-filtrado RF-01/02)', () {
    testWidgets('buscador_filtra_por_nombre', (tester) async {
      await _pumpInicio(tester);

      await tester.enterText(find.byType(TextField), 'elite');
      await tester.pump();

      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsNothing);
      expect(find.text('Cancha Municipal'), findsNothing);

      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('Cancha Municipal'), findsOneWidget);
    });

    testWidgets('categorías_filtran_y_se_deseleccionan', (tester) async {
      await _pumpInicio(tester);

      // Los chips quedan bajo el scroll con las 3 cards: hacerlos visibles.
      await tester.ensureVisible(find.byKey(const ValueKey('categoria-futbol7')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('categoria-futbol7')));
      await tester.pump();
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('Elite Arena Central'), findsNothing);
      expect(find.text('Cancha Municipal'), findsNothing);

      // Tocar el chip activo lo deselecciona.
      await tester.ensureVisible(find.byKey(const ValueKey('categoria-futbol7')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('categoria-futbol7')));
      await tester.pump();
      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('Cancha Municipal'), findsOneWidget);
    });

    testWidgets('filtros_se_combinan', (tester) async {
      await _pumpInicio(tester);

      await tester.enterText(find.byType(TextField), 'sky');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('categoria-futbol5')));
      await tester.pump();

      // Skyline es 7v7: con Fútbol 5 activo no hay resultados.
      expect(find.text('Skyline Sports Hub'), findsNothing);
      expect(find.text('Elite Arena Central'), findsNothing);
    });
  });

  group('Estado sin canchas (RD inicio-filtrado RF-03/04, frame 06)', () {
    testWidgets('sin_resultados_muestra_estado_06', (tester) async {
      await _pumpInicio(tester);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();

      expect(find.text('No hay canchas disponibles'), findsOneWidget);
      expect(
          find.text(
              'No quedan canchas libres para esta fecha en tu zona. Probá con otro día.'),
          findsOneWidget);
      expect(find.byIcon(LucideIcons.calendarX), findsOneWidget);
      expect(find.text('Elegir otra fecha'), findsOneWidget);
      expect(find.text('Elite Arena Central'), findsNothing);
    });

    testWidgets('acciones_limpian_filtros', (tester) async {
      await _pumpInicio(tester);

      // Elegir otra fecha limpia buscador y categoría.
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();
      await tester.ensureVisible(find.text('Elegir otra fecha'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Elegir otra fecha'));
      await tester.pumpAndSettle();
      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('Cancha Municipal'), findsOneWidget);

      // Ver todo también limpia ( buscador + categoría ).
      await tester.enterText(find.byType(TextField), 'sky');
      await tester.pump();
      await tester
          .ensureVisible(find.byKey(const ValueKey('categoria-futbol5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('categoria-futbol5')));
      await tester.pump();
      expect(find.text('No hay canchas disponibles'), findsOneWidget);
      await tester.ensureVisible(find.text('Ver todo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver todo'));
      await tester.pumpAndSettle();
      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('Cancha Municipal'), findsOneWidget);
    });

    testWidgets('estado_06_estilos', (tester) async {
      await _pumpInicio(tester);

      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pump();

      final card = find
          .ancestor(
            of: find.text('No hay canchas disponibles'),
            matching: find.byType(Container),
          )
          .first;
      final deco = tester.widget<Container>(card).decoration! as BoxDecoration;
      expect(deco.color, AppColors.surface);
      expect(deco.borderRadius, BorderRadius.circular(16));

      final circulo = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(LucideIcons.calendarX),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(circulo.constraints, const BoxConstraints.tightFor(width: 76, height: 76));
      expect((circulo.decoration! as BoxDecoration).color, AppColors.primarySoft);

      final boton = find
          .ancestor(
            of: find.text('Elegir otra fecha'),
            matching: find.byType(Container),
          )
          .first;
      final decoBoton =
          tester.widget<Container>(boton).decoration! as BoxDecoration;
      expect(decoBoton.color, AppColors.primary);
      expect(decoBoton.borderRadius, BorderRadius.circular(12));
      expect(
        tester.widget<Container>(boton).padding,
        const EdgeInsets.symmetric(vertical: 13, horizontal: 26),
      );
    });
  });
}
