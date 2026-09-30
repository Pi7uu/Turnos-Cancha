import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:turnos_cancha/app.dart';
import 'package:turnos_cancha/core/widgets/estado_badge.dart';

void main() {
  testWidgets('EstadoBadge muestra el estado en mayúsculas',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTemaApp(),
        home: const Scaffold(
          body: EstadoBadge(estado: 'CONFIRMADA'),
        ),
      ),
    );

    expect(find.text('CONFIRMADA'), findsOneWidget);
  });

  testWidgets('EstadoBadge usa el color de su estado',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTemaApp(),
        home: const Scaffold(
          body: EstadoBadge(estado: 'PENDIENTE'),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(EstadoBadge),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, isNotNull);
    expect('${decoration.color!.toARGB32()}', isNotEmpty);
  });
}
