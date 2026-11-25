import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/auth/login_screen.dart';
import 'package:turnos_cancha/features/navegacion/main_shell.dart';
import 'package:turnos_cancha/features/navegacion/tab_bar.dart';
import 'package:turnos_cancha/features/perfil/perfil_screen.dart';

Future<void> _pumpPerfil(WidgetTester tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: PerfilScreen()));
}

Future<void> _pumpShellEnPerfil(WidgetTester tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: MainShell()));
  await tester.tap(find.byKey(const ValueKey('tab-perfil')));
  await tester.pumpAndSettle();
}

Color? _colorTab(WidgetTester tester, String nombre) {
  final container = tester
      .widget<Container>(
        find
            .descendant(
              of: find.byKey(ValueKey('tab-$nombre')),
              matching: find.byType(Container),
            )
            .first,
      )
      .decoration! as BoxDecoration;
  return container.color;
}

void main() {
  group('PerfilScreen (RD perfil §4)', () {
    testWidgets('perfil_muestra_cuenta_y_stats', (tester) async {
      await _pumpPerfil(tester);

      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);
      expect(find.text('Martín Rodríguez'), findsOneWidget);
      expect(find.text('martin.rodriguez@gmail.com'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Reservas'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('Favoritas'), findsOneWidget);
      expect(find.text('340'), findsOneWidget);
      expect(find.text('Puntos'), findsOneWidget);
    });

    testWidgets('perfil_muestra_las_5_filas_del_menu', (tester) async {
      await _pumpPerfil(tester);

      for (final label in [
        'Mis datos',
        'Mis reservas',
        'Métodos de pago',
        'Notificaciones',
        'Ayuda',
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'fila $label');
      }
      expect(find.byIcon(LucideIcons.chevronRight), findsNWidgets(5));
      expect(find.byIcon(LucideIcons.user), findsOneWidget);
      expect(find.byIcon(LucideIcons.calendar), findsOneWidget);
      expect(find.byIcon(LucideIcons.creditCard), findsOneWidget);
      expect(find.byIcon(LucideIcons.bell), findsOneWidget);
      expect(find.byIcon(LucideIcons.circleQuestionMark), findsOneWidget);
    });

    testWidgets('perfil_boton_cerrar_sesion_visible', (tester) async {
      await _pumpPerfil(tester);

      expect(find.byIcon(LucideIcons.logOut), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
      final boton = find
          .ancestor(
            of: find.text('Cerrar sesión'),
            matching: find.byType(Container),
          )
          .first;
      final deco = tester.widget<Container>(boton).decoration! as BoxDecoration;
      expect(deco.color, const Color(0xFFFEE2E2));
      expect(deco.borderRadius, BorderRadius.circular(12));
      expect(tester.widget<Container>(boton).padding, const EdgeInsets.all(15));
    });
  });

  group('Acciones de Perfil (RD perfil RF-02)', () {
    testWidgets('cerrar_sesion_vuelve_al_login', (tester) async {
      await _pumpShellEnPerfil(tester);

      await tester.tap(find.byKey(const ValueKey('cerrar-sesion')));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(MainShell), findsNothing,
          reason: 'pushAndRemoveUntil limpia la pila: atrás no hay shell');
    });

    testWidgets('fila_mis_reservas_cambia_de_tab', (tester) async {
      await _pumpShellEnPerfil(tester);

      await tester.tap(find.byKey(const ValueKey('fila-mis-reservas')));
      await tester.pumpAndSettle();

      expect(find.text('Próximas'), findsOneWidget,
          reason: 'la fila Mis reservas cambia al tab Mis reservas');
      expect(_colorTab(tester, TabApp.misReservas.name), AppColors.primarySoft);
      expect(_colorTab(tester, TabApp.perfil.name), isNull);
    });

    testWidgets('las_4_filas_restantes_son_inertes', (tester) async {
      await _pumpShellEnPerfil(tester);

      for (final label in [
        'Mis datos',
        'Métodos de pago',
        'Notificaciones',
        'Ayuda',
      ]) {
        await tester.tap(find.text(label));
        await tester.pump();
      }

      expect(find.text('Martín Rodríguez'), findsOneWidget,
          reason: 'sigue en Perfil: las filas no navegan');
      expect(_colorTab(tester, TabApp.perfil.name), AppColors.primarySoft);
    });
  });
}
