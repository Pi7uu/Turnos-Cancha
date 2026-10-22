import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/main.dart';

void main() {
  group('Pantalla de login (wireframe 04)', () {
    testWidgets('muestra todos los textos del wireframe', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());

      expect(find.text('TurnosCancha'), findsOneWidget);
      expect(find.text('Iniciá sesión'), findsOneWidget);
      expect(find.text('Reservá tu cancha en segundos'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('tu@email.com'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Tu contraseña'), findsOneWidget);
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
      expect(find.text('Ingresar'), findsOneWidget);
      expect(find.text('¿No tenés cuenta?'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);

      expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
      expect(find.byIcon(LucideIcons.mail), findsOneWidget);
      expect(find.byIcon(LucideIcons.lock), findsOneWidget);
      expect(find.byIcon(LucideIcons.eye), findsOneWidget);
    });

    testWidgets('login_ojo_alterna_visibilidad', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());

      final campos = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(campos, hasLength(2));
      expect(campos[1].obscureText, isTrue,
          reason: 'la contraseña arranca oculta');

      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pump();
      final visible = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(visible[1].obscureText, isFalse,
          reason: 'el ojo muestra la contraseña');
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.eyeOff));
      await tester.pump();
      final oculta = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(oculta[1].obscureText, isTrue,
          reason: 'el ojo vuelve a ocultarla');
      expect(find.byIcon(LucideIcons.eye), findsOneWidget);
    });

    testWidgets('login_sin_overflow_en_375x844_y_pantalla_chica',
        (tester) async {
      addTearDown(tester.view.reset);
      for (final size in const [Size(375, 844), Size(320, 568)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(const TurnosCanchaApp());
        expect(tester.takeException(), isNull,
            reason: 'sin excepciones de layout en '
                '${size.width}x${size.height}');
      }
    });

    testWidgets('login_links_no_navegan', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());

      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pumpAndSettle();
      expect(find.text('Iniciá sesión'), findsOneWidget,
          reason: 'el link de recuperación no navega');

      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();
      expect(find.text('Iniciá sesión'), findsOneWidget,
          reason: 'el link de crear cuenta no navega');
    });
  });
}
