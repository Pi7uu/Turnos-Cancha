import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';

/// Decoración del primer `Container` bajo [finder].
BoxDecoration _deco(WidgetTester tester, Finder finder) {
  final container = tester.widget<Container>(finder);
  return container.decoration! as BoxDecoration;
}

/// Observador que cuenta los push de rutas (los taps del header no deben
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
  group('InicioScreen · header (RD inicio-header §4)', () {
    testWidgets('inicio_muestra_header_con_marca_campana_y_perfil',
        (tester) async {
      await _pumpInicio(tester);

      expect(find.text('TurnosCancha'), findsOneWidget);
      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
      expect(find.byIcon(LucideIcons.bell), findsOneWidget);
      expect(find.byIcon(LucideIcons.user), findsOneWidget);
    });

    testWidgets('inicio_header_medidas_y_colores', (tester) async {
      await _pumpInicio(tester);

      // Logo 34×34, fondo primary, radio 10 (RD §4).
      final logo = find
          .ancestor(
            of: find.byIcon(Icons.sports_soccer),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(logo), const Size(34, 34));
      final decoLogo = _deco(tester, logo);
      expect(decoLogo.color, AppColors.primary);
      expect(decoLogo.borderRadius, BorderRadius.circular(10));

      // Pelota blanca de 20.
      final pelota = tester.widget<Icon>(find.byIcon(Icons.sports_soccer));
      expect(pelota.size, 20);
      expect(pelota.color, Colors.white);

      // Nombre: 18, bold, primary.
      final nombre = tester.widget<Text>(find.text('TurnosCancha'));
      expect(nombre.style!.fontSize, 18);
      expect(nombre.style!.fontWeight, FontWeight.w700);
      expect(nombre.style!.color, AppColors.primary);

      // Campana 22 en text, perfil 23 en text.
      final campana = tester.widget<Icon>(find.byIcon(LucideIcons.bell));
      expect(campana.size, 22);
      expect(campana.color, AppColors.text);
      final perfil = tester.widget<Icon>(find.byIcon(LucideIcons.user));
      expect(perfil.size, 23);
      expect(perfil.color, AppColors.text);

      // Badge 9×9, danger, borde blanco 2px, en (17, 0) dentro de la caja
      // 26×26 de la campana.
      final cajaCampana = find
          .ancestor(
            of: find.byIcon(LucideIcons.bell),
            matching: find.byType(SizedBox),
          )
          .first;
      expect(tester.getSize(cajaCampana), const Size(26, 26));
      final badge = find
          .descendant(
            of: cajaCampana,
            matching: find.byType(Container),
          )
          .last;
      expect(tester.getSize(badge), const Size(9, 9));
      final decoBadge = _deco(tester, badge);
      expect(decoBadge.color, AppColors.danger);
      expect(decoBadge.shape, BoxShape.circle);
      expect(decoBadge.border!.top.width, 2);
      expect(decoBadge.border!.top.color, Colors.white);
      final desfase = tester.getTopLeft(badge) - tester.getTopLeft(cajaCampana);
      expect(desfase, const Offset(17, 0));
    });

    testWidgets('inicio_campana_y_perfil_no_navegan', (tester) async {
      final observer = _Observer();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const InicioScreen(),
      ));
      // La ruta inicial también dispara didPush: se toma como baseline.
      final pushesIniciales = observer.pushes;

      await tester.tap(find.byIcon(LucideIcons.bell));
      await tester.pump();
      await tester.tap(find.byIcon(LucideIcons.user));
      await tester.pumpAndSettle();

      expect(observer.pushes, pushesIniciales,
          reason: 'campana y perfil son visibles pero no navegan (RF-02)');
      expect(find.text('TurnosCancha'), findsOneWidget,
          reason: 'la pantalla no cambia');
    });

    testWidgets('inicio_sin_overflow_375x844_y_chica', (tester) async {
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
