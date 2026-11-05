import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/auth/registro_screen.dart';

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
}
