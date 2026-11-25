# Mis reservas · lista y pestañas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Mis reservas screen (mockup 03/08): header with back, the 3 tabs (Próximas/Completadas/Canceladas) and the reservation cards with status badges — replacing the shell's placeholder tab.

**Architecture:** Task 1 creates `lib/features/mis_reservas/reserva.dart` with the `Reserva` model + `EstadoReserva` enum + `reservasSimuladas` (2 mockup cards + 1 completada + 1 cancelada). Task 2 builds `MisReservasScreen` (StatefulWidget: `_pestanaActiva`), filters `reservasSimuladas` per tab, and replaces the `_Placeholder('placeholder-mis-reservas')` in `MainShell` (key unchanged); `MainShell` passes an `onVolver` callback that switches to `TabApp.inicio` (IndexedStack preserves the Inicio state). Card buttons stay inert (actions = parte 2).

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas ( fotos: assets existentes ).

**Spec:** `docs/requerimientos/mis-reservas-lista.md` (RD 2026-11-25). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `Mis reservas` (24px `FontWeight.w700` `AppColors.text`), `Próximas`/`Completadas`/`Canceladas` (15px; activa `FontWeight.w600` `AppColors.primary`, inactiva `FontWeight.w500` `AppColors.text2`), `HORARIO`/`CANCHA` (10px `FontWeight.w600`, `letterSpacing: 1`, `AppColors.text2`), valores `19:00 - 20:00` / `Cancha A (5v5)` (17px `FontWeight.w700` `AppColors.text`), fecha `Mar, 15 oct 2026` (13px `AppColors.text2`), badges `CONFIRMADA`/`PENDIENTE`/`COMPLETADA`/`CANCELADA` (10px `FontWeight.w700`, `letterSpacing: 0.5`, radio 6, padding 5/9), botones `Cancelar reserva`/`Ver QR`/`Confirmar` (14px `FontWeight.w600`).
- Badges ( RD §4 ): `CONFIRMADA` `$primary`/blanco; `PENDIENTE` `#F59E0B`/blanco; `COMPLETADA` `$primarySoft`/`$primary`; `CANCELADA` `#FEE2E2`/`$danger`.
- Botones de card: `Cancelar reserva` = `$surface` + borde `$border` 1px, radio 10, padding 12, texto `$text`; `Ver QR`/`Confirmar` = `$primary`, radio 10, padding 12, texto blanco. En Próximas: `Cancelar reserva` + (`Ver QR` si CONFIRMADA / `Confirmar` si PENDIENTE ). En Completadas/Canceladas: solo `Cancelar reserva`… **no**: en esas pestañas el mockup no define acciones — decisión: **sin botones** en Completadas/Canceladas ( la reserva ya terminó; nota en el spec as-built ).
- Content: padding 8/16/16/16, hueco **18** entre bloques ( header → pestañas → lista ); lista vertical hueco **12** entre cards.
- Header: fila gap 14 centrada — Volver 40×40 `$surface` radio 20 borde `$border` 1px con `chevron-left` 20×20 `$text`, envuelto en `Semantics(button: true, label: 'Volver')`; título.
- Pestañas: fila con los 3 en `Expanded`; pestaña = columna hueco 9, padding 0/10, centrada: label + subrayado ( `Container(height: 3, radius 2)` — activo `$primary`, inactivo `Colors.transparent` ). Claves `ValueKey('pestana-proximas')` / `pestana-completadas` / `pestana-canceladas`. Tap cambia `_pestanaActiva`.
- Modelo ( Task 1 ): `enum EstadoReserva { confirmada, pendiente, completada, cancelada }` y `class Reserva { final String nombre, foto, fecha, horario, sector; final EstadoReserva estado; }` + `const List<Reserva> reservasSimuladas` ( RD §4 ): Elite `Mar, 15 oct 2026` `19:00 - 20:00` `Cancha A (5v5)` confirmada; Skyline `Sáb, 19 oct 2026` `10:00 - 11:30` `Cancha principal (7v7)` pendiente; Municipal `Lun, 12 oct 2026` `18:00 - 19:00` `Cancha B (5v5)` completada; Elite `Vie, 23 oct 2026` `20:00 - 21:00` `Cancha A (5v5)` cancelada. `foto` = `cancha.foto` correspondiente ( assets existentes ).
- Filtro por pestaña: Próximas = `confirmada | pendiente`; Completadas = `completada`; Canceladas = `cancelada` ( orden de `reservasSimuladas` ).
- Card clave `ValueKey('reserva-<índice>')` ( tests ). Foto `Image.asset` 48×48 en `ClipRRect` radio 10.
- **Volver** ( RD §8 ): `MisReservasScreen({this.onVolver})` — `MainShell` pasa `onVolver: () => setState(() => _activo = TabApp.inicio)` ( **conserva el estado del Inicio** por el IndexedStack ). En tests sueltos, el callback se inyecta.
- **MainShell**: reemplaza `_Placeholder(key: ValueKey('placeholder-mis-reservas'))` por `MisReservasScreen(key: ValueKey('placeholder-mis-reservas'), onVolver: ...)` — la key **no cambia** ( tests existentes la referencian ).
- Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos. Sin HTTP; sin persistencia.

## Review Focus

1. **Badges cruzados o mal coloreados** — CONFIRMADA verde/white, PENDIENTE ámbar/white, COMPLETADA verde-claro/verde, CANCELADA rosa/rojo; cada card con SU badge ( no mezclados ). Pinned: Task 2 tests `proximas_muestra_las_cards_del_mockup` y `cards_estilos_del_mockup`.
2. **Pestañas: un solo activo con subrayado correcto** — label green w600 + subrayado `$primary` solo en la activa; transparente en las demás; cambiar desmarca la anterior. Pinned: Task 2 test `pestanas_estado_activo` y `cambiar_pestana_muestra_su_lista`.
3. **Datos cruzados entre pestañas** — Completadas muestra la Municipal `18:00 - 19:00`; Canceladas la Elite `20:00 - 21:00` ( no las de Próximas ). Pinned: Task 2 test `cambiar_pestana_muestra_su_lista`.
4. **Volver conserva el Inicio** — cambia al tab Inicio sin resetearlo ( buscador/día intactos ). Pinned: Task 2 test `mis_reservas_volver_cambia_al_tab_inicio`.
5. **Regresión del shell** — la key `placeholder-mis-reservas` sigue presente ( tests de navegación y de reserva sin edits ) y los botones de las cards son inertes. Pinned: Task 2 tests `botones_de_las_cards_son_inertes` + suite ( 144 sin edits ).

---

### Task 1: Modelo `Reserva` + data simulada

**Files:**
- Create: `src/FrontEnd/lib/features/mis_reservas/reserva.dart`
- Test: `src/FrontEnd/test/reserva_test.dart`

**Interfaces:**
- Consumes: nada.
- Produces ( Task 2 ): `enum EstadoReserva`, `class Reserva` ( campos del Global Constraints ), `const List<Reserva> reservasSimuladas` ( 4 elementos, orden del RD §4 ).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/reserva_test.dart`**

```dart
test('reservas_simuladas_datos_del_mockup', () {
  expect(reservasSimuladas.length, 4);
  expect(reservasSimuladas[0].nombre, 'Elite Arena Central');
  expect(reservasSimuladas[0].fecha, 'Mar, 15 oct 2026');
  expect(reservasSimuladas[0].horario, '19:00 - 20:00');
  expect(reservasSimuladas[0].sector, 'Cancha A (5v5)');
  expect(reservasSimuladas[0].estado, EstadoReserva.confirmada);
  expect(reservasSimuladas[1].nombre, 'Skyline Sports Hub');
  expect(reservasSimuladas[1].estado, EstadoReserva.pendiente);
  expect(reservasSimuladas[2].nombre, 'Cancha Municipal');
  expect(reservasSimuladas[2].estado, EstadoReserva.completada);
  expect(reservasSimuladas[3].estado, EstadoReserva.cancelada);
  expect(reservasSimuladas[3].fecha, 'Vie, 23 oct 2026');
});

test('reservas_por_estado', () {
  final proximas = reservasSimuladas
      .where((r) =>
          r.estado == EstadoReserva.confirmada ||
          r.estado == EstadoReserva.pendiente)
      .length;
  expect(proximas, 2);
  expect(
      reservasSimuladas
          .where((r) => r.estado == EstadoReserva.completada)
          .length,
      1);
  expect(
      reservasSimuladas
          .where((r) => r.estado == EstadoReserva.cancelada)
          .length,
      1);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/reserva_test.dart`
Expected: FAIL ( `reserva.dart` no existe ).

- [ ] **Step 3: Implementar `lib/features/mis_reservas/reserva.dart`**

Enum + clase ( constructor `const` ) + `reservasSimuladas` con los valores del Global Constraints ( `foto`: `cancha.foto` correspondiente: elite/skyline/municipal/elite ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/reserva_test.dart`
Expected: PASS ( 2 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/mis_reservas/reserva.dart src/FrontEnd/test/reserva_test.dart
git commit -m "feat(mis-reservas): modelo Reserva con data simulada (RD mis-reservas-lista §4)"
```

### Task 2: `MisReservasScreen` + pestañas + cards ( RD RF-01/RF-02 )

**Files:**
- Create: `src/FrontEnd/lib/features/mis_reservas/mis_reservas_screen.dart`
- Modify: `src/FrontEnd/lib/features/navegacion/main_shell.dart` ( tab Mis reservas )
- Test: `src/FrontEnd/test/mis_reservas_test.dart`

**Interfaces:**
- Consumes: `Reserva`/`reservasSimuladas` ( Task 1 ).
- Produces ( Task 3 ): `class MisReservasScreen extends StatefulWidget`, `const MisReservasScreen({super.key, this.onVolver})` ( clave `placeholder-mis-reservas` en el shell ).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/mis_reservas_test.dart`**

Pump base: `MaterialApp(home: MisReservasScreen())` con viewport 375×844 @2x. Helper `_decoCard(tester, i)` = decoración del `Container` con `key: ValueKey('reserva-$i')`.

```dart
testWidgets('mis_reservas_muestra_header_y_3_pestanas', (tester) async {
  // 'Mis reservas' + LucideIcons.chevronLeft + 'Próximas' + 'Completadas'
  // + 'Canceladas' + las 2 cards de Próximas.
});

testWidgets('pestanas_estado_activo', (tester) async {
  // Próximas: label primary w600 + subrayado (Container de la pestaña)
  // primary; Completadas/Canceladas: label text2 w500 + subrayado
  // transparente.
});

testWidgets('proximas_muestra_las_cards_del_mockup', (tester) async {
  // Card 0 (Elite): 'Elite Arena Central', 'Mar, 15 oct 2026', 'CONFIRMADA',
  // 'HORARIO', '19:00 - 20:00', 'CANCHA', 'Cancha A (5v5)', 'Cancelar
  // reserva', 'Ver QR'; Card 1 (Skyline): 'Skyline Sports Hub', 'Sáb, 19 oct
  // 2026', 'PENDIENTE', '10:00 - 11:30', 'Cancha principal (7v7)', 'Confirmar'.
});

testWidgets('cambiar_pestana_muestra_su_lista', (tester) async {
  // tap 'Completadas' → activa + card 'Cancha Municipal' con badge
  // 'COMPLETADA' + '18:00 - 19:00'; 'Próximas' inactiva. tap 'Canceladas' →
  // badge 'CANCELADA' + 'Vie, 23 oct 2026' + '20:00 - 21:00'.
});

testWidgets('cards_estilos_del_mockup', (tester) async {
  // Card: surface, radio 16, borde border 1px. Foto Image 48×48 en
  // ClipRRect radio 10. Nombre 15 w700 text; fecha 13 text2; badge
  // CONFIRMADA: primary, radio 6, padding 5/9, texto 10 w700 ls 0.5 blanco;
  // labels 10 w600 ls 1 text2; valores 17 w700 text; botón Cancelar:
  // surface + borde border, radio 10, padding 12, texto 14 w600 text;
  // Ver QR: primary, radio 10, padding 12, texto 14 w600 blanco.
});

testWidgets('botones_de_las_cards_son_inertes', (tester) async {
  // NavigatorObserver: taps en 'Cancelar reserva', 'Ver QR' y 'Confirmar' →
  // pushes == baseline; pantalla intacta.
});

testWidgets('mis_reservas_volver_cambia_al_tab_inicio', (tester) async {
  // pump MainShell() 375×844: tap tab 'Mis reservas' → tap (semántica
  // 'Volver') → Inicio activo ( pill del tab 'tab-inicio' primarySoft ) y
  // placeholder-inicio visible.
});

testWidgets('mis_reservas_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/mis_reservas_test.dart`
Expected: FAIL ( la pantalla no existe ).

- [ ] **Step 3: Implementar**

- `MisReservasScreen` ( StatefulWidget, `_pestanaActiva = 0` ): content según Global Constraints ( header, pestañas, lista scrolleable de cards filtradas ). `onVolver` en el `Semantics(button: true, label: 'Volver')` del header ( `GestureDetector` que llama `onVolver?.call()` ).
- `_CardReserva({required Reserva reserva, required int indice})` con la estructura del §4 ( Superior/Detalle/Acciones según el estado — sin acciones en Completadas/Canceladas ). Botones `GestureDetector(onTap: () {})` ( inertes ).
- `main_shell.dart`: el hijo de `placeholder-mis-reservas` pasa a `MisReservasScreen(key: ValueKey('placeholder-mis-reservas'), onVolver: () => setState(() => _activo = TabApp.inicio))` ( import nuevo ).

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` ( suite completo )
Expected: PASS — 154/154 ( 144 previos + 2 Task 1 + 8 de esta task ), sin edits en otros tests.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/mis_reservas src/FrontEnd/lib/features/navegacion/main_shell.dart src/FrontEnd/test/mis_reservas_test.dart
git commit -m "feat(mis-reservas): pantalla con pestañas y cards del mockup (RD mis-reservas-lista RF-01/02)"
```

### Task 3: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/mis-reservas-lista.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-25 )
- Modify: `docs/requerimientos/README.md` ( quitar `mis-reservas-lista.md` de activos )
- Move: `docs/requerimientos/mis-reservas-lista.md` → `docs/HistRequerimientos/mis-reservas-lista.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 154/154
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\mis-reservas\` )

- [ ] Tab Mis reservas: header + pestañas + 2 cards Próximas con badges y botones.
- [ ] Tap Completadas / Canceladas: listas y badges correctos.
- [ ] Volver → tab Inicio con el estado intacto.
- [ ] Comparar con el PNG 03 y el frame 08.

- [ ] **Step 3: Escribir `Specs/mis-reservas-lista.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/mis-reservas-lista.md docs/HistRequerimientos/mis-reservas-lista.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: **parte 2 de Mis reservas** — acciones + store, estados vacíos, variante Sin QR ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: mis reservas lista y pestanas implementadas — spec SDD + RD a HistRequerimientos"
```
