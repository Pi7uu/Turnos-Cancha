import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';

/// Decoración del chip de categoría [slug] ( key `categoria-<slug>` ).
BoxDecoration _decoChip(WidgetTester tester, String slug) {
  final container = tester.widget<Container>(
    find.byKey(ValueKey('categoria-$slug')),
  );
  return container.decoration! as BoxDecoration;
}

/// Observador que cuenta los push ( los chips no navegan — RF-02 ).
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
  group('InicioScreen · categorías (RD inicio-categorias §4)', () {
    testWidgets('categorias_muestra_titulo_y_2_chips', (tester) async {
      await _pumpInicio(tester);

      expect(find.text('Categorías'), findsOneWidget);
      expect(find.text('Fútbol 5'), findsOneWidget);
      expect(find.text('Fútbol 7'), findsOneWidget);
      expect(
          find.descendant(
            of: find.byKey(const ValueKey('categoria-futbol5')),
            matching: find.byIcon(LucideIcons.users),
          ),
          findsOneWidget,
          reason: 'Fútbol 5 usa el glyph users');
      expect(
          find.descendant(
            of: find.byKey(const ValueKey('categoria-futbol7')),
            matching: find.byIcon(LucideIcons.layoutGrid),
          ),
          findsOneWidget,
          reason: 'Fútbol 7 usa el glyph layout-grid');
    });

    testWidgets('categorias_estilo_del_mockup', (tester) async {
      await _pumpInicio(tester);

      // Chip: surface, radio 14, borde border 1px, padding 18/12.
      final deco = _decoChip(tester, 'futbol5');
      expect(deco.color, AppColors.surface);
      expect(deco.borderRadius, BorderRadius.circular(14));
      expect(deco.border!.top.color, AppColors.border);
      expect(deco.border!.top.width, 1);
      final chip = tester.widget<Container>(
        find.byKey(const ValueKey('categoria-futbol5')),
      );
      expect(chip.padding,
          const EdgeInsets.symmetric(vertical: 18, horizontal: 12));

      // Caja de ícono: 44×44, primarySoft, radio 22; glyph 20 primary.
      final caja = find
          .descendant(
            of: find.byKey(const ValueKey('categoria-futbol5')),
            matching: find
                .ancestor(
                  of: find.byIcon(LucideIcons.users),
                  matching: find.byType(Container),
                )
                .first,
          )
          .first;
      expect(tester.getSize(caja), const Size(44, 44));
      final decoCaja = tester.widget<Container>(caja).decoration! as BoxDecoration;
      expect(decoCaja.color, AppColors.primarySoft);
      expect(decoCaja.borderRadius, BorderRadius.circular(22));
      final glyph = tester.widget<Icon>(find.byIcon(LucideIcons.users));
      expect(glyph.size, 20);
      expect(glyph.color, AppColors.primary);

      // Label: 14 w600 text.
      final label = tester.widget<Text>(find.text('Fútbol 5'));
      expect(label.style!.fontSize, 14);
      expect(label.style!.fontWeight, FontWeight.w600);
      expect(label.style!.color, AppColors.text);
    });

    testWidgets('categorias_chips_mismo_ancho_hueco_12', (tester) async {
      await _pumpInicio(tester);

      final a = tester.getRect(find.byKey(const ValueKey('categoria-futbol5')));
      final b = tester.getRect(find.byKey(const ValueKey('categoria-futbol7')));
      expect(a.width, b.width, reason: 'los 2 chips reparten el ancho igual');
      expect(b.left - a.right, 12, reason: 'hueco 12 entre chips');
    });

    testWidgets('categorias_chips_inertes', (tester) async {
      final observer = _Observer();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const InicioScreen(),
      ));
      final pushesIniciales = observer.pushes;

      await tester.tap(find.text('Fútbol 5'));
      await tester.pump();
      await tester.tap(find.text('Fútbol 7'));
      await tester.pumpAndSettle();

      expect(observer.pushes, pushesIniciales,
          reason: 'los chips no navegan ni cambian nada (RF-02)');
      expect(find.text('Categorías'), findsOneWidget);
    });

    testWidgets('categorias_sin_overflow_375x844_y_chica', (tester) async {
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
