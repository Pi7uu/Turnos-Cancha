import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/auth/registro_screen.dart';
import 'package:turnos_cancha/features/auth/usuarios_locales.dart';

/// Arma un `MaterialApp` con una pantalla-puerta que empuja la 05 y guarda
/// el resultado del `Navigator.push<bool>` (null si se vuelve sin registrar).
Future<void> _pumpConPuerta(
  WidgetTester tester,
  void Function(bool?) guardaResultado,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                final resultado = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute<bool>(
                    builder: (_) => const RegistroScreen(),
                  ),
                );
                guardaResultado(resultado);
              },
              child: const Text('Abrir 05'),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Decoración del contenedor 20×20 del checkbox de términos (RD §4).
BoxDecoration _estadoCheckbox(WidgetTester tester) {
  final contenedor = tester.widget<Container>(
    find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.constraints != null &&
          widget.constraints!.maxWidth == 20 &&
          widget.constraints!.maxHeight == 20,
    ),
  );
  return contenedor.decoration! as BoxDecoration;
}

/// Los 4 campos de la 05, en orden (nombre, email, contraseña, repetir).
List<TextField> _campos(WidgetTester tester) =>
    tester.widgetList<TextField>(find.byType(TextField)).toList();

/// Borde habilitado del campo [index] (0..3).
OutlineInputBorder _bordeCampo(WidgetTester tester, int index) {
  final campo = _campos(tester)[index];
  return campo.decoration!.enabledBorder! as OutlineInputBorder;
}

/// `true` si el campo [index] está marcado con el borde de error.
bool _campoEnError(WidgetTester tester, int index) =>
    _bordeCampo(tester, index).borderSide.color == AppColors.danger;

/// Busca un mensaje de error inline (13 semibold `danger`), no el hint ni el
/// texto de ayuda (RD §4: `Mínimo 8 caracteres` también es el placeholder).
Finder _mensajeError(String texto) => find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == texto &&
          widget.style?.fontSize == 13 &&
          widget.style?.fontWeight == FontWeight.w600 &&
          widget.style?.color == AppColors.danger,
    );

/// Abre la 05 desde la pantalla-puerta.
Future<void> _abrirRegistro(WidgetTester tester) async {
  await _pumpConPuerta(tester, (_) {});
  await tester.tap(find.text('Abrir 05'));
  await tester.pumpAndSettle();
}

/// Toca el botón principal (no el titular, que repite el texto).
Future<void> _tocarCrearCuenta(WidgetTester tester) async {
  final boton = find.widgetWithText(FilledButton, 'Crear cuenta');
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

/// Rellena los 4 campos en orden; [repetir] permite forzar la diferencia.
Future<void> _completarFormulario(
  WidgetTester tester, {
  String nombre = 'Marta Gómez',
  String email = 'marta@test.com',
  String password = 'qwerty1234',
  String? repetir,
}) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), nombre);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), password);
  await tester.enterText(campos.at(3), repetir ?? password);
  await tester.pump();
}

/// Marca el checkbox tocando el texto de términos (RF-07).
Future<void> _marcarTerminos(WidgetTester tester) async {
  final texto = find.text(
    'Acepto los términos y condiciones y la política de privacidad',
  );
  await tester.ensureVisible(texto);
  await tester.pumpAndSettle();
  await tester.tap(texto);
  await tester.pump();
}

void main() {
  group('Pantalla de registro (mockup 05)', () {
    testWidgets('registro_muestra_todos_los_textos_del_mockup', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegistroScreen()),
      );

      expect(find.text('Crear cuenta'), findsNWidgets(2),
          reason: 'titular + botón principal');
      expect(find.text('Creá tu cuenta y empezá a reservar'), findsOneWidget);
      expect(find.text('Nombre y apellido'), findsOneWidget);
      expect(find.text('Tu nombre completo'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('tu@email.com'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
      expect(find.text('Usá 8 caracteres como mínimo'), findsOneWidget);
      expect(find.text('Repetir contraseña'), findsOneWidget);
      expect(find.text('Repetí tu contraseña'), findsOneWidget);
      expect(
        find.text(
          'Acepto los términos y condiciones y la política de privacidad',
        ),
        findsOneWidget,
      );
      expect(find.text('¿Ya tenés cuenta?'), findsOneWidget);
      expect(find.text('Iniciá sesión'), findsOneWidget);

      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
      expect(find.byIcon(LucideIcons.user), findsOneWidget);
      expect(find.byIcon(LucideIcons.mail), findsOneWidget);
      expect(find.byIcon(LucideIcons.lock), findsNWidgets(2));
      expect(find.byIcon(LucideIcons.eye), findsNWidgets(2));
    });

    testWidgets('registro_los_4_campos_con_los_placeholder_correctos',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegistroScreen()),
      );

      final campos = _campos(tester);
      expect(campos, hasLength(4));

      // RD §4: los 4 inputs con padding vertical 13 / horizontal 16.
      for (final campo in campos) {
        expect(
          campo.decoration!.contentPadding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          reason: 'padding del input según RD §4',
        );
      }

      // RD §4: íconos lucide 18px `text2`.
      expect(tester.widget<Icon>(find.byIcon(LucideIcons.user)).size, 18);
      expect(tester.widget<Icon>(find.byIcon(LucideIcons.user)).color,
          AppColors.text2);
      expect(tester.widget<Icon>(find.byIcon(LucideIcons.mail)).size, 18);
      expect(tester.widget<Icon>(find.byIcon(LucideIcons.mail)).color,
          AppColors.text2);
      final candados = tester.widgetList<Icon>(find.byIcon(LucideIcons.lock));
      expect(candados, hasLength(2));
      for (final candado in candados) {
        expect(candado.size, 18, reason: 'ícono lock 18px (RD §4)');
        expect(candado.color, AppColors.text2);
      }

      expect(campos[0].decoration!.hintText, 'Tu nombre completo');
      expect(campos[0].keyboardType, TextInputType.text);
      expect(campos[0].textInputAction, TextInputAction.next);

      expect(campos[1].decoration!.hintText, 'tu@email.com');
      expect(campos[1].keyboardType, TextInputType.emailAddress);
      expect(campos[1].textInputAction, TextInputAction.next);

      expect(campos[2].decoration!.hintText, 'Mínimo 8 caracteres');
      expect(campos[2].keyboardType, TextInputType.visiblePassword);
      expect(campos[2].textInputAction, TextInputAction.next);
      expect(campos[2].obscureText, isTrue,
          reason: 'la contraseña arranca oculta');

      expect(campos[3].decoration!.hintText, 'Repetí tu contraseña');
      expect(campos[3].keyboardType, TextInputType.visiblePassword);
      expect(campos[3].textInputAction, TextInputAction.done);
      expect(campos[3].obscureText, isTrue,
          reason: 'repetir contraseña arranca oculta');
    });

    testWidgets('registro_ojos_independientes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegistroScreen()),
      );

      // Primer ojo (campo Contraseña): solo se muestra esa contraseña.
      await tester.tap(find.byIcon(LucideIcons.eye).first);
      await tester.pump();

      var campos = _campos(tester);
      expect(campos[2].obscureText, isFalse,
          reason: 'el ojo del campo 3 muestra su contraseña');
      expect(campos[3].obscureText, isTrue,
          reason: 'el campo 4 sigue oculto');
      expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);
      expect(find.byIcon(LucideIcons.eye), findsOneWidget);

      // Segundo ojo (campo Repetir): ahora ambos visibles, sin perder el 3.
      await tester.tap(find.byIcon(LucideIcons.eye));
      await tester.pump();

      campos = _campos(tester);
      expect(campos[2].obscureText, isFalse,
          reason: 'el campo 3 sigue visible');
      expect(campos[3].obscureText, isFalse,
          reason: 'el ojo del campo 4 muestra su contraseña');
      expect(find.byIcon(LucideIcons.eyeOff), findsNWidgets(2));
    });

    testWidgets('registro_checkbox_alterna', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegistroScreen()),
      );

      final desmarcado = _estadoCheckbox(tester);
      expect(desmarcado.color, AppColors.surface,
          reason: 'arranca desmarcado');
      expect(desmarcado.border!.top.color, AppColors.border);
      expect(find.byIcon(LucideIcons.check), findsNothing);

      final textTerminos = find.text(
        'Acepto los términos y condiciones y la política de privacidad',
      );
      await tester.ensureVisible(textTerminos);
      await tester.pumpAndSettle();
      await tester.tap(textTerminos);
      await tester.pump();

      final marcado = _estadoCheckbox(tester);
      expect(marcado.color, AppColors.primary,
          reason: 'tocar el texto marca el checkbox');
      expect(find.byIcon(LucideIcons.check), findsOneWidget);

      await tester.ensureVisible(textTerminos);
      await tester.pumpAndSettle();
      await tester.tap(textTerminos);
      await tester.pump();

      final otraVez = _estadoCheckbox(tester);
      expect(otraVez.color, AppColors.surface,
          reason: 'tocar de nuevo lo desmarca');
      expect(otraVez.border!.top.color, AppColors.border);
      expect(find.byIcon(LucideIcons.check), findsNothing);
    });

    testWidgets('registro_tap_fuera_descarta_foco_sin_validar',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegistroScreen()),
      );

      final campoEmail = find.byType(TextField).at(1);
      await tester.tap(campoEmail);
      await tester.pump();
      await tester.enterText(campoEmail, 'algo');
      await tester.pump();

      EditableText editableEmail() =>
          tester.widget<EditableText>(find.byType(EditableText).at(1));

      expect(editableEmail().focusNode.hasFocus, isTrue,
          reason: 'escribir deja el foco en el campo');

      // Tap fuera del formulario (subtítulo): descarta el teclado.
      await tester.tap(find.text('Creá tu cuenta y empezá a reservar'));
      await tester.pump();

      expect(editableEmail().focusNode.hasFocus, isFalse,
          reason: 'tocar fuera descarta el foco del campo');
      expect(find.text('algo'), findsOneWidget,
          reason: 'lo escrito no se pierde al descartar el teclado');
      expect(find.text('Ingresá un email válido'), findsNothing,
          reason: 'tap fuera no dispara la validación');
      expect(find.text('Ingresá tu nombre'), findsNothing);
    });

    testWidgets('registro_volver_y_footer_retornan_sin_datos',
        (tester) async {
      bool? resultado;
      await _pumpConPuerta(tester, (valor) => resultado = valor);

      // Volver con el chevron: regresa al home sin datos.
      await tester.tap(find.text('Abrir 05'));
      await tester.pumpAndSettle();
      expect(find.text('Crear cuenta'), findsNWidgets(2));

      await tester.tap(find.byIcon(LucideIcons.chevronLeft));
      await tester.pumpAndSettle();
      expect(find.text('Abrir 05'), findsOneWidget);
      expect(resultado, isNull);

      // Footer "Iniciá sesión": también vuelve, aunque haya datos escritos.
      resultado = true; // centinela: el pop debe dejarlo en null
      await tester.tap(find.text('Abrir 05'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), 'algo');
      await tester.ensureVisible(find.text('Iniciá sesión'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciá sesión'));
      await tester.pumpAndSettle();

      expect(find.text('Abrir 05'), findsOneWidget);
      expect(resultado, isNull, reason: 'volver no registra nada');
    });

    testWidgets('registro_sin_overflow_375x844_y_chica', (tester) async {
      addTearDown(tester.view.reset);
      for (final size in const [Size(375, 844), Size(320, 568)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(
          const MaterialApp(home: RegistroScreen()),
        );
        expect(tester.takeException(), isNull,
            reason: 'sin excepciones de layout en '
                '${size.width}x${size.height}');
      }
    });
  });

  group('Registro · validación inline y alta (RF-01..08)', () {
    setUp(resetUsuarios);

    testWidgets('registro_submit_vacio_muestra_errores_por_campo',
        (tester) async {
      await _abrirRegistro(tester);
      await _tocarCrearCuenta(tester);

      expect(_mensajeError('Ingresá tu nombre'), findsOneWidget);
      expect(_mensajeError('Ingresá un email válido'), findsOneWidget);
      expect(_mensajeError('Mínimo 8 caracteres'), findsOneWidget,
          reason: 'error de contraseña, no el placeholder');
      expect(_mensajeError('Aceptá los términos y condiciones'), findsOneWidget);
      expect(_mensajeError('Las contraseñas no coinciden'), findsNothing,
          reason: 'RF-03: dos contraseñas vacías coinciden');

      // Campos ofensivos: nombre, email y contraseña con borde `danger` 1.5px.
      for (final indice in const [0, 1, 2]) {
        expect(_campoEnError(tester, indice), isTrue,
            reason: 'campo $indice con borde de error');
        expect(_bordeCampo(tester, indice).borderSide.width, 1.5,
            reason: 'RD §4: borde danger 1.5px');
      }
      // Repetir vacío coincide con contraseña vacía: sin error.
      expect(_campoEnError(tester, 3), isFalse);
      expect(_bordeCampo(tester, 3).borderSide.color, AppColors.border);
    });

    testWidgets('registro_email_duplicado_muestra_error_semilla',
        (tester) async {
      await _abrirRegistro(tester);
      await _completarFormulario(tester, email: ' igpi7uu@gmail.com ');
      await _marcarTerminos(tester);
      await _tocarCrearCuenta(tester);

      expect(_mensajeError('Ya hay una cuenta con ese email'), findsOneWidget,
          reason: 'duplicado contra el usuario semilla, con trim');
      expect(_campoEnError(tester, 1), isTrue);
      for (final indice in const [0, 2, 3]) {
        expect(_campoEnError(tester, indice), isFalse,
            reason: 'el campo $indice es válido');
      }
      expect(find.text('Crear cuenta'), findsNWidgets(2),
          reason: 'sigue en la 05: no registra ni navega');
      expect(emailRegistrado('igpi7uu@gmail.com'), isTrue);
    });

    testWidgets('registro_escribir_limpia_solo_su_error', (tester) async {
      await _abrirRegistro(tester);
      await _completarFormulario(
        tester,
        nombre: '',
        email: '',
        password: 'corta',
        repetir: 'distinta',
      );
      await _tocarCrearCuenta(tester);

      // Los 5 errores a la vez (4 campos + checkbox).
      expect(_mensajeError('Ingresá tu nombre'), findsOneWidget);
      expect(_mensajeError('Ingresá un email válido'), findsOneWidget);
      expect(_mensajeError('Mínimo 8 caracteres'), findsOneWidget);
      expect(_mensajeError('Las contraseñas no coinciden'), findsOneWidget);
      expect(_mensajeError('Aceptá los términos y condiciones'), findsOneWidget);

      // Escribir en email limpia SOLO el error de email (RF-02/RF-03).
      await tester.enterText(find.byType(TextField).at(1), 'nueva@test.com');
      await tester.pump();

      expect(_mensajeError('Ingresá un email válido'), findsNothing);
      expect(_campoEnError(tester, 1), isFalse);
      expect(_bordeCampo(tester, 1).borderSide.color, AppColors.border);

      expect(_mensajeError('Ingresá tu nombre'), findsOneWidget,
          reason: 'el error de nombre sigue');
      expect(_mensajeError('Las contraseñas no coinciden'), findsOneWidget,
          reason: 'el error de repetir sigue');
      expect(_mensajeError('Aceptá los términos y condiciones'), findsOneWidget,
          reason: 'el error del checkbox sigue');
    });

    testWidgets('registro_checkbox_error_limpia_solo_marcando',
        (tester) async {
      await _abrirRegistro(tester);
      await _completarFormulario(tester);
      await _tocarCrearCuenta(tester);

      expect(_mensajeError('Aceptá los términos y condiciones'), findsOneWidget);
      for (var indice = 0; indice < 4; indice++) {
        expect(_campoEnError(tester, indice), isFalse,
            reason: 'los campos son válidos');
      }

      // Escribir en los 4 campos no limpia el error del checkbox.
      await _completarFormulario(
        tester,
        nombre: 'Marta Gómez ',
        email: 'otra@test.com',
      );
      expect(_mensajeError('Aceptá los términos y condiciones'), findsOneWidget,
          reason: 'RF-07: solo marcar lo limpia');

      // Marcarlo sí lo limpia.
      await _marcarTerminos(tester);
      expect(_mensajeError('Aceptá los términos y condiciones'), findsNothing);
    });

    testWidgets('registro_submit_valido_registra_y_vuelve_true',
        (tester) async {
      bool? resultado;
      await _pumpConPuerta(tester, (valor) => resultado = valor);
      await tester.tap(find.text('Abrir 05'));
      await tester.pumpAndSettle();

      await _completarFormulario(tester, email: 'nueva@test.com');
      await _marcarTerminos(tester);
      await _tocarCrearCuenta(tester);

      expect(find.text('Abrir 05'), findsOneWidget,
          reason: 'volvió a la pantalla anterior');
      expect(resultado, isTrue, reason: 'pop(true) para el aviso de éxito');
      expect(emailRegistrado('nueva@test.com'), isTrue,
          reason: 'el usuario quedó en la lista local');

      final usuario = usuarioPorEmail('nueva@test.com');
      expect(usuario?.nombre, 'Marta Gómez');
      expect(usuario?.password, 'qwerty1234');
    });

    testWidgets('registro_teclado_done_en_repetir_dispara_validacion',
        (tester) async {
      await _abrirRegistro(tester);
      await tester.tap(find.byType(TextField).at(3));
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(_mensajeError('Ingresá tu nombre'), findsOneWidget,
          reason: 'done en Repetir valida igual que el botón');
      expect(_mensajeError('Ingresá un email válido'), findsOneWidget);
      expect(_mensajeError('Aceptá los términos y condiciones'), findsOneWidget);
    });

    testWidgets('registro_campos_misma_altura_con_y_sin_errores',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistroScreen()));

      List<double> alturas() => [
            for (var indice = 0; indice < 4; indice++)
              tester.getSize(find.byType(TextField).at(indice)).height,
          ];

      expect(alturas().toSet(), hasLength(1),
          reason: 'el IconButton del ojo no infla el input');

      await _tocarCrearCuenta(tester);
      expect(alturas().toSet(), hasLength(1),
          reason: 'la altura no cambia con errores visibles');
    });

    testWidgets('registro_sin_overflow_con_errores_375x844_y_chica',
        (tester) async {
      addTearDown(tester.view.reset);
      for (final size in const [Size(375, 844), Size(320, 568)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        await tester.pumpWidget(
          const MaterialApp(home: RegistroScreen()),
        );
        await _tocarCrearCuenta(tester);

        expect(tester.takeException(), isNull,
            reason: 'sin overflow con errores en '
                '${size.width}x${size.height}');
        expect(find.text('Ingresá tu nombre'), findsOneWidget);
      }
    });
  });
}
