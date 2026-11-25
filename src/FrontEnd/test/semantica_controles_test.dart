import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/detalle/detalle_screen.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';
import 'package:turnos_cancha/features/inicio/inicio_screen.dart';

void main() {
  group('Semántica de los controles inertes (pasada de limpieza)', () {
    testWidgets('controles_del_header_tienen_etiqueta_accesible',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: InicioScreen()));

      for (final etiqueta in ['Notificaciones', 'Perfil']) {
        final nodo = find.bySemanticsLabel(etiqueta);
        expect(nodo, findsOneWidget, reason: 'falta la etiqueta $etiqueta');
        expect(
          tester
              .getSemantics(nodo)
              .flagsCollection
              .isButton,
          isTrue,
          reason: '$etiqueta se anuncia como botón',
        );
      }
    });

    testWidgets('botones_del_hero_tienen_etiqueta_accesible', (tester) async {
      tester.view.physicalSize = const Size(750, 1688);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: DetalleScreen(cancha: canchasSimuladas[0]),
      ));

      for (final etiqueta in ['Volver', 'Compartir', 'Favorito']) {
        final nodo = find.bySemanticsLabel(etiqueta);
        expect(nodo, findsOneWidget, reason: 'falta la etiqueta $etiqueta');
        expect(
          tester
              .getSemantics(nodo)
              .flagsCollection
              .isButton,
          isTrue,
          reason: '$etiqueta se anuncia como botón',
        );
      }
    });
  });
}
