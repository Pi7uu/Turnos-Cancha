import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:turnos_cancha/core/theme/app_colors.dart';
import 'package:turnos_cancha/features/favoritos/favoritos_locales.dart';
import 'package:turnos_cancha/features/favoritos/favoritos_screen.dart';

Future<void> _pumpFavoritos(WidgetTester tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(home: FavoritosScreen()));
}

void main() {
  setUp(resetFavoritos);

  group('FavoritosScreen (RD favoritos §4)', () {
    testWidgets('favoritos_muestra_header_y_contador', (tester) async {
      await _pumpFavoritos(tester);

      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('3 canchas'), findsOneWidget);
    });

    testWidgets('favoritos_muestra_las_cards_del_mockup', (tester) async {
      await _pumpFavoritos(tester);

      expect(find.text('Elite Arena Central'), findsOneWidget);
      expect(find.text('1.2 km de vos'), findsOneWidget);
      expect(find.text('4.8 (124 reseñas)'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('2.8 km de vos'), findsOneWidget);
      expect(find.text('4.6 (89 reseñas)'), findsOneWidget);
      expect(find.text('Cancha Municipal'), findsOneWidget);
      expect(find.text('3.5 km de vos'), findsOneWidget);
      expect(find.text('4.9 (210 reseñas)'), findsOneWidget);
      expect(find.text('\$45'), findsOneWidget);
      expect(find.text('\$60'), findsOneWidget);
      expect(find.text('\$40'), findsOneWidget);
      expect(find.text('/ hora'), findsNWidgets(3));
      expect(find.text('Reservar'), findsNWidgets(3));
      expect(find.byIcon(LucideIcons.heart), findsNWidgets(3));
      expect(find.byIcon(LucideIcons.mapPin), findsNWidgets(3));
      expect(find.byIcon(LucideIcons.star), findsNWidgets(3));
    });

    testWidgets('favoritos_card_estilos_del_mockup', (tester) async {
      await _pumpFavoritos(tester);

      // Foto 92×92 radio 12.
      final foto = find
          .descendant(
            of: find.byKey(const ValueKey('card-Elite Arena Central')),
            matching: find.byType(Image),
          )
          .first;
      expect(tester.getSize(foto), const Size(92, 92));

      // Botón Reservar: $primary, radio 10, padding 11/20.
      final boton = find
          .ancestor(
            of: find.text('Reservar').first,
            matching: find.byType(Container),
          )
          .first;
      final deco = tester.widget<Container>(boton).decoration! as BoxDecoration;
      expect(deco.color, AppColors.primary);
      expect(deco.borderRadius, BorderRadius.circular(10));
      expect(
        tester.widget<Container>(boton).padding,
        const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
      );
    });
  });

  group('Acciones de Favoritos (RD favoritos RF-02/03)', () {
    testWidgets('corazon_quita_favorito_y_actualiza_contador',
        (tester) async {
      await _pumpFavoritos(tester);

      await tester.tap(find.byKey(const ValueKey('quitar-Elite Arena Central')));
      await tester.pumpAndSettle();

      expect(find.text('Elite Arena Central'), findsNothing);
      expect(find.text('2 canchas'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsOneWidget);
      expect(find.text('Cancha Municipal'), findsOneWidget);
    });

    testWidgets('lista_vacia_muestra_estado_vacio', (tester) async {
      await _pumpFavoritos(tester);

      for (final nombre in [
        'Elite Arena Central',
        'Skyline Sports Hub',
        'Cancha Municipal',
      ]) {
        await tester.tap(find.byKey(ValueKey('quitar-$nombre')));
        await tester.pumpAndSettle();
      }

      expect(find.text('0 canchas'), findsOneWidget);
      expect(find.text('Todavía no tenés favoritos'), findsOneWidget);
      expect(
          find.text(
              'Cuando marques una cancha como favorita va a aparecer acá.'),
          findsOneWidget);
      expect(find.byIcon(LucideIcons.heart), findsOneWidget);
      expect(find.text('Explorar canchas'), findsOneWidget);
    });

    testWidgets('reservar_abre_el_detalle', (tester) async {
      await _pumpFavoritos(tester);

      await tester.tap(find.byKey(const ValueKey('reservar-Skyline Sports Hub')));
      await tester.pumpAndSettle();

      // Detalle de Skyline con la fecha por defecto ( RD §8 ).
      expect(find.text('Elegí el horario'), findsOneWidget);
      expect(find.text('Mié, 16 oct'), findsNothing);
      expect(find.text('Mar, 15 oct'), findsOneWidget);
      expect(find.text('Skyline Sports Hub'), findsWidgets);

      // Volver regresa a Favoritos ( la lista sigue viva ).
      await tester.tap(find.byKey(const ValueKey('detalle-volver')));
      await tester.pumpAndSettle();
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('3 canchas'), findsOneWidget);
    });
  });
}
