import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';
import 'package:turnos_cancha/features/navegacion/main_shell.dart';

/// Decoración del card de la cancha [nombre] ( key `cancha-<nombre>` ).
BoxDecoration _decoCard(WidgetTester tester, String nombre) {
  final container = tester.widget<Container>(
    find.byKey(ValueKey('cancha-$nombre')),
  );
  return container.decoration! as BoxDecoration;
}

/// Observador que cuenta los push ( card / Reservar / Ver todo no navegan ).
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
  group('InicioScreen · canchas (RD inicio-canchas §4)', () {
    testWidgets('canchas_muestra_titulo_ver_todo_y_3_cards', (tester) async {
      await _pumpInicio(tester);

      expect(find.text('Canchas disponibles'), findsOneWidget);
      expect(find.text('Ver todo'), findsOneWidget);
      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('Cancha Municipal'), findsOneWidget);
      expect(find.text('5v5'), findsNWidgets(2));
      expect(find.text('7v7'), findsOneWidget);
      expect(find.text('Reservar'), findsNWidgets(3));
    });

    testWidgets('canchas_datos_simulados_en_orden', (tester) async {
      await _pumpInicio(tester);

      const filas = [
        ['Elite Arena Central', '5v5', '1.2 km de vos', '4.8 (124 reseñas)', r'$45'],
        ['Skyline Sports Hub', '7v7', '2.8 km de vos', '4.6 (89 reseñas)', r'$60'],
        ['Cancha Municipal', '5v5', '3.5 km de vos', '4.9 (210 reseñas)', r'$40'],
      ];
      double? topAnterior;
      for (final fila in filas) {
        final card = find.byKey(ValueKey('cancha-${fila[0]}'));
        for (final texto in fila) {
          expect(find.descendant(of: card, matching: find.text(texto)),
              findsOneWidget,
              reason: 'falta "$texto" en ${fila[0]}');
        }
        final top = tester.getRect(find.text(fila[0])).top;
        if (topAnterior != null) {
          expect(top, greaterThan(topAnterior),
              reason: 'los cards aparecen en orden del mockup');
        }
        topAnterior = top;
      }
      // Unidad del precio en los 3 cards.
      expect(find.text('/ hora'), findsNWidgets(3));
    });

    testWidgets('canchas_card_estilo_del_mockup', (tester) async {
      await _pumpInicio(tester);

      final card = find.byKey(const ValueKey('cancha-Elite Arena Central'));

      // Card: surface, radio 16, borde border 1px.
      final decoCard = _decoCard(tester, 'Elite Arena Central');
      expect(decoCard.color, AppColors.surface);
      expect(decoCard.borderRadius, BorderRadius.circular(16));
      expect(decoCard.border!.top.color, AppColors.border);
      expect(decoCard.border!.top.width, 1);

      // Foto 92×92 dentro de ClipRRect radio 12.
      final foto = find.descendant(
        of: card,
        matching: find.byType(Image),
      );
      expect(tester.getSize(foto), const Size(92, 92));
      final clip = find
          .ancestor(of: foto, matching: find.byType(ClipRRect))
          .first;
      expect((tester.widget<ClipRRect>(clip).borderRadius as BorderRadius)
          .topLeft, const Radius.circular(12));

      // Nombre 15 w700 text.
      final nombre = tester.widget<Text>(find.text('Elite Arena Central'));
      expect(nombre.style!.fontSize, 15);
      expect(nombre.style!.fontWeight, FontWeight.w700);
      expect(nombre.style!.color, AppColors.text);

      // Tag: primary, radio 8, padding 4/8, texto 11 w600 blanco.
      final tag = find
          .descendant(of: card, matching: find.text('5v5'))
          .first;
      final tagBox = find
          .ancestor(of: tag, matching: find.byType(Container))
          .first;
      final decoTag =
          tester.widget<Container>(tagBox).decoration! as BoxDecoration;
      expect(decoTag.color, AppColors.primary);
      expect(decoTag.borderRadius, BorderRadius.circular(8));
      expect(tester.widget<Container>(tagBox).padding,
          const EdgeInsets.symmetric(vertical: 4, horizontal: 8));
      final textoTag = tester.widget<Text>(tag);
      expect(textoTag.style!.fontSize, 11);
      expect(textoTag.style!.fontWeight, FontWeight.w600);
      expect(textoTag.style!.color, Colors.white);

      // Pin 13 text2; estrella 13 ámbar; textos 13 text2.
      final pin = tester.widget<Icon>(
        find.descendant(
          of: card,
          matching: find.byIcon(LucideIcons.mapPin),
        ),
      );
      expect(pin.size, 13);
      expect(pin.color, AppColors.text2);
      final estrella = tester.widget<Icon>(
        find.descendant(
          of: card,
          matching: find.byIcon(LucideIcons.star),
        ),
      );
      expect(estrella.size, 13);
      expect(estrella.color, const Color(0xFFF59E0B));
      final distancia = tester.widget<Text>(find.text('1.2 km de vos'));
      expect(distancia.style!.fontSize, 13);
      expect(distancia.style!.color, AppColors.text2);

      // Precio: monto 17 w700 primary + '/ hora' 12 text2.
      final monto = tester.widget<Text>(find.text(r'$45'));
      expect(monto.style!.fontSize, 17);
      expect(monto.style!.fontWeight, FontWeight.w700);
      expect(monto.style!.color, AppColors.primary);
      final unidad = find
          .descendant(of: card, matching: find.text('/ hora'))
          .first;
      final textoUnidad = tester.widget<Text>(unidad);
      expect(textoUnidad.style!.fontSize, 12);
      expect(textoUnidad.style!.color, AppColors.text2);

      // Botón Reservar: primary, radio 10, padding 11/20, texto 14 w600 blanco.
      final botonTexto = find
          .descendant(of: card, matching: find.text('Reservar'))
          .first;
      final boton = find
          .ancestor(of: botonTexto, matching: find.byType(Container))
          .first;
      final decoBoton =
          tester.widget<Container>(boton).decoration! as BoxDecoration;
      expect(decoBoton.color, AppColors.primary);
      expect(decoBoton.borderRadius, BorderRadius.circular(10));
      expect(tester.widget<Container>(boton).padding,
          const EdgeInsets.symmetric(vertical: 11, horizontal: 20));
      final textoBoton = tester.widget<Text>(botonTexto);
      expect(textoBoton.style!.fontSize, 14);
      expect(textoBoton.style!.fontWeight, FontWeight.w600);
      expect(textoBoton.style!.color, Colors.white);
    });

    testWidgets('canchas_fotos_cargadas', (tester) async {
      await _pumpInicio(tester);

      expect(find.byType(Image), findsNWidgets(3));
    });

    testWidgets('canchas_card_abre_el_detalle_con_la_cancha', (tester) async {
      final observer = _Observer();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const InicioScreen(),
      ));

      await tester.tap(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();

      expect(observer.pushes, greaterThan(0),
          reason: 'la card empuja una ruta ( el Detalle )');
      expect(find.text('Av. de los Deportes 123, Centro'), findsOneWidget,
          reason: 'el Detalle muestra la cancha de la card tocada');
    });

    testWidgets('canchas_reservar_abre_el_detalle', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: InicioScreen()));

      final reservar = find.descendant(
        of: find.byKey(const ValueKey('cancha-Skyline Sports Hub')),
        matching: find.text('Reservar'),
      );
      await tester.ensureVisible(reservar);
      await tester.pumpAndSettle();
      await tester.tap(reservar);
      await tester.pumpAndSettle();

      expect(find.text('Av. del Parque 789, Oeste'), findsOneWidget,
          reason: 'Reservar abre el Detalle de esa cancha');
    });

    testWidgets('canchas_ver_todo_sigue_inerte', (tester) async {
      final observer = _Observer();
      await tester.pumpWidget(MaterialApp(
        navigatorObservers: [observer],
        home: const InicioScreen(),
      ));
      final pushesIniciales = observer.pushes;

      await tester.tap(find.text('Ver todo'));
      await tester.pumpAndSettle();

      expect(observer.pushes, pushesIniciales,
          reason: 'Ver todo sigue sin funcionalidad');
      expect(find.text('Canchas disponibles'), findsOneWidget);
    });

    testWidgets('detalle_volver_conserva_el_estado_del_inicio', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: MainShell()));

      await tester.enterText(find.byType(TextField), 'elite');
      await tester.pumpAndSettle();
      await tester.tap(find.text('MIÉ'));
      await tester.pump();
      await tester.tap(find.text('Elite Arena Central'));
      await tester.pumpAndSettle();
      expect(find.text('Av. de los Deportes 123, Centro'), findsOneWidget,
          reason: 'el Detalle abrió');

      await tester.tap(find.byKey(const ValueKey('detalle-volver')));
      await tester.pumpAndSettle();

      expect(find.text('elite'), findsOneWidget,
          reason: 'el buscador conserva su texto');
      final chip = tester.widget<Container>(
        find.byKey(const ValueKey('dia-16')),
      );
      expect((chip.decoration! as BoxDecoration).color, AppColors.primary,
          reason: 'el día seleccionado se conserva');
    });

    testWidgets('canchas_sin_overflow_375x844_y_chica', (tester) async {
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
