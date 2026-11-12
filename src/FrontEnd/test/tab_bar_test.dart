import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/navegacion/tab_bar.dart';

/// Último tab notificado por el callback (se reinicia en cada pump).
TabApp? _capturado;

Future<void> _pump(WidgetTester tester, {required TabApp activo}) async {
  _capturado = null;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      bottomNavigationBar: AppTabBar(
        activo: activo,
        onTab: (t) => _capturado = t,
      ),
    ),
  ));
}

/// Decoración del contenedor de un tab (RD §4: estados activo/inactivo).
BoxDecoration _decoTab(WidgetTester tester, TabApp tab) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byKey(ValueKey('tab-${tab.name}')),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as BoxDecoration;
}

/// Estilo del label de un tab.
TextStyle _estiloLabel(WidgetTester tester, TabApp tab) {
  final text = tester.widget<Text>(
    find.descendant(
      of: find.byKey(ValueKey('tab-${tab.name}')),
      matching: find.byType(Text),
    ),
  );
  return text.style!;
}

/// Color del ícono de un tab.
Color _colorIcono(WidgetTester tester, TabApp tab) {
  final icon = tester.widget<Icon>(
    find.descendant(
      of: find.byKey(ValueKey('tab-${tab.name}')),
      matching: find.byType(Icon),
    ),
  );
  return icon.color!;
}

void main() {
  group('AppTabBar (RD navegacion §4)', () {
    testWidgets('tab_bar_muestra_los_4_tabs_con_icono_y_label', (tester) async {
      await _pump(tester, activo: TabApp.inicio);

      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Mis reservas'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.byIcon(LucideIcons.home), findsOneWidget);
      expect(find.byIcon(LucideIcons.calendarCheck), findsOneWidget);
      expect(find.byIcon(LucideIcons.heart), findsOneWidget);
      expect(find.byIcon(LucideIcons.user), findsOneWidget);
    });

    testWidgets('tab_bar_estado_activo_tiene_pill_y_verde', (tester) async {
      await _pump(tester, activo: TabApp.inicio);

      final deco = _decoTab(tester, TabApp.inicio);
      expect(deco.color, AppColors.primarySoft);
      expect(deco.borderRadius, BorderRadius.circular(20));
      expect(_colorIcono(tester, TabApp.inicio), AppColors.primary);
      expect(_estiloLabel(tester, TabApp.inicio).color, AppColors.primary);
      expect(_estiloLabel(tester, TabApp.inicio).fontWeight, FontWeight.w600);
    });

    testWidgets('tab_bar_inactivo_gris_sin_fondo', (tester) async {
      await _pump(tester, activo: TabApp.inicio);

      expect(_decoTab(tester, TabApp.misReservas).color, isNull);
      expect(_colorIcono(tester, TabApp.misReservas), AppColors.text2);
      expect(_estiloLabel(tester, TabApp.misReservas).color, AppColors.text2);
      expect(
          _estiloLabel(tester, TabApp.misReservas).fontWeight, FontWeight.w500);
    });

    testWidgets('tab_bar_solo_un_tab_activo', (tester) async {
      await _pump(tester, activo: TabApp.favoritos);

      expect(_decoTab(tester, TabApp.favoritos).color, AppColors.primarySoft);
      expect(_decoTab(tester, TabApp.inicio).color, isNull);
      expect(_decoTab(tester, TabApp.misReservas).color, isNull);
      expect(_decoTab(tester, TabApp.perfil).color, isNull);
    });

    testWidgets('tab_bar_tocar_tab_notifica_cambio', (tester) async {
      await _pump(tester, activo: TabApp.inicio);

      await tester.tap(find.text('Favoritos'));
      expect(_capturado, TabApp.favoritos);

      await tester.tap(find.text('Mis reservas'));
      expect(_capturado, TabApp.misReservas);
    });

    testWidgets('tab_bar_medidas_y_estilo_de_la_pildora', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bg,
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: AppTabBar(
                activo: TabApp.inicio,
                onTab: (_) {},
              ),
            ),
          ),
        ),
      ));

      // Píldora 375×56 de diseño, 343×56 dentro de la zona (16 lateral).
      expect(tester.getSize(find.byType(AppTabBar)), const Size(343, 56));
      final deco = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AppTabBar),
              matching: find.byType(Container),
            )
            .first,
      ).decoration! as BoxDecoration;
      expect(deco.color, const Color(0xE6FFFFFF));
      expect(deco.borderRadius, BorderRadius.circular(28));
      final sombra = deco.boxShadow!.single;
      expect(sombra.color, const Color(0x1A0F172A));
      expect(sombra.offset, const Offset(0, 6));
      expect(sombra.blurRadius, 20);
    });
  });
}
