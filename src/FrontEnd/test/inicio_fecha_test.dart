import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';
import 'package:turnos_cancha/features/navegacion/main_shell.dart';

/// Decoración del chip del día [numero] ( key `dia-<numero>` ).
BoxDecoration _decoChip(WidgetTester tester, String numero) {
  final container = tester.widget<Container>(
    find.byKey(ValueKey('dia-$numero')),
  );
  return container.decoration! as BoxDecoration;
}

/// Textos del chip en orden: [0] = día (LUN...), [1] = número.
List<Text> _textosChip(WidgetTester tester, String numero) {
  return tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(ValueKey('dia-$numero')),
          matching: find.byType(Text),
        ),
      )
      .toList();
}

/// Observador que cuenta los push ( el mes no debe navegar — RF-03 ).
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
  group('InicioScreen · selector de fecha (RD inicio-fecha §4)', () {
    testWidgets('fecha_muestra_titulo_mes_y_5_dias', (tester) async {
      await _pumpInicio(tester);

      expect(find.text('Elegí la fecha'), findsOneWidget);
      expect(find.text('Octubre'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);
      for (final par in [
        ['LUN', '14'],
        ['MAR', '15'],
        ['MIÉ', '16'],
        ['JUE', '17'],
        ['VIE', '18'],
      ]) {
        expect(find.text(par[0]), findsOneWidget);
        expect(find.text(par[1]), findsOneWidget);
      }
    });

    testWidgets('fecha_estados_activo_e_inactivo', (tester) async {
      await _pumpInicio(tester);

      // Activo: MAR 15 — fondo primary, día primarySoft, número blanco.
      expect(_decoChip(tester, '15').color, AppColors.primary);
      final activo = _textosChip(tester, '15');
      expect(activo[0].style!.color, AppColors.primarySoft);
      expect(activo[0].style!.fontWeight, FontWeight.w500);
      expect(activo[0].style!.fontSize, 11);
      expect(activo[1].style!.color, Colors.white);
      expect(activo[1].style!.fontWeight, FontWeight.w600);
      expect(activo[1].style!.fontSize, 17);

      // Inactivo: LUN 14 — fondo surface, día text2, número text.
      expect(_decoChip(tester, '14').color, AppColors.surface);
      final inactivo = _textosChip(tester, '14');
      expect(inactivo[0].style!.color, AppColors.text2);
      expect(inactivo[1].style!.color, AppColors.text);
    });

    testWidgets('fecha_chips_mismo_ancho_hueco_8', (tester) async {
      await _pumpInicio(tester);

      final claves = ['14', '15', '16', '17', '18'];
      final anchos = claves
          .map((n) => tester.getSize(find.byKey(ValueKey('dia-$n'))).width)
          .toList();
      for (final ancho in anchos) {
        expect(ancho, anchos[0],
            reason: 'los 5 chips reparten el ancho por igual');
      }
      for (var i = 0; i < claves.length - 1; i++) {
        final a = tester.getRect(find.byKey(ValueKey('dia-${claves[i]}')));
        final b = tester.getRect(find.byKey(ValueKey('dia-${claves[i + 1]}')));
        expect(b.left - a.right, 8, reason: 'hueco 8 entre chips contiguos');
      }
    });

    testWidgets('fecha_tocar_dia_cambia_seleccion', (tester) async {
      await _pumpInicio(tester);

      await tester.tap(find.text('MIÉ'));
      await tester.pump();

      expect(_decoChip(tester, '16').color, AppColors.primary);
      expect(_decoChip(tester, '15').color, AppColors.surface,
          reason: 'el activo anterior vuelve a inactivo');
      expect(_decoChip(tester, '14').color, AppColors.surface);
      expect(_decoChip(tester, '17').color, AppColors.surface);
      expect(_decoChip(tester, '18').color, AppColors.surface);
    });

    testWidgets('fecha_seleccion_se_conserva_al_cambiar_de_tab',
        (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      await tester.tap(find.text('MIÉ'));
      await tester.pump();
      await tester.tap(find.text('Favoritos'));
      await tester.pump();
      await tester.tap(find.text('Inicio'));
      await tester.pump();

      expect(_decoChip(tester, '16').color, AppColors.primary,
          reason: 'la selección persiste: la pantalla está precargada');
    });

    testWidgets('fecha_mes_no_hace_nada', (tester) async {
      final observer = _Observer();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const InicioScreen(),
      ));
      final pushesIniciales = observer.pushes;

      await tester.tap(find.text('Octubre'));
      await tester.pumpAndSettle();

      expect(observer.pushes, pushesIniciales,
          reason: 'el selector de mes es visual (RF-03)');
      expect(find.text('Elegí la fecha'), findsOneWidget);
    });

    testWidgets('fecha_sin_overflow_375x844_y_chica', (tester) async {
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
