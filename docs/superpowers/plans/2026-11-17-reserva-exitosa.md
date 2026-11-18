# Reserva exitosa Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `¡Reserva exitosa!` screen (mockup "Contenido") and wire `Confirmar reserva` to open it with the reservation data, including the two real navigation buttons.

**Architecture:** Task 1 adds `MainShell({TabApp tabInicial = TabApp.inicio})` (tab switching entry point). Task 2 builds `lib/features/reserva/reserva_exitosa_screen.dart` with a deterministic order-number generator (static counter starting at `882910` — the mockup's number is the first one, later ones differ) and the two buttons (`Ver mis reservas` = `pushAndRemoveUntil(MainShell(tabInicial: misReservas))`, `Volver al inicio` = `popUntil(isFirst)`). Task 3 replaces the inert `Confirmar reserva` with a push to the screen carrying `cancha`, `fecha` and the selected `hora`, and updates the `barra_confirmar_es_inerte` test accordingly.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas ( sin assets: la ilustración es vectorial simple ).

**Spec:** `docs/requerimientos/reserva-exitosa.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `¡Reserva exitosa!` (24px `FontWeight.w700` `AppColors.text`), `N° DE ORDEN` / `ESTADO DE PAGO` / `PRECIO TOTAL` (11px `FontWeight.w600`, `letterSpacing: 1`, `AppColors.text2`), orden `#GB-######` (15px `FontWeight.w600` `AppColors.text`), `PAGADO` (11px `FontWeight.w600` `AppColors.primary` sobre `AppColors.primarySoft`, radio 8, padding 4/9), monto (20px `FontWeight.w700` `AppColors.primary`), `Te enviamos la confirmación a tu email registrado.` (13px `AppColors.text2`), `Ver mis reservas` (15px `FontWeight.w600` blanco), `Volver al inicio` (15px `FontWeight.w600` `AppColors.text`).
- Descripción (15px `AppColors.text2`, centrada): `Tu cancha <nombre> quedó reservada para el <día> de octubre a las <hora>.` — `<día>` = los dígitos del label `fecha` ( `Mié, 16 oct` → `16` ); `<hora>` = la hora seleccionada.
- Orden generado: `static int _ultimoOrden = 882910` en la pantalla; cada construcción usa `'#GB-${_ultimoOrden++}'` ( determinista y único; el primero coincide con el mockup ). Los tests validan formato `^#GB-\d{6}$` y no un valor fijo ( excepto el test de unicidad ).
- Layout ( RD §4, medidas del PNG ): columna scrolleable centrada, padding lados 24, hueco 16 entre bloques — ilustración ( Stack: círculo `$primary` ≈130 con `LucideIcons.check` blanco ≈56 + punto ámbar `#F59E0B` ≈12 arriba-derecha + punto azul `#3B82F6` ≈9 a la izquierda ) + título + descripción + card ( `$surface`, radio 16, borde `$border` 1px, padding 20, hueco 16; cada fila `spaceBetween`: label + valor; fila del precio con el monto a la derecha en verde ) + aviso + botones ( `FilledButton`/`OutlinedButton`-style: primario `$primary` radio 12; secundario `$surface` + borde `$border` 1px radio 12; ancho completo, padding vertical 15, hueco 12 entre botones ).
- `MainShell` ( Task 1 ): `const MainShell({super.key, this.tabInicial = TabApp.inicio})`; `_MainShellState._activo` se inicializa con `widget.tabInicial`. Claves de placeholder sin cambios.
- Navegación ( RD RF-02 ): `Ver mis reservas` →
  `Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell(tabInicial: TabApp.misReservas)), (r) => false)`; `Volver al inicio` → `Navigator.of(context).popUntil((r) => r.isFirst)` ( conserva el estado del shell ).
- `Confirmar reserva` ( Task 3 ): reemplaza el handler vacío por
  `Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReservaExitosaScreen(cancha: widget.cancha, fecha: widget.fecha, hora: _seleccionado)))`. `_BarraReserva` pasa a recibir `cancha`, `fecha` y `hora`.
- Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos ( ámbar/azul literales ). Sin HTTP; sin persistencia.

## Review Focus

1. **Números de orden** — formato `#GB-######`, únicos entre reservas ( no un valor fijo hardcodeado que no cambie ). Pinned: Task 2 test `reserva_exitosa_orden_distinto_entre_reservas`.
2. **Datos cruzados en la descripción y el precio** — abrir desde Skyline/`20:00`/`Mié, 16 oct` muestra `Skyline Sports Hub`, `16 de octubre`, `20:00` y `$60.00` ( no los de Elite ). Pinned: Task 2 test `reserva_exitosa_descripcion_con_datos_de_la_reserva` + Task 3 test `barra_confirmar_abre_reserva_exitosa`.
3. **Navegación de los botones** — `Ver mis reservas` abre el shell EN el tab Mis reservas; `Volver al inicio` conserva el estado del Inicio ( buscador/día ). Pinned: Task 2 test `reserva_exitosa_ver_mis_reservas_abre_el_tab` + Task 3 test `flujo_completo_volver_conserva_estado`.
4. **Derivación del día** — del label `Mié, 16 oct` sale `16` ( extraer dígitos, no split frágil ). Pinned: Task 2 test `reserva_exitosa_descripcion_con_datos_de_la_reserva`.
5. **Regresión del test inerte** — `barra_confirmar_es_inerte` queda reemplazado ( el botón ahora navega ) y el resto de los 124 tests pasa sin edits. Pinned: Task 3 — suite completo.

---

### Task 1: `MainShell(tabInicial)` ( RD §8 )

**Files:**
- Modify: `src/FrontEnd/lib/features/navegacion/main_shell.dart`
- Test: `src/FrontEnd/test/main_shell_test.dart` ( +1 test )

**Interfaces:**
- Consumes: `TabApp` ( existente ).
- Produces ( Task 2 ): `const MainShell({super.key, this.tabInicial = TabApp.inicio})`.

- [ ] **Step 1: Write the failing test ( agregar a `test/main_shell_test.dart` )**

```dart
testWidgets('shell_tab_inicial_personalizable', (tester) async {
  tester.view.physicalSize = const Size(750, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const MaterialApp(
      home: MainShell(tabInicial: TabApp.misReservas)));

  expect(find.byKey(const ValueKey('placeholder-mis-reservas')), findsOneWidget);
  // El tab Mis reservas está activo ( pill primarySoft — mismo helper que
  // navegacion: _decoTab sobre ValueKey('tab-misReservas') ).
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/main_shell_test.dart`
Expected: FAIL ( no existe el parámetro ).

- [ ] **Step 3: Implementar en `main_shell.dart`**

`const MainShell({super.key, this.tabInicial = TabApp.inicio})` + `final TabApp tabInicial;` y `_activo = widget.tabInicial` ( el State inicializa desde el widget ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/main_shell_test.dart`
Expected: PASS ( 5 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/navegacion/main_shell.dart src/FrontEnd/test/main_shell_test.dart
git commit -m "feat(navegacion): MainShell con tabInicial (RD reserva-exitosa §8)"
```

### Task 2: `ReservaExitosaScreen` ( RD RF-01/RF-02 )

**Files:**
- Create: `src/FrontEnd/lib/features/reserva/reserva_exitosa_screen.dart`
- Test: `src/FrontEnd/test/reserva_exitosa_test.dart`

**Interfaces:**
- Consumes: `Cancha`, `MainShell(tabInicial)` ( Task 1 ), `TabApp`.
- Produces ( Task 3 ): `class ReservaExitosaScreen extends StatelessWidget`,
  `const ReservaExitosaScreen({super.key, required this.cancha, required this.fecha, required this.hora})`; generador `#GB-######` con `static int _ultimoOrden = 882910`.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/reserva_exitosa_test.dart`**

Pump: `MaterialApp(home: ReservaExitosaScreen(cancha: canchasSimuladas[0], fecha: 'Mar, 15 oct', hora: '19:00'))` con viewport 375×844 @2x.

```dart
testWidgets('reserva_exitosa_muestra_titulo_descripcion_y_card', (tester) async {
  // '¡Reserva exitosa!'; 'N° DE ORDEN'; orden con formato
  // RegExp(r'^#GB-\d{6}$') ( find.textContaining('#GB-') + match );
  // 'ESTADO DE PAGO' + 'PAGADO'; 'PRECIO TOTAL' + '$45.00';
  // 'Te enviamos la confirmación a tu email registrado.';
  // 'Ver mis reservas' y 'Volver al inicio'; ilustración: LucideIcons.check.
});

testWidgets('reserva_exitosa_descripcion_con_datos_de_la_reserva', (tester) async {
  // pump con Skyline / 'Mié, 16 oct' / '20:00' →
  // find.text('Tu cancha Skyline Sports Hub quedó reservada para el 16 de octubre a las 20:00.')
  // y monto '$60.00'.
});

testWidgets('reserva_exitosa_card_estilos', (tester) async {
  // Labels 11 w600 letterSpacing 1 text2; orden 15 w600 text;
  // pill PAGADO: primarySoft, radio 8, padding 4/9, texto 11 w600 primary;
  // monto 20 w700 primary; card: surface, radio 16, borde border 1px.
});

testWidgets('reserva_exitosa_orden_distinto_entre_reservas', (tester) async {
  // pump 1 y pump 2 ( pantalla nueva ): los dos números matchean el regex y
  // son distintos entre sí.
});

testWidgets('reserva_exitosa_ver_mis_reservas_abre_el_tab', (tester) async {
  // tap 'Ver mis reservas' → MainShell con el tab Mis reservas activo:
  // find.byKey('placeholder-mis-reservas') visible + pill del tab
  // 'tab-misReservas' con primarySoft ( helper _decoTab ).
});

testWidgets('reserva_exitosa_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/reserva_exitosa_test.dart`
Expected: FAIL ( la pantalla no existe ).

- [ ] **Step 3: Implementar `lib/features/reserva/reserva_exitosa_screen.dart`**

Estructura según Global Constraints ( columna scrolleable centrada; ilustración vectorial simple con `Stack` de círculo + check + 2 puntos; card con 3 filas `spaceBetween`; 2 botones ancho completo ). Derivar el día: `RegExp(r'(\d+)').firstMatch(fecha)?.group(1)`. Número: `'#GB-${_ultimoOrden++}'`. Botones según Global Constraints ( `Ver mis reservas` y `Volver al inicio` reales ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/reserva_exitosa_test.dart`
Expected: PASS ( 6 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/reserva/reserva_exitosa_screen.dart src/FrontEnd/test/reserva_exitosa_test.dart
git commit -m "feat(reserva): pantalla Reserva exitosa del mockup (RD reserva-exitosa RF-01/02)"
```

### Task 3: `Confirmar reserva` cableado ( RD RF-02 / cierra RF-03 de detalle-horarios )

**Files:**
- Modify: `src/FrontEnd/lib/features/detalle/detalle_screen.dart` ( `_BarraReserva` )
- Modify: `src/FrontEnd/test/detalle_horarios_test.dart` ( reemplazar `barra_confirmar_es_inerte` )

**Interfaces:**
- Consumes: `ReservaExitosaScreen` ( Task 2 ), `cancha`, `fecha`, `_seleccionado`.
- Produces: `_BarraReserva({required cancha, required fecha, required hora, required onConfirmar})` — el handler vive en `_DetalleScreenState` ( navega con `cancha: widget.cancha, fecha: widget.fecha, hora: _seleccionado` ).

- [ ] **Step 1: Reescribir los tests ( primero fallan )**

En `test/detalle_horarios_test.dart`, reemplazar `barra_confirmar_es_inerte` por:

```dart
testWidgets('barra_confirmar_abre_reserva_exitosa', (tester) async {
  // pump DetalleScreen(cancha: Skyline, fecha: 'Mié, 16 oct'); ensureVisible
  // + tap '20:00'; tap 'Confirmar reserva' →
  // find.text('Tu cancha Skyline Sports Hub quedó reservada para el 16 de
  // octubre a las 20:00.') findsOneWidget + find.text(r'$60.00') findsOneWidget.
});

testWidgets('flujo_completo_volver_conserva_estado', (tester) async {
  // pump MainShell() 375×844: escribir 'futbol' + tap 'MIÉ' + tap card Elite
  // → Detalle: tap 'Confirmar reserva' → Reserva exitosa: tap 'Volver al
  // inicio' → Inicio con find.text('futbol') y chip dia-16 primary.
});

testWidgets('flujo_ver_mis_reservas_abre_el_tab', (tester) async {
  // mismo flujo pero tap 'Ver mis reservas' → MainShell con el tab Mis
  // reservas activo ( pill ) y su placeholder visible.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_horarios_test.dart`
Expected: FAIL ( el botón no navega ).

- [ ] **Step 3: Implementar en `detalle_screen.dart`**

- `_BarraReserva` recibe `fecha`, `hora` y `onConfirmar` ( o directamente hace el push — decisión: handler en el State para pasar `_seleccionado` ); el `GestureDetector` vacío se reemplaza por el push del Global Constraints. Los estilos no cambian.

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` ( suite completo )
Expected: PASS — 133/133 ( 124 previos + 1 Task 1 + 6 Task 2 + 2 netos de esta task ), sin edits en otros tests.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/detalle/detalle_screen.dart src/FrontEnd/test/detalle_horarios_test.dart
git commit -m "feat(reserva): Confirmar reserva abre la pantalla de exito (RD reserva-exitosa RF-02)"
```

### Task 4: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/reserva-exitosa.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-17 )
- Modify: `docs/requerimientos/README.md` ( quitar `reserva-exitosa.md` de activos )
- Move: `docs/requerimientos/reserva-exitosa.md` → `docs/HistRequerimientos/reserva-exitosa.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 133/133
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\reserva-exitosa\` )

- [ ] Detalle → elegir hora → `Confirmar reserva` → `¡Reserva exitosa!` con datos correctos ( descripción, orden, PAGADO, precio ).
- [ ] `Ver mis reservas` → shell en el tab Mis reservas.
- [ ] `Volver al inicio` → Inicio con buscador y día conservados.
- [ ] Comparar con el PNG del mockup.

- [ ] **Step 3: Escribir `Specs/reserva-exitosa.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/reserva-exitosa.md docs/HistRequerimientos/reserva-exitosa.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: **error de reserva** ( frame 10 ) ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: reserva exitosa implementada — spec SDD + RD a HistRequerimientos"
```
