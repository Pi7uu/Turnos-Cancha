# Error de reserva Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `No se pudo completar la reserva` screen (mockup frame 10) and make `Confirmar reserva` open it (instead of the success screen) when the chosen hour is in conflict.

**Architecture:** Task 1 adds `Cancha.horasEnConflicto` (mock race data: Elite `['18:00']`). Task 2 builds `lib/features/reserva/reserva_error_screen.dart` (same structure family as `reserva_exitosa_screen.dart`: derived subtitle, detail card with the 3 rows, real action buttons) including the derived `ALTERNATIVAS` count with proper pluralization. Task 3 makes `_confirmarReserva` conditional (error if `horasEnConflicto.contains(hora)`) and adds the flow tests (conflict → error → `Elegir otro horario` back to the Detalle with the selection alive; `Volver al inicio` preserving the shell state).

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/reserva-error.md` (RD 2026-11-25). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `No se pudo completar la reserva` (24px `FontWeight.w700` `AppColors.text`, centrado), subtítulo `La cancha <nombre> del <día> de octubre a las <hora> ya fue reservada por otro usuario.` (15px normal `AppColors.text2`, `height: 1.5`, centrado), `MOTIVO` / `ESTADO DE PAGO` / `ALTERNATIVAS` (11px `FontWeight.w600`, `letterSpacing: 1`, `AppColors.text2`), `Horario ocupado` (14px `FontWeight.w700` `AppColors.text`), badge `SIN COBRO` (10px `FontWeight.w700`, `letterSpacing: 0.5`, `AppColors.primary` sobre `AppColors.primarySoft`, radio 6, padding 5/9), valor de alternativas (14px `FontWeight.w700` `AppColors.primary`), `Te avisamos por email en cuanto se libere un horario.` (13px `AppColors.text2`, centrado), botones `Elegir otro horario` (16px `FontWeight.w600` blanco) y `Volver al inicio` (16px `FontWeight.w600` `AppColors.text`).
- **Pluralización de alternativas** ( decisión del plan, refina el RD §4 ): `1 cancha libre` si N==1, `<N> canchas libres` si N!=1.
- Derivaciones ( RD RF-02 ): `<día>` = dígitos del label `fecha` ( RegExp `(\d+)`, igual que en éxito ); N = cantidad de **otras** `canchasSimuladas` cuyo `horasOcupadas` **no** contiene la hora **y** cuyo `horasEnConflicto` no la contiene ( hora libre ).
- Layout ( RD §4, frame 10 ): `Scaffold` `$bg` + `SafeArea` + `SingleChildScrollView` con `Column` **centrada verticalmente** cuando el contenido es menor que la pantalla ( mismo patrón que el login: `LayoutBuilder` + `ConstrainedBox(minHeight)` + `MainAxisAlignment.center` ) — padding 32 vertical / 24 lateral, hueco 20 entre bloques ( círculo+título+subtítulo con hueco 18 interno ):
  - Círculo: `Container` 96×96 `Color(0xFFFEE2E2)` radio 48 centrado con `LucideIcons.x` 46×46 `AppColors.danger`.
  - Card: `$surface`, radio 16, borde `$border` 1px, padding 20, hueco 14; filas `spaceBetween` ( label + valor ) con separadores `Container(height: 1, color: AppColors.border)`.
  - Botones: ancho completo, radio 12, padding 15 ( primario `$primary` / secundario `$surface` + borde `$border` 1px ), hueco 12.
- Modelo ( Task 1 ): `Cancha` + `final List<String> horasEnConflicto;` — Elite `['18:00']`, Skyline `[]`, Municipal `[]` ( RD §8 ).
- Regla ( RD RF-01 ): `_confirmarReserva` en `_DetalleScreenState` →
  `widget.cancha.horasEnConflicto.contains(_seleccionado) ? ReservaErrorScreen(cancha, fecha, hora) : ReservaExitosaScreen(cancha, fecha, hora)` ( misma firma de datos ).
- Acciones ( RD RF-03 ): `Elegir otro horario` → `Navigator.pop(context)`; `Volver al inicio` → `Navigator.popUntil((r) => r.isFirst)`. Claves `ValueKey('error-elegir-otro')` y `ValueKey('error-volver')` en los botones ( tests de flujo ).
- Tipografía: fuente por defecto si Inter no está configurada. `#FEE2E2` literal. Sin tokens nuevos. Sin HTTP; sin persistencia.

## Review Focus

1. **Subtítulo y alternativas cruzados** — abrir desde Elite/`Mar, 15 oct`/`19:00` muestra esos datos ( no otros ); `2 canchas libres` para Elite 18:00 y `1 cancha libre` ( singular ) para Skyline 21:00. Pinned: Task 2 tests `error_muestra_titulo_subtitulo_card_nota_y_botones` y `error_alternativas_derivadas`.
2. **La regla condicional no rompe el éxito** — 20:00 sigue abriendo la pantalla de éxito; solo las horas en conflicto van al error. Pinned: Task 3 test `barra_confirmar_hora_en_conflicto_abre_error` + el test existente `barra_confirmar_abre_reserva_exitosa` ( sin edits ).
3. **`Elegir otro horario` conserva la selección** — vuelve al Detalle con la hora anterior marcada y permite elegir otra y confirmar con éxito. Pinned: Task 3 test `flujo_error_elegir_otro_horario_vuelve_al_detalle`.
4. **Estilos del frame 10** — círculo `#FEE2E2`/46px, badge `SIN COBRO` ( ls 0.5, radio 6 ), separadores 1px, botones 16px. Pinned: Task 2 test `error_estilos_del_mockup`.
5. **Centrado vertical y sin overflow** — el content se centra como el login y no desborda en 320px ( subtítulo largo con la fuente de test ). Pinned: Task 2 test `error_sin_overflow_375x844_y_chica` + suite previo ( 133 sin edits ).

---

### Task 1: `Cancha.horasEnConflicto` ( data simulada )

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/cancha.dart`
- Test: `src/FrontEnd/test/cancha_test.dart` ( +1 test )

**Interfaces:**
- Consumes: nada.
- Produces ( Task 2/3 ): `Cancha` + `final List<String> horasEnConflicto;` con los valores del Global Constraints.

- [ ] **Step 1: Write the failing test ( agregar a `test/cancha_test.dart` )**

```dart
test('canchas_simuladas_horas_en_conflicto', () {
  expect(canchasSimuladas[0].horasEnConflicto, ['18:00']);
  expect(canchasSimuladas[1].horasEnConflicto, isEmpty);
  expect(canchasSimuladas[2].horasEnConflicto, isEmpty);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: FAIL ( el campo no existe ).

- [ ] **Step 3: Implementar en `lib/features/inicio/cancha.dart`**

+ `final List<String> horasEnConflicto;` ( constructor `const` ); `canchasSimuladas` con los valores del Global Constraints.

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: PASS ( 7 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/cancha.dart src/FrontEnd/test/cancha_test.dart
git commit -m "feat(reserva): Cancha con horasEnConflicto simuladas (RD reserva-error §8)"
```

### Task 2: `ReservaErrorScreen` ( RD RF-02/RF-03 )

**Files:**
- Create: `src/FrontEnd/lib/features/reserva/reserva_error_screen.dart`
- Test: `src/FrontEnd/test/reserva_error_test.dart`

**Interfaces:**
- Consumes: `Cancha` ( Task 1 ).
- Produces ( Task 3 ): `class ReservaErrorScreen extends StatelessWidget`,
  `const ReservaErrorScreen({super.key, required this.cancha, required this.fecha, required this.hora})`; botones con claves `error-elegir-otro` / `error-volver`.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/reserva_error_test.dart`**

Pump base: `MaterialApp(home: ReservaErrorScreen(cancha: <cancha>, fecha: 'Mar, 15 oct', hora: '<hora>'))` con viewport 375×844 @2x.

```dart
testWidgets('error_muestra_titulo_subtitulo_card_nota_y_botones', (tester) async {
  // Elite/18:00: 'No se pudo completar la reserva' + LucideIcons.x +
  // 'La cancha Elite Arena Central del 15 de octubre a las 18:00 ya fue
  // reservada por otro usuario.' + 'MOTIVO' + 'Horario ocupado' +
  // 'ESTADO DE PAGO' + 'SIN COBRO' + 'ALTERNATIVAS' + '2 canchas libres' +
  // 'Te avisamos por email en cuanto se libere un horario.' +
  // 'Elegir otro horario' + 'Volver al inicio'.
});

testWidgets('error_alternativas_derivadas', (tester) async {
  // Elite 18:00 → '2 canchas libres' ( Skyline y Municipal libres );
  // Skyline 21:00 → '1 cancha libre' ( solo Municipal: Elite la tiene
  // ocupada ) — singular correcto.
});

testWidgets('error_estilos_del_mockup', (tester) async {
  // Círculo 96×96 Color(0xFFFEE2E2) radio 48; LucideIcons.x 46 AppColors.danger.
  // Título 24 w700 text; subtítulo 15 text2 height 1.5.
  // Card: surface, radio 16, borde border 1px; labels 11 w600 ls 1 text2;
  // 'Horario ocupado' 14 w700 text; badge: primarySoft, radio 6, padding
  // 5/9, texto 10 w700 ls 0.5 primary; '2 canchas libres' 14 w700 primary;
  // nota 13 text2; botones: texto 16 w600 ( primario blanco, secundario
  // text ), radio 12, padding 15.
});

testWidgets('error_elegir_otro_horario_hace_pop', (tester) async {
  // Wrapper con botón que empuja ReservaErrorScreen; tap 'Elegir otro
  // horario' → vuelve al wrapper ( la ruta se desapiló ).
});

testWidgets('error_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/reserva_error_test.dart`
Expected: FAIL ( la pantalla no existe ).

- [ ] **Step 3: Implementar `lib/features/reserva/reserva_error_screen.dart`**

Estructura según Global Constraints ( `Column` centrada con `LayoutBuilder`+`ConstrainedBox(minHeight)` patrón login; bloques del §4; botones con las claves fijas; `Elegir otro horario` → `pop`, `Volver al inicio` → `popUntil(isFirst)`; alternativas derivadas + pluralización ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/reserva_error_test.dart`
Expected: PASS ( 5 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/reserva/reserva_error_screen.dart src/FrontEnd/test/reserva_error_test.dart
git commit -m "feat(reserva): pantalla Error de reserva del mockup (RD reserva-error RF-02/03)"
```

### Task 3: Regla condicional en `Confirmar reserva` ( RD RF-01 )

**Files:**
- Modify: `src/FrontEnd/lib/features/detalle/detalle_screen.dart` ( `_confirmarReserva` )
- Test: `src/FrontEnd/test/detalle_horarios_test.dart` ( +3 tests )

**Interfaces:**
- Consumes: `ReservaErrorScreen` ( Task 2 ), `Cancha.horasEnConflicto` ( Task 1 ).
- Produces: `_confirmarReserva` condicional ( Global Constraints ).

- [ ] **Step 1: Write the failing tests ( agregar a `test/detalle_horarios_test.dart` )**

```dart
testWidgets('barra_confirmar_hora_en_conflicto_abre_error', (tester) async {
  // pump DetalleScreen(Elite, 'Mar, 15 oct'); ensureVisible + tap '18:00';
  // tap 'Confirmar reserva' → find.text('No se pudo completar la reserva').
});

testWidgets('flujo_error_elegir_otro_horario_vuelve_al_detalle', (tester) async {
  // mismo flujo → tap (clave 'error-elegir-otro') → sigue en el Detalle:
  // find.text('Elegí el horario') visible y el slot '18:00' sigue
  // seleccionado; tap '20:00' + 'Confirmar reserva' → ¡Reserva exitosa!
});

testWidgets('flujo_error_volver_conserva_estado_inicio', (tester) async {
  // pump MainShell() 375×844: 'futbol' + 'MIÉ' + card Elite → tap '18:00' →
  // Confirmar → error → tap (clave 'error-volver') → Inicio con
  // find.text('futbol') y chip dia-16 primary.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_horarios_test.dart`
Expected: FAIL ( la regla no existe: 18:00 abre éxito ).

- [ ] **Step 3: Implementar en `detalle_screen.dart`**

`_confirmarReserva` condicional según Global Constraints ( mismo `cancha/fecha/hora` para ambas pantallas ). Nada más cambia.

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` ( suite completo )
Expected: PASS — 142/142 ( 133 previos + 1 Task 1 + 5 Task 2 + 3 de esta task ), sin edits en otros tests.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/detalle/detalle_screen.dart src/FrontEnd/test/detalle_horarios_test.dart
git commit -m "feat(reserva): Confirmar reserva abre error si la hora esta en conflicto (RD reserva-error RF-01)"
```

### Task 4: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/reserva-error.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-25 )
- Modify: `docs/requerimientos/README.md` ( quitar `reserva-error.md` de activos )
- Move: `docs/requerimientos/reserva-error.md` → `docs/HistRequerimientos/reserva-error.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 142/142
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\reserva-error\` )

- [ ] Detalle Elite → 18:00 → `Confirmar reserva` → pantalla de error con datos y card.
- [ ] `Elegir otro horario` → Detalle con 18:00 marcado; cambiar a 20:00 → éxito.
- [ ] Comparar con el frame 10 del mockup.

- [ ] **Step 3: Escribir `Specs/reserva-error.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/reserva-error.md docs/HistRequerimientos/reserva-error.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( sigue: Mis reservas / Favoritos / Perfil / filtrado / estado 06 ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: error de reserva implementado — spec SDD + RD a HistRequerimientos"
```
