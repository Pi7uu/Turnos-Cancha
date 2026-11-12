import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/navegacion/main_shell.dart';
import 'package:turnos_cancha/features/navegacion/tab_bar.dart';

/// Decoración del contenedor de un tab (igual criterio que tab_bar_test).
BoxDecoration _decoTab(WidgetTester tester, TabApp tab) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byKey(ValueKey('tab-${tab.name}')),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as BoxDecoration;
}

/// Índice del IndexedStack del shell.
int? _indice(WidgetTester tester) =>
    tester.widget<IndexedStack>(find.byType(IndexedStack)).index;

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: MainShell()));
}

void main() {
  group('MainShell (RD navegacion RF-02/03)', () {
    testWidgets('shell_arranca_en_inicio_activo', (tester) async {
      await _pump(tester);

      expect(_indice(tester), 0);
      expect(
          find.byKey(const ValueKey('placeholder-inicio')), findsOneWidget,
          reason: 'placeholder de Inicio visible');
      expect(find.byKey(const ValueKey('placeholder-mis-reservas')),
          findsNothing,
          reason: 'las otras 3 están precargadas pero fuera de vista');
      expect(_decoTab(tester, TabApp.inicio).color, AppColors.primarySoft,
          reason: 'tab Inicio marcado activo');
    });

    testWidgets('shell_cambiar_tab_marca_activo_y_muestra_pantalla',
        (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Favoritos'));
      await tester.pump();
      expect(_indice(tester), 2);
      expect(
          find.byKey(const ValueKey('placeholder-favoritos')), findsOneWidget);
      expect(_decoTab(tester, TabApp.favoritos).color, AppColors.primarySoft);
      expect(_decoTab(tester, TabApp.inicio).color, isNull);

      await tester.tap(find.text('Perfil'));
      await tester.pump();
      expect(_indice(tester), 3);
      expect(find.byKey(const ValueKey('placeholder-perfil')), findsOneWidget);
    });

    testWidgets('shell_las_4_pantallas_estan_precargadas', (tester) async {
      await _pump(tester);

      // Sin haber tocado nada, las 4 ya están en el árbol (offstage incluidas):
      // es IndexedStack, no Navigator apilando rutas.
      for (final nombre in [
        'placeholder-inicio',
        'placeholder-mis-reservas',
        'placeholder-favoritos',
        'placeholder-perfil',
      ]) {
        expect(
          find.byKey(ValueKey(nombre), skipOffstage: false),
          findsOneWidget,
          reason: '$nombre precargado en el árbol',
        );
      }
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('shell_tab_bar_en_la_zona_del_mockup', (tester) async {
      await _pump(tester);

      // SafeArea(bottom) + Padding 16 lateral / 12 inferior alrededor del
      // Tab Bar, dentro del bottomNavigationBar del Scaffold (RD §4).
      expect(
        find.ancestor(
          of: find.byType(AppTabBar),
          matching: find.byType(SafeArea),
        ),
        findsOneWidget,
      );
      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(AppTabBar),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(padding.padding,
          const EdgeInsets.only(left: 16, right: 16, bottom: 12));

      // El Scaffold del shell (el más externo) usa el fondo del design system.
      final scaffold = tester.widget<Scaffold>(
        find
            .ancestor(
              of: find.byType(AppTabBar),
              matching: find.byType(Scaffold),
            )
            .first,
      );
      expect(scaffold.backgroundColor, AppColors.bg);
    });
  });
}
