import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
