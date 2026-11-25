import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';
import 'package:turnos_cancha/features/reserva/reserva_error_screen.dart';

Future<void> _pumpError(WidgetTester tester,
    {Cancha? cancha, String fecha = 'Mar, 15 oct', String hora = '18:00'}) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: ReservaErrorScreen(
      cancha: cancha ?? canchasSimuladas[0],
      fecha: fecha,
      hora: hora,
    ),
  ));
}

void main() {
  group('ReservaErrorScreen (RD reserva-error §4)', () {
    testWidgets('error_muestra_titulo_subtitulo_card_nota_y_botones',
        (tester) async {
      await _pumpError(tester, cancha: canchasSimuladas[0], hora: '18:00');

      expect(find.byIcon(LucideIcons.x), findsOneWidget);
      expect(find.text('No se pudo completar la reserva'), findsOneWidget);
      expect(
          find.text(
              'La cancha Elite Arena Central del 15 de octubre a las 18:00 ya fue reservada por otro usuario.'),
          findsOneWidget);
      expect(find.text('MOTIVO'), findsOneWidget);
      expect(find.text('Horario ocupado'), findsOneWidget);
      expect(find.text('ESTADO DE PAGO'), findsOneWidget);
      expect(find.text('SIN COBRO'), findsOneWidget);
      expect(find.text('ALTERNATIVAS'), findsOneWidget);
      expect(find.text('2 canchas libres'), findsOneWidget);
      expect(find.text('Te avisamos por email en cuanto se libere un horario.'),
          findsOneWidget);
      expect(find.text('Elegir otro horario'), findsOneWidget);
      expect(find.text('Volver al inicio'), findsOneWidget);
    });

    testWidgets('error_alternativas_derivadas', (tester) async {
      // Elite 18:00 → Skyline y Municipal libres → 2.
      await _pumpError(tester, cancha: canchasSimuladas[0], hora: '18:00');
      expect(find.text('2 canchas libres'), findsOneWidget);

      // Skyline 21:00 → Elite la tiene ocupada, Municipal libre → 1 (singular).
      await _pumpError(tester, cancha: canchasSimuladas[1], hora: '21:00');
      expect(find.text('1 cancha libre'), findsOneWidget);
    });

    testWidgets('error_estilos_del_mockup', (tester) async {
      await _pumpError(tester);

      // Círculo: #FEE2E2, 96×96, radio 48; cruz 46 danger.
      final circulo = find
          .ancestor(
            of: find.byIcon(LucideIcons.x),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(circulo), const Size(96, 96));
      final decoCirculo =
          tester.widget<Container>(circulo).decoration! as BoxDecoration;
      expect(decoCirculo.color, const Color(0xFFFEE2E2));
      expect(decoCirculo.borderRadius, BorderRadius.circular(48));
      final cruz = tester.widget<Icon>(find.byIcon(LucideIcons.x));
      expect(cruz.size, 46);
      expect(cruz.color, AppColors.danger);

      // Título y subtítulo.
      final titulo =
          tester.widget<Text>(find.text('No se pudo completar la reserva'));
      expect(titulo.style!.fontSize, 24);
      expect(titulo.style!.fontWeight, FontWeight.w700);
      expect(titulo.style!.color, AppColors.text);
      final subtitulo = tester.widget<Text>(find.textContaining(
          'ya fue reservada por otro usuario.'));
      expect(subtitulo.style!.fontSize, 15);
      expect(subtitulo.style!.color, AppColors.text2);
      expect(subtitulo.style!.height, 1.5);

      // Card + filas.
      final card = find
          .ancestor(
            of: find.text('MOTIVO'),
            matching: find.byType(Container),
          )
          .first;
      final decoCard =
          tester.widget<Container>(card).decoration! as BoxDecoration;
      expect(decoCard.color, AppColors.surface);
      expect(decoCard.borderRadius, BorderRadius.circular(16));
      expect(decoCard.border!.top.color, AppColors.border);
      expect(decoCard.border!.top.width, 1);

      for (final label in ['MOTIVO', 'ESTADO DE PAGO', 'ALTERNATIVAS']) {
        final t = tester.widget<Text>(find.text(label));
        expect(t.style!.fontSize, 11);
        expect(t.style!.fontWeight, FontWeight.w600);
        expect(t.style!.letterSpacing, 1);
        expect(t.style!.color, AppColors.text2);
      }
      final motivo = tester.widget<Text>(find.text('Horario ocupado'));
      expect(motivo.style!.fontSize, 14);
      expect(motivo.style!.fontWeight, FontWeight.w700);
      expect(motivo.style!.color, AppColors.text);

      // Badge SIN COBRO.
      final badge = find
          .ancestor(
            of: find.text('SIN COBRO'),
            matching: find.byType(Container),
          )
          .first;
      final decoBadge =
          tester.widget<Container>(badge).decoration! as BoxDecoration;
      expect(decoBadge.color, AppColors.primarySoft);
      expect(decoBadge.borderRadius, BorderRadius.circular(6));
      expect(tester.widget<Container>(badge).padding,
          const EdgeInsets.symmetric(vertical: 5, horizontal: 9));
      final textoBadge = tester.widget<Text>(find.text('SIN COBRO'));
      expect(textoBadge.style!.fontSize, 10);
      expect(textoBadge.style!.fontWeight, FontWeight.w700);
      expect(textoBadge.style!.letterSpacing, 0.5);
      expect(textoBadge.style!.color, AppColors.primary);

      // Alternativas + nota + botones.
      final alt = tester.widget<Text>(find.text('2 canchas libres'));
      expect(alt.style!.fontSize, 14);
      expect(alt.style!.fontWeight, FontWeight.w700);
      expect(alt.style!.color, AppColors.primary);
      final nota = tester.widget<Text>(
          find.text('Te avisamos por email en cuanto se libere un horario.'));
      expect(nota.style!.fontSize, 13);
      expect(nota.style!.color, AppColors.text2);
      final primario = tester.widget<Text>(find.text('Elegir otro horario'));
      expect(primario.style!.fontSize, 16);
      expect(primario.style!.fontWeight, FontWeight.w600);
      final btnPrimario = tester.widget<FilledButton>(
          find.byKey(const ValueKey('error-elegir-otro')));
      expect(btnPrimario.style!.foregroundColor!.resolve(const <WidgetState>{}),
          Colors.white);
      final secundario = tester.widget<Text>(find.text('Volver al inicio'));
      expect(secundario.style!.fontSize, 16);
      expect(secundario.style!.fontWeight, FontWeight.w600);
      final btnSecundario = tester.widget<OutlinedButton>(
          find.byKey(const ValueKey('error-volver')));
      expect(btnSecundario.style!.foregroundColor!.resolve(const <WidgetState>{}),
          AppColors.text);
    });

    testWidgets('error_elegir_otro_horario_hace_pop', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReservaErrorScreen(
                      cancha: canchasSimuladas[0],
                      fecha: 'Mar, 15 oct',
                      hora: '18:00',
                    ),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('No se pudo completar la reserva'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('error-elegir-otro')));
      await tester.pumpAndSettle();

      expect(find.text('abrir'), findsOneWidget,
          reason: 'la ruta se desapiló ( pop )');
      expect(find.text('No se pudo completar la reserva'), findsNothing);
    });

    testWidgets('error_sin_overflow_375x844_y_chica', (tester) async {
      await _pumpError(tester);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(MaterialApp(
        home: ReservaErrorScreen(
          cancha: canchasSimuladas[0],
          fecha: 'Mar, 15 oct',
          hora: '18:00',
        ),
      ));
      expect(tester.takeException(), isNull);
    });
  });
}
