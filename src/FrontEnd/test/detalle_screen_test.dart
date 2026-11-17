import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/detalle/detalle_screen.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';

/// Rect del widget con `key: ValueKey(clave)`.
Rect _rect(WidgetTester tester, String clave) =>
    tester.getRect(find.byKey(ValueKey(clave)));

Future<void> _pumpDetalle(WidgetTester tester, {Cancha? cancha}) async {
  await tester.pumpWidget(MaterialApp(
    home: DetalleScreen(cancha: cancha ?? canchasSimuladas[0]),
  ));
}

void main() {
  group('DetalleScreen · hero e info (RD detalle-hero §4)', () {
    testWidgets('detalle_muestra_hero_botones_info_nombre_direccion',
        (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await _pumpDetalle(tester);

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('PREMIUM'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text(r'$45'), findsOneWidget);
      expect(find.text('por hora'), findsOneWidget);
      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Av. de los Deportes 123, Centro'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
      expect(find.byIcon(LucideIcons.share2), findsOneWidget);
      expect(find.byIcon(LucideIcons.heart), findsOneWidget);
      expect(find.byIcon(LucideIcons.star), findsOneWidget);
      expect(find.byIcon(LucideIcons.mapPin), findsOneWidget);
    });

    testWidgets('detalle_hero_botones_en_posicion', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await _pumpDetalle(tester);

      expect(tester.getSize(find.byType(Image)), const Size(375, 240));
      final hero = tester.getTopLeft(find.byType(Image));

      for (final (clave, dx) in [
        ('detalle-volver', 16.0),
        ('detalle-compartir', 269.0),
        ('detalle-favorito', 319.0),
      ]) {
        final boton = _rect(tester, clave);
        expect(boton.width, 40);
        expect(boton.height, 40);
        expect(boton.topLeft.dx - hero.dx, dx,
            reason: '$clave en x=$dx relativa al hero');
        expect(boton.topLeft.dy - hero.dy, 16,
            reason: '$clave en y=16 relativa al hero');
      }

      final deco =
          tester.widget<Container>(find.byKey(const ValueKey('detalle-volver')))
              .decoration! as BoxDecoration;
      expect(deco.color, AppColors.surface);
      expect(deco.borderRadius, BorderRadius.circular(20));
      final sombra = deco.boxShadow!.single;
      expect(sombra.color, const Color(0x260F172A));
      expect(sombra.offset, const Offset(0, 2));
      expect(sombra.blurRadius, 8);
      final icono =
          tester.widget<Icon>(find.byIcon(LucideIcons.chevronLeft));
      expect(icono.size, 19);
      expect(icono.color, AppColors.text);
    });

    testWidgets('detalle_estilos_del_mockup', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await _pumpDetalle(tester);

      // Badge PREMIUM: primary, radio 6, padding 5/9, texto 10 w700 blanco.
      final badgeBox = find
          .ancestor(
            of: find.text('PREMIUM'),
            matching: find.byType(Container),
          )
          .first;
      final decoBadge =
          tester.widget<Container>(badgeBox).decoration! as BoxDecoration;
      expect(decoBadge.color, AppColors.primary);
      expect(decoBadge.borderRadius, BorderRadius.circular(6));
      expect(
          tester.widget<Container>(badgeBox).padding,
          const EdgeInsets.symmetric(vertical: 5, horizontal: 9));
      final textoBadge = tester.widget<Text>(find.text('PREMIUM'));
      expect(textoBadge.style!.fontSize, 10);
      expect(textoBadge.style!.fontWeight, FontWeight.w700);
      expect(textoBadge.style!.color, Colors.white);
      expect(textoBadge.style!.letterSpacing, 0.8);

      // Rating: estrella 15 ámbar; valor 14 w600 text.
      final estrella = tester.widget<Icon>(find.byIcon(LucideIcons.star));
      expect(estrella.size, 15);
      expect(estrella.color, const Color(0xFFF59E0B));
      final valor = tester.widget<Text>(find.text('4.8'));
      expect(valor.style!.fontSize, 14);
      expect(valor.style!.fontWeight, FontWeight.w600);
      expect(valor.style!.color, AppColors.text);

      // Precio: monto 22 w700 primary; 'por hora' 11 text2.
      final monto = tester.widget<Text>(find.text(r'$45'));
      expect(monto.style!.fontSize, 22);
      expect(monto.style!.fontWeight, FontWeight.w700);
      expect(monto.style!.color, AppColors.primary);
      final unidad = tester.widget<Text>(find.text('por hora'));
      expect(unidad.style!.fontSize, 11);
      expect(unidad.style!.color, AppColors.text2);

      // Nombre 24 w700 text; pin 16 text2; dirección 14 text2.
      final nombre = tester.widget<Text>(find.text('Elite Arena Central'));
      expect(nombre.style!.fontSize, 24);
      expect(nombre.style!.fontWeight, FontWeight.w700);
      expect(nombre.style!.color, AppColors.text);
      final pin = tester.widget<Icon>(find.byIcon(LucideIcons.mapPin));
      expect(pin.size, 16);
      expect(pin.color, AppColors.text2);
      final direccion =
          tester.widget<Text>(find.text('Av. de los Deportes 123, Centro'));
      expect(direccion.style!.fontSize, 14);
      expect(direccion.style!.color, AppColors.text2);
    });

    testWidgets('detalle_sin_premium_oculta_el_badge', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await _pumpDetalle(tester, cancha: canchasSimuladas[2]);

      expect(find.text('PREMIUM'), findsNothing,
          reason: 'Cancha Municipal no es premium');
      expect(find.text('Cancha Municipal'), findsOneWidget);
      expect(find.text(r'$40'), findsOneWidget);
    });

    testWidgets('detalle_sin_overflow_375x844_y_chica', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
          home: DetalleScreen(cancha: canchasSimuladas[0])));
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(640, 1136);
      await tester.pumpWidget(MaterialApp(
          home: DetalleScreen(cancha: canchasSimuladas[0])));
      expect(tester.takeException(), isNull);
    });
  });
}
