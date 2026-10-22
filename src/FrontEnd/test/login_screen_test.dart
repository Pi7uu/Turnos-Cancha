import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/main.dart';

/// Ingresa credenciales y toca Ingresar (RF-03).
Future<void> _ingresar(
  WidgetTester tester,
  String email,
  String password,
) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), email);
  await tester.enterText(campos.at(1), password);
  await tester.tap(find.text('Ingresar'));
  await tester.pumpAndSettle();
}

/// Color del borde normal de un campo (índice 0 = email, 1 = contraseña).
Color _borde(WidgetTester tester, int index) {
  final campo = tester.widget<TextField>(find.byType(TextField).at(index));
  final borde = campo.decoration!.enabledBorder! as OutlineInputBorder;
  return borde.borderSide.color;
}

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

  group('Flujo de login (RF-03/04/05)', () {
    testWidgets('login_credenciales_correctas_navega_a_exito', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await _ingresar(tester, 'igpi7uu@gmail.com', 'igpi7uu');

      expect(find.text('usuario validado'), findsOneWidget);
      expect(find.text('Iniciá sesión'), findsNothing);
    });

    testWidgets('login_credenciales_incorrectas_muestra_estado_error',
        (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await _ingresar(tester, 'otro@gmail.com', 'otra');

      expect(find.text('El mail o la contraseña son incorrectos'),
          findsOneWidget);
      expect(_borde(tester, 0), AppColors.danger,
          reason: 'email con borde rojo');
      expect(_borde(tester, 1), AppColors.danger,
          reason: 'contraseña con borde rojo');
      expect(find.text('Ingresar'), findsOneWidget,
          reason: 'el botón sigue visible');
    });

    testWidgets('login_campos_vacios_muestra_estado_error', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await _ingresar(tester, '', '');

      expect(find.text('El mail o la contraseña son incorrectos'),
          findsOneWidget);
      expect(_borde(tester, 0), AppColors.danger);
      expect(_borde(tester, 1), AppColors.danger);
    });

    testWidgets('login_email_case_insensitive_y_trim_navega_a_exito',
        (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await _ingresar(tester, '  IgPi7Uu@GmAiL.com ', 'igpi7uu');

      expect(find.text('usuario validado'), findsOneWidget);
    });

    testWidgets('login_escribir_en_email_limpia_error', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await _ingresar(tester, 'x', 'x');
      expect(find.text('El mail o la contraseña son incorrectos'),
          findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'nuevo@x.com');
      await tester.pump();

      expect(find.text('El mail o la contraseña son incorrectos'),
          findsNothing);
      expect(_borde(tester, 0), AppColors.border,
          reason: 'borde del email vuelve a la normalidad');
    });

    testWidgets('login_escribir_en_password_limpia_error', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await _ingresar(tester, 'x', 'x');
      expect(find.text('El mail o la contraseña son incorrectos'),
          findsOneWidget);

      await tester.enterText(find.byType(TextField).at(1), 'abc');
      await tester.pump();

      expect(find.text('El mail o la contraseña son incorrectos'),
          findsNothing);
      expect(_borde(tester, 1), AppColors.border,
          reason: 'borde de la contraseña vuelve a la normalidad');
    });

    testWidgets('login_reintento_incorrecto_vuelve_a_mostrar_error',
        (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await _ingresar(tester, 'x', 'x');
      await tester.enterText(find.byType(TextField).at(0), 'a@b.com');
      await tester.pump();
      expect(find.text('El mail o la contraseña son incorrectos'),
          findsNothing);

      await _ingresar(tester, 'a@b.com', 'mal');
      expect(find.text('El mail o la contraseña son incorrectos'),
          findsOneWidget,
          reason: 'un nuevo intento incorrecto muestra el error otra vez');
    });

    testWidgets('login_teclado_dispara_validacion', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());
      await tester.enterText(
          find.byType(TextField).at(0), 'igpi7uu@gmail.com');
      await tester.enterText(find.byType(TextField).at(1), 'igpi7uu');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('usuario validado'), findsOneWidget,
          reason: 'enviar desde el teclado valida igual que el botón');
    });
  });
}
