import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';

/// Observador que cuenta los push de rutas (la acción "search" no debe
/// navegar — RD RF-02).
class _Observer extends NavigatorObserver {
  int pushes = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

Future<void> _pumpInicio(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: InicioScreen()));
}

void main() {
  group('InicioScreen · buscador (RD inicio-buscador §4)', () {
    testWidgets('buscador_muestra_campo_con_lupa_y_placeholder',
        (tester) async {
      await _pumpInicio(tester);

      expect(find.text('Buscá canchas cerca tuyo...'), findsOneWidget);
      expect(find.byIcon(LucideIcons.search), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('buscador_debajo_del_header_con_hueco_16', (tester) async {
      await _pumpInicio(tester);

      final header = find
          .ancestor(
            of: find.text('TurnosCancha'),
            matching: find.byType(Row),
          )
          .last;
      final campo = find.byType(TextField);
      final hueco =
          tester.getTopLeft(campo).dy - tester.getBottomRight(header).dy;
      expect(hueco, 16);
    });

    testWidgets('buscador_estilo_del_mockup', (tester) async {
      await _pumpInicio(tester);

      final campo = tester.widget<TextField>(find.byType(TextField));
      final deco = campo.decoration!;
      expect(deco.filled, isTrue);
      expect(deco.fillColor, AppColors.surface);
      // Padding literal del mockup ( §4: 13 vertical / 14 horizontal ).
      expect(deco.contentPadding,
          const EdgeInsets.symmetric(vertical: 13, horizontal: 14));
      expect(deco.hintStyle!.fontSize, 14);
      expect(deco.hintStyle!.fontWeight, FontWeight.normal);
      expect(deco.hintStyle!.color, AppColors.text2);
      final borde = deco.enabledBorder! as OutlineInputBorder;
      expect(borde.borderRadius, BorderRadius.circular(12));
      expect(borde.borderSide.color, AppColors.border);
      expect(borde.borderSide.width, 1);

      // Geometría del mockup: ícono a 14px del borde, hueco 10 al texto.
      final icono = find.byIcon(LucideIcons.search);
      final rectCampo = tester.getRect(find.byType(TextField));
      final rectIcono = tester.getRect(icono);
      expect(rectIcono.left - rectCampo.left, 14);
      expect(rectIcono.width, 18);
      expect(tester.widget<Icon>(icono).size, 18);
      expect(tester.widget<Icon>(icono).color, AppColors.text2);
      final rectHint =
          tester.getRect(find.text('Buscá canchas cerca tuyo...'));
      expect(rectHint.left - (rectIcono.left + 18), 10);
    });

    testWidgets('buscador_acepta_texto_y_lo_conserva', (tester) async {
      await _pumpInicio(tester);

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'futbol');
      await tester.pumpAndSettle();
      expect(find.text('futbol'), findsOneWidget);
      // El hint queda en el árbol fadeado al escribir: lo que desaparece es
      // su superficie visible/hit-testeable.
      expect(find.text('Buscá canchas cerca tuyo...').hitTestable(),
          findsNothing);
      expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'futbol');

      // Tap fuera descarta el teclado pero conserva el valor (RF-01).
      await tester.tapAt(const Offset(200, 700));
      await tester.pumpAndSettle();
      expect(find.text('futbol'), findsOneWidget,
          reason: 'el texto se conserva al perder foco');
    });

    testWidgets('buscador_teclado_search_no_hace_nada', (tester) async {
      final observer = _Observer();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const InicioScreen(),
      ));
      final pushesIniciales = observer.pushes;

      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'futbol');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(observer.pushes, pushesIniciales,
          reason: 'la acción search no navega (RF-02)');
      expect(find.text('futbol'), findsOneWidget,
          reason: 'la acción search no limpia ni cambia el campo');
      expect(find.text('TurnosCancha'), findsOneWidget);
    });

    testWidgets('buscador_sin_overflow_375x844_y_chica', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: InicioScreen()));
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(const MaterialApp(home: InicioScreen()));
      expect(tester.takeException(), isNull);
    });
  });
}
