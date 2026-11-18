# Detalle de cancha · horarios y barra de reserva Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the "Elegí el horario" block (6 slots with available/selected/occupied states and real selection) and the fixed bottom bar (`PRECIO TOTAL` + `Confirmar reserva`) to the Detalle screen.

**Architecture:** Task 1 extends `Cancha.horasOcupadas` (mock data). Task 2 turns `DetalleScreen` into a StatefulWidget (selection state `String _seleccionado = '19:00'`) with a new optional `fecha` parameter (default `Mar, 15 oct`) and adds the `_Horarios` block (2 rows of 3 `Expanded` slots). Task 3 adds the fixed `_BarraReserva` in `bottomNavigationBar` (same pattern as the shell's tab bar) and wires the Inicio to pass the selected-day label into `DetalleScreen`. `Confirmar reserva` stays inert until the reservation-flow RD.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/detalle-horarios.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `Elegí el horario` (17px `FontWeight.w700` `AppColors.text`), fecha `Mar, 15 oct` (13px normal `AppColors.text2`), horas `17:00`/`18:00`/`19:00`/`20:00`/`21:00`/`22:00` (15px `FontWeight.w600`), `PRECIO TOTAL` (11px `FontWeight.w600`, `letterSpacing: 1`, `AppColors.text2`), monto `$45.00` (24px `FontWeight.w700` `AppColors.text`), `Confirmar reserva` (15px `FontWeight.w600` blanco).
- Bloque `_Horarios` ( hueco 16 bajo `_Sobre` en la columna scrolleable del Detalle; hueco 12 interno ): fila título `spaceBetween` centrada + 2 filas de 3 slots ( hueco 10, cada slot `Expanded` — reparto igual ).
- Slot: `Container` ( clave `ValueKey('hora-<HH:MM>')` ) radio 10, padding `EdgeInsets.symmetric(vertical: 13)`, centrado: texto de la hora. Estados ( RD §4 ): disponible = `$surface` / `$text-2`; seleccionado = `$primary` / `Colors.white`; ocupado = `Color(0xFFF1F5F9)` / `$text-2` dentro de `Opacity(0.5)`.
- Selección ( RD RF-02 ): `DetalleScreen` → `StatefulWidget` con `String _seleccionado = '19:00'` ( default del mockup; la data actual lo deja libre en las 3 canchas ). Tap en disponible → cambia selección; tap en ocupado o en el seleccionado → sin efecto. El monto NO cambia con la selección.
- `_BarraReserva` en `bottomNavigationBar` del `Scaffold` ( mismo patrón que la tab bar del shell ): `Container` `$surface`, `Border(top: BorderSide(color: AppColors.border, width: 1))`, padding `EdgeInsets.symmetric(vertical: 16, horizontal: 20)`, `Row(spaceBetween, center)`:
  - `Column(mainAxisSize: min)` ( hueco 2 ): `PRECIO TOTAL` + `Text('${cancha.precio}.00')`.
  - Botón: `Container` `$primary` radio 12, padding `EdgeInsets.symmetric(vertical: 15, horizontal: 22)`, `Row` ( hueco 8 ): `Confirmar reserva` + `LucideIcons.arrowRight` 16×16 blanco. **Inerte** ( `GestureDetector(onTap: () {})` — RD RF-03 ).
- Parámetro `fecha` de `DetalleScreen`: `final String fecha;` con constructor `const DetalleScreen({super.key, required this.cancha, this.fecha = 'Mar, 15 oct'})` ( default = mockup; los tests existentes no cambian ).
- Wiring del Inicio ( RD §8 ): `_InicioScreenState` deriva el label del día activo ( `['Lun','Mar','Mié','Jue','Vie'][_diaActivo] + ', ${[14,15,16,17,18][_diaActivo]} oct'` ) y lo pasa a `_Canchas(fecha:)` → `_CardCancha(cancha, fecha)` → `DetalleScreen(cancha: cancha, fecha: fecha)`.
- Modelo ( Task 1 ): `Cancha` + `final List<String> horasOcupadas;` — Elite `['21:00']`, Skyline `['17:00', '21:00']`, Municipal `['20:00']` ( RD §4 ).
- Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos ( `#F1F5F9` literal ). Sin HTTP.

## Review Focus

1. **Estados del slot mal mapeados o invertidos** — verde/blanco solo el seleccionado; ocupado gris + `Opacity(0.5)`; el disponible NO lleva Opacity. Pinned: Task 2 test `horarios_estados_disponible_seleccionado_ocupado`.
2. **Selección que no se mueve o que permite ocupados** — tap disponible desmarca el anterior; tap en ocupado no hace nada. Pinned: Task 2 test `horarios_seleccion_cambia_y_ocupado_no_tappable`.
3. **La fecha no refleja el día del Inicio** — abrir desde MIÉ muestra `Mié, 16 oct`, no el default. Pinned: Task 3 test `horarios_fecha_refleja_el_dia_del_inicio`.
4. **Montos por cancha** — `$45.00` / `$60.00` / `$40.00` ( `precio + '.00'`, sin mezclar con el monto de la card `$45` ). Pinned: Task 3 test `barra_muestra_precio_total_y_confirmar`.
5. **La barra fija no tapa contenido ni rompe 320px** — `bottomNavigationBar` ( no overlay ) y sin overflow con la fuente de test. Pinned: Task 2 test `horarios_sin_overflow_375x844_y_chica` + suite previo ( 116 sin edits ).

---

### Task 1: `Cancha.horasOcupadas` ( data simulada )

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/cancha.dart`
- Test: `src/FrontEnd/test/cancha_test.dart` ( +1 test )

**Interfaces:**
- Consumes: nada.
- Produces ( Task 2 ): `Cancha` + `final List<String> horasOcupadas;` con los valores del Global Constraints.

- [ ] **Step 1: Write the failing test ( agregar a `test/cancha_test.dart` )**

```dart
test('canchas_simuladas_horas_ocupadas', () {
  expect(canchasSimuladas[0].horasOcupadas, ['21:00']);
  expect(canchasSimuladas[1].horasOcupadas, ['17:00', '21:00']);
  expect(canchasSimuladas[2].horasOcupadas, ['20:00']);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: FAIL ( el campo no existe ).

- [ ] **Step 3: Implementar en `lib/features/inicio/cancha.dart`**

+ `final List<String> horasOcupadas;` ( constructor `const` ); `canchasSimuladas` con los valores del Global Constraints ( listas `const` ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: PASS ( 6 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/cancha.dart src/FrontEnd/test/cancha_test.dart
git commit -m "feat(detalle): Cancha con horasOcupadas simuladas (RD detalle-horarios §4)"
```

### Task 2: `_Horarios` con selección + parámetro `fecha` ( RD RF-01/RF-02 )

**Files:**
- Modify: `src/FrontEnd/lib/features/detalle/detalle_screen.dart`
- Test: `src/FrontEnd/test/detalle_horarios_test.dart`

**Interfaces:**
- Consumes: `Cancha.horasOcupadas` ( Task 1 ).
- Produces ( Task 3 ): `DetalleScreen` como `StatefulWidget` con `const DetalleScreen({super.key, required this.cancha, this.fecha = 'Mar, 15 oct'})`; widget `_Horarios` ( clave de slot `ValueKey('hora-<HH:MM>')` ).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/detalle_horarios_test.dart`**

Pump: `MaterialApp(home: DetalleScreen(cancha: <cancha>))` con viewport 375×844 @2x. Helper `_decoHora(tester, hora)` = `BoxDecoration` del `Container` con `key: ValueKey('hora-<hora>')`.

```dart
testWidgets('horarios_muestra_titulo_fecha_y_6_slots', (tester) async {
  // pump Elite ( fecha default ): 'Elegí el horario' + 'Mar, 15 oct' +
  // las 6 horas ( cada una en su clave ).
});

testWidgets('horarios_estados_disponible_seleccionado_ocupado', (tester) async {
  // Elite: '19:00' — color primary + texto Colors.white; '21:00' — color
  // Color(0xFFF1F5F9) + texto text2 dentro de Opacity(0.5); '17:00' — color
  // surface + texto text2 SIN Opacity.
});

testWidgets('horarios_seleccion_cambia_y_ocupado_no_tappable', (tester) async {
  // tap '20:00' → 20:00 primary y 19:00 surface; tap '21:00' (ocupado) →
  // 21:00 sigue ocupado y 20:00 sigue seleccionado; tap '20:00' de nuevo →
  // sigue seleccionado ( sin estado "sin selección" ).
});

testWidgets('horarios_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos ( slots en
  // Expanded: reparto igual ).
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_horarios_test.dart`
Expected: FAIL ( el bloque no existe ).

- [ ] **Step 3: Implementar en `lib/features/detalle/detalle_screen.dart`**

- `DetalleScreen` → `StatefulWidget` ( `final String fecha;` con default `Mar, 15 oct`; `_seleccionado = '19:00'` ). La columna del content agrega `SizedBox(16), _Horarios(cancha: cancha, fecha: fecha, seleccionado: _seleccionado, onSelect: ...)` después de `_Sobre`.
- `_Horarios`: `Column(gap 12, stretch)` — fila título ( `Text('Elegí el horario')` + `Text(fecha)` ) + 2 `Row(gap 10)` de 3 slots cada una ( cada slot `Expanded` ).
- Slot: `GestureDetector` ( handler: si ocupado → vacío; si no → `onSelect(hora)` ) → `Container(key: ValueKey('hora-<hora>'), padding: vertical 13, decoration: radio 10 + color según estado, alignment: center, child: Text(hora, 15, w600, color según estado))`. Ocupado: texto envuelto en `Opacity(0.5)`.
- Estados: `hora == seleccionado` → primary/white; `horasOcupadas.contains(hora)` → `#F1F5F9`/text2(0.5); resto → surface/text2.

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_horarios_test.dart`
Expected: PASS ( 4 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/detalle/detalle_screen.dart src/FrontEnd/test/detalle_horarios_test.dart
git commit -m "feat(detalle): bloque horarios con estados y seleccion (RD detalle-horarios RF-01/02)"
```

### Task 3: `_BarraReserva` + fecha desde el Inicio ( RD RF-03 / §8 )

**Files:**
- Modify: `src/FrontEnd/lib/features/detalle/detalle_screen.dart` ( barra )
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart` ( wiring `fecha` )
- Test: `src/FrontEnd/test/detalle_horarios_test.dart` ( +3 tests )

**Interfaces:**
- Consumes: `DetalleScreen.fecha` ( Task 2 ).
- Produces: la barra fija ( clave `ValueKey('barra-reserva')` ); el Inicio pasa el label del día activo.

- [ ] **Step 1: Write the failing tests ( agregar a `test/detalle_horarios_test.dart` )**

```dart
testWidgets('barra_muestra_precio_total_y_confirmar', (tester) async {
  // Elite: 'PRECIO TOTAL' (11 w600 letterSpacing 1 text2), '$45.00'
  // (24 w700 text), 'Confirmar reserva' (15 w600 Colors.white) +
  // LucideIcons.arrowRight 16 Colors.white.
  // Barra ( key 'barra-reserva' ): color surface, Border(top) color border
  // width 1, padding EdgeInsets.symmetric(vertical: 16, horizontal: 20).
  // Skyline → '$60.00'; Municipal → '$40.00'.
});

testWidgets('barra_confirmar_es_inerte', (tester) async {
  // NavigatorObserver: tap 'Confirmar reserva' → pushes == baseline;
  // pantalla intacta.
});

testWidgets('horarios_fecha_refleja_el_dia_del_inicio', (tester) async {
  // pump MaterialApp(home: MainShell()) 375×844; tap 'MIÉ' en el Inicio;
  // tap card 'Elite Arena Central' → el Detalle muestra 'Mié, 16 oct'.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_horarios_test.dart`
Expected: FAIL ( sin barra ni wiring ).

- [ ] **Step 3: Implementar**

- `_BarraReserva({required Cancha cancha})` según Global Constraints, en `bottomNavigationBar` del `Scaffold` de `DetalleScreen`. Clave `ValueKey('barra-reserva')` en el `Container`. Botón `GestureDetector(onTap: () {})` ( inerte — RF-03 ).
- `inicio_screen.dart`: `_InicioScreenState.build` deriva `final fecha = ...` ( fórmula del Global Constraints, sobre `_diaActivo` ) y lo pasa a `_Canchas(fecha: fecha)` → `_CardCancha(cancha, fecha)` → `DetalleScreen(cancha: cancha, fecha: fecha)` ( `_Canchas` deja de ser `const` donde haga falta ). Los chips y `Ver todo` no cambian.

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` ( suite completo )
Expected: PASS — 124/124 ( 116 previos + 1 Task 1 + 4 Task 2 + 3 de esta task ), sin edits en otros tests.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/detalle/detalle_screen.dart src/FrontEnd/lib/features/inicio/inicio_screen.dart src/FrontEnd/test/detalle_horarios_test.dart
git commit -m "feat(detalle): barra de reserva fija y fecha desde el dia elegido (RD detalle-horarios RF-03)"
```

### Task 4: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/detalle-horarios.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-17 )
- Modify: `docs/requerimientos/README.md` ( quitar `detalle-horarios.md` de activos )
- Move: `docs/requerimientos/detalle-horarios.md` → `docs/HistRequerimientos/detalle-horarios.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 124/124
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\detalle-horarios\` )

- [ ] Detalle de Elite: bloque `Elegí el horario` con `19:00` seleccionado y `21:00` ocupado + barra `PRECIO TOTAL $45.00 / Confirmar reserva`.
- [ ] Tap `20:00` → cambia la selección; `21:00` no reacciona.
- [ ] Elegir MIÉ en el Inicio → el Detalle muestra `Mié, 16 oct`.
- [ ] Comparar con el mockup ( frame 07 + footer ).

- [ ] **Step 3: Escribir `Specs/detalle-horarios.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/detalle-horarios.md docs/HistRequerimientos/detalle-horarios.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: flujo de reserva — éxito / error ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: horarios y barra de reserva del detalle — spec SDD + RD a HistRequerimientos"
```
