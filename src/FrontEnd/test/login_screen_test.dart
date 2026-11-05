import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/auth/usuarios_locales.dart';
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

/// Abre la 05 desde el footer "Crear cuenta" de la 04 (RF-05).
Future<void> _abrirRegistroDesdeLogin(WidgetTester tester) async {
  await tester.pumpWidget(const TurnosCanchaApp());
  await tester.tap(find.text('Crear cuenta'));
  await tester.pumpAndSettle();
}

/// Rellena los 4 campos de la 05 en orden (RF-01): nombre, email,
/// contraseña y repetir.
Future<void> _completarRegistro(
  WidgetTester tester, {
  String nombre = 'Marta Gómez',
  String email = 'marta@test.com',
  String password = 'qwerty1234',
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), nombre);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), password);
  await tester.enterText(campos.at(3), password);
  await tester.pump();
}

/// Marca el checkbox de términos tocando su texto (RF-07).
Future<void> _marcarTerminos(WidgetTester tester) async {
  final texto = find.text(
    'Acepto los términos y condiciones y la política de privacidad',
  );
  await tester.ensureVisible(texto);
  await tester.pumpAndSettle();
  await tester.tap(texto);
  await tester.pump();
}

/// Toca el botón principal de la 05 (el titular repite el texto).
Future<void> _tocarCrearCuentaDelRegistro(WidgetTester tester) async {
  final boton = find.widgetWithText(FilledButton, 'Crear cuenta');
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
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

    testWidgets('login_sin_overflow_en_landscape_con_teclado',
        (tester) async {
      addTearDown(tester.view.reset);
      // Viewport landscape del emulador (2400x1080 físicos @1.0) y su versión
      // con teclado completo: el body efectivo queda en ~142 lógicos de alto.
      for (final size in const [Size(2400, 1080), Size(2400, 142)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(const TurnosCanchaApp());
        expect(tester.takeException(), isNull,
            reason: 'sin overflow en landscape '
                '${size.width}x${size.height}');
      }
    });

    testWidgets('login_link_recuperacion_no_navega', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());

      // El único link de la 04 sin funcionalidad (spec §3 fuera de alcance):
      // sigue en la 04 y no empuja la 05 (el footer "Crear cuenta" sí navega,
      // cubierto por el grupo de integración RF-05).
      await tester.tap(find.text('¿Olvidaste tu contraseña?'));
      await tester.pumpAndSettle();

      expect(find.text('Reservá tu cancha en segundos'), findsOneWidget,
          reason: 'el link de recuperación no navega: sigue en la 04');
      expect(find.text('Nombre y apellido'), findsNothing,
          reason: 'no se empujó la pantalla 05');
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

  group('Login · integración con la 05 (RF-05/08)', () {
    setUp(resetUsuarios);
    tearDown(resetUsuarios);

    testWidgets('login_crear_cuenta_navega_a_la_pantalla_05', (tester) async {
      await tester.pumpWidget(const TurnosCanchaApp());

      // En la 04 el link del footer es único.
      expect(find.text('Crear cuenta'), findsOneWidget);
      await tester.tap(find.text('Crear cuenta'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre y apellido'), findsOneWidget,
          reason: 'la 05 muestra sus campos');
      expect(
        find.text(
          'Acepto los términos y condiciones y la política de privacidad',
        ),
        findsOneWidget,
      );
      expect(find.text('¿Ya tenés cuenta?'), findsOneWidget,
          reason: 'footer de la 05');
    });

    testWidgets('login_volver_desde_la_05_footer_inicia_sesion_retorna',
        (tester) async {
      await _abrirRegistroDesdeLogin(tester);
      expect(find.text('Nombre y apellido'), findsOneWidget,
          reason: 'estamos en la 05');

      // Escribir en la 05 no debe prefillear el email de la 04.
      await tester.enterText(find.byType(TextField).at(1), 'algo@test.com');

      final volver = find.text('Iniciá sesión');
      await tester.ensureVisible(volver);
      await tester.pumpAndSettle();
      await tester.tap(volver);
      await tester.pumpAndSettle();

      expect(find.text('Reservá tu cancha en segundos'), findsOneWidget,
          reason: 'volvió a la 04');
      expect(find.text('Iniciá sesión'), findsOneWidget);
      final email = tester.widget<TextField>(find.byType(TextField).at(0));
      expect(email.controller!.text, isEmpty,
          reason: 'la 04 vuelve vacía, sin prefill');
      expect(find.text('Cuenta creada'), findsNothing,
          reason: 'volver sin registrar no muestra el aviso');
    });

    testWidgets('login_registro_exitoso_muestra_cuenta_creada_y_login_vacio',
        (tester) async {
      await _abrirRegistroDesdeLogin(tester);

      await _completarRegistro(tester);
      await _marcarTerminos(tester);
      await _tocarCrearCuentaDelRegistro(tester);

      // El pop vuelve a la 04 y dispara la SnackBar; se pumpea la entrada en
      // vez de pumpAndSettle para poder verla antes de que se autodestruya.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Cuenta creada'), findsOneWidget,
          reason: 'aviso de éxito sobre la 04 (RF-05)');
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
        SnackBarBehavior.floating,
      );
      expect(find.text('Reservá tu cancha en segundos'), findsOneWidget,
          reason: 'la SnackBar vive en la 04');
      expect(tester.widget<TextField>(find.byType(TextField).at(0))
          .controller!.text, isEmpty);
      expect(tester.widget<TextField>(find.byType(TextField).at(1))
          .controller!.text, isEmpty);
    });

    testWidgets('login_acepta_usuario_registrado_end_to_end', (tester) async {
      await _abrirRegistroDesdeLogin(tester);

      await _completarRegistro(tester);
      await _marcarTerminos(tester);
      await _tocarCrearCuentaDelRegistro(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(emailRegistrado('marta@test.com'), isTrue,
          reason: 'el alta quedó en la lista local');

      // Se ingresa con la cuenta recién creada desde la 04.
      await _ingresar(tester, 'marta@test.com', 'qwerty1234');

      expect(find.text('usuario validado'), findsOneWidget,
          reason: 'RF-06: los usuarios registrados también pueden entrar');
    });
  });
}
