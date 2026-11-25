# Mis reservas · acciones y store Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Mis reservas: real card actions (cancelar/confirmar/Ver QR), the in-memory store shared with the reservation flow (created reservations appear in Próximas), empty states (frame 09) and the "Sin QR" variant (frame 08).

**Architecture:** Task 1 creates `lib/features/mis_reservas/reservas_locales.dart` (mutable list seeded from `reservasSimuladas` + `registrarReserva`/`cancelarReserva`/`confirmarReserva`/`resetReservas`) and extends `Reserva` with `tieneQr` + `copyWith`, and `Cancha` with `sector`. Task 2 wires the card actions (state moves via the store; `Ver QR` opens a simulated dialog). Task 3 renders the empty state when a tab has no reservations (`Explorar canchas` = the existing `onVolver`). Task 4 registers the flow's successful reservation into the store from `_confirmarReserva`. Task 5: verification + SDD spec + docs closure.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/mis-reservas-acciones.md` (RD 2026-11-25). Valores de su §4; decisiones de su §8.

## Global Constraints

- Store ( `reservas_locales.dart` ): `final List<Reserva> reservasLocales = [...reservasSimuladas]`; `void registrarReserva(Reserva)` ( inserta al inicio ); `void cancelarReserva(Reserva)` / `void confirmarReserva(Reserva)` ( reemplazan el elemento por `copyWith(estado: ...)` — misma identidad por posición ); `void resetReservas()` ( `@visibleForTesting`, re-sembrar ). `Reserva.copyWith({EstadoReserva? estado, bool? tieneQr})`.
- `Reserva` + `final bool tieneQr` ( constructor `const` ); semillas: Elite Mar 15 `tieneQr: false`, las demás `true` ( RD §8 ).
- `Cancha` + `final String sector`: Elite `Cancha A (5v5)`, Skyline `Cancha principal (7v7)`, Municipal `Cancha B (5v5)`.
- Registro del flujo ( RF-02 ): en `_DetalleScreenState._confirmarReserva`, rama de éxito ANTES del push: `registrarReserva(Reserva(nombre: widget.cancha.nombre, foto: widget.cancha.foto, fecha: '${widget.fecha} 2026', horario: '${_seleccionado} - ${_horaFin()}', sector: widget.cancha.sector, estado: EstadoReserva.confirmada, tieneQr: true))` donde `_horaFin()` = hora + 1 ( `20:00` → `21:00`; `22:00` → `23:00` ). La rama de error NO registra.
- Acciones ( RF-01 ): en `_CardReserva`, los `GestureDetector` pasan a: `Cancelar reserva` → `cancelarReserva(reserva)` + `setState`; `Confirmar` → `confirmarReserva(reserva)` + `setState`; `Ver QR` → `_mostrarQr(context)` ( diálogo del RD §4: `showDialog` con `AlertDialog`-style a medida — `$surface` radio 16 padding 24, hueco 16: `Tu QR` 18px w700, cuadro 160×160 borde `$border` radio 12 con `LucideIcons.qrCode` 96×96 `$text-2`, `Mostrá este código en la entrada.` 13px `$text-2` centrado, botón `Cerrar` clave `ValueKey('qr-cerrar')` ). La pantalla lee `reservasLocales` ( no la copia del modelo ).
- Variante Sin QR ( RF-04 ): botón `Ver QR` solo si `estado == confirmada && tieneQr`; `Confirmar` solo si `estado == pendiente`; `Cancelar reserva` solo en Próximas ( igual que hoy ).
- Estado vacío ( RF-03, frame 09 ): si la lista filtrada está vacía, en lugar del `ListView`: `Column` centrada ( padding 40/24, hueco 14 ) — círculo 88×88 `$primarySoft` radio 44 con `LucideIcons.calendarDays` 40×40 `$primary`, `No tenés reservas` 19px w700 `$text` centrado, descripción 14px `$text-2` `height: 1.5` ( ancho máx 270, centrada ), botón `Explorar canchas` ( `$primary`, radio 12, padding 14/30, texto 15px w600 blanco, clave `ValueKey('explorar-canchas')` ) → `widget.onVolver?.call()`.
- Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos. Sin HTTP; sin persistencia entre arranques.

## Review Focus

1. **Las acciones mutan el estado correcto** — cancelar mueve a Canceladas ( badge `CANCELADA` ) y saca de Próximas; confirmar cambia badge a `CONFIRMADA` y agrega `Ver QR`. Pinned: Task 2 tests `accion_cancelar_mueve_a_canceladas` y `accion_confirmar_cambia_estado`.
2. **El flujo registra y el error NO** — reservar con éxito agrega la reserva a Próximas con sus datos ( `20:00 - 21:00`, `Cancha A (5v5)` ); el camino de error no agrega nada. Pinned: Task 4 test `flujo_exitoso_registra_en_próximas` y `flujo_error_no_registra`.
3. **Variante Sin QR** — la semilla Elite ( `tieneQr: false` ) muestra solo `Cancelar reserva`; una confirmada con QR muestra `Ver QR`. Pinned: Task 2 test `variante_sin_qr`.
4. **Estado vacío con su acción** — pestaña vacía muestra el frame 09 y `Explorar canchas` cambia al tab Inicio. Pinned: Task 3 test `pestana_vacia_muestra_estado_vacio`.
5. **Reset del store entre tests** — `resetReservas()` en los `setUp` ( sin fugas de estado entre tests ) y suite previo ( 155 ) sin edits. Pinned: Task 1 test del store + suite completo.

---

### Task 1: Store `reservas_locales` + campos nuevos

**Files:**
- Create: `src/FrontEnd/lib/features/mis_reservas/reservas_locales.dart`
- Modify: `src/FrontEnd/lib/features/mis_reservas/reserva.dart` ( `tieneQr`, `copyWith`, semillas )
- Modify: `src/FrontEnd/lib/features/inicio/cancha.dart` ( `sector` )
- Test: `src/FrontEnd/test/reservas_locales_test.dart`, `src/FrontEnd/test/cancha_test.dart` ( +1 )

**Interfaces:**
- Consumes: `Reserva`/`EstadoReserva`/`reservasSimuladas`, `Cancha`.
- Produces ( Tasks 2/4 ): `reservasLocales`, `registrarReserva`, `cancelarReserva`, `confirmarReserva`, `resetReservas`, `Reserva.copyWith`; `Cancha.sector`.

- [ ] **Step 1: Write the failing tests**

`test/reservas_locales_test.dart` ( `setUp(resetReservas)` ):

```dart
test('store_arranca_sembrado', ...)          // 4 reservas, misma data
test('registrar_reserva_agrega_al_inicio', ...) // +1 al inicio, 5
test('cancelar_reserva_cambia_estado', ...)     // Elite Mar 15 → cancelada
test('confirmar_reserva_cambia_estado', ...)    // Skyline → confirmada
test('reset_vuelve_a_la_semilla', ...)          // tras mutar, reset → 4 semilla
```

`test/cancha_test.dart` +1: `canchas_simuladas_sector` ( `Cancha A (5v5)` / `Cancha principal (7v7)` / `Cancha B (5v5)` ).

- [ ] **Step 2: Run tests to verify they fail**

Run: `C:\src\flutter\bin\flutter.bat test test/reservas_locales_test.dart test/cancha_test.dart`
Expected: FAIL ( el store y los campos no existen ).

- [ ] **Step 3: Implementar**

`Reserva` + `tieneQr` + `copyWith`; semillas con `tieneQr` ( Elite Mar 15 `false` ); `Cancha` + `sector`; `reservas_locales.dart` con la lista mutable y los helpers del Global Constraints.

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test test/reservas_locales_test.dart test/cancha_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/mis_reservas src/FrontEnd/lib/features/inicio/cancha.dart src/FrontEnd/test/reservas_locales_test.dart src/FrontEnd/test/cancha_test.dart
git commit -m "feat(mis-reservas): store en memoria y campos tieneQr/sector (RD mis-reservas-acciones)"
```

### Task 2: Acciones de las cards ( RF-01/RF-04 )

**Files:**
- Modify: `src/FrontEnd/lib/features/mis_reservas/mis_reservas_screen.dart`
- Test: `src/FrontEnd/test/mis_reservas_acciones_test.dart`

**Interfaces:**
- Consumes: store ( Task 1 ).
- Produces ( Task 3 ): `_CardReserva` con acciones reales + diálogo `_mostrarQr`.

- [ ] **Step 1: Write the failing tests** ( `setUp(resetReservas)`; pump con `MisReservasScreen()` + `setState` vía tap ):

```dart
testWidgets('accion_cancelar_mueve_a_canceladas', ...)   // tap Cancelar en Elite → Próximas solo Skyline; Canceladas tiene Elite + badge CANCELADA
testWidgets('accion_confirmar_cambia_estado', ...)        // tap Confirmar en Skyline → badge CONFIRMADA + aparece 'Ver QR'
testWidgets('ver_qr_abre_dialogo_y_cierra', ...)          // tap 'Ver QR' → 'Tu QR' + 'Mostrá este código...'; tap 'Cerrar' → cierra
testWidgets('variante_sin_qr', ...)                       // Elite (tieneQr false) muestra SOLO 'Cancelar reserva' (sin 'Ver QR')
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `C:\src\flutter\bin\flutter.bat test test/mis_reservas_acciones_test.dart`
Expected: FAIL ( las acciones son inertes ).

- [ ] **Step 3: Implementar**

Acciones según Global Constraints ( mutan el store + `setState` ); diálogo QR; botones según `tieneQr`/estado ( RF-04 ).

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test test/mis_reservas_acciones_test.dart`
Expected: PASS ( 4 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/mis_reservas/mis_reservas_screen.dart src/FrontEnd/test/mis_reservas_acciones_test.dart
git commit -m "feat(mis-reservas): acciones cancelar/confirmar/ver QR y variante sin QR (RD mis-reservas-acciones RF-01/04)"
```

### Task 3: Estados vacíos ( RF-03 )

**Files:**
- Modify: `src/FrontEnd/lib/features/mis_reservas/mis_reservas_screen.dart`
- Test: `src/FrontEnd/test/mis_reservas_acciones_test.dart` ( +2 )

**Interfaces:**
- Consumes: store + `onVolver`.
- Produces: estado vacío del frame 09.

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('pestana_vacia_muestra_estado_vacio', ...)   // cancelar las 2 de Próximas → 'No tenés reservas' + descripción + 'Explorar canchas' + LucideIcons.calendarDays
testWidgets('explorar_canchas_cambia_al_inicio', ...)    // tap 'Explorar canchas' → tab Inicio activo ( MainShell )
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `C:\src\flutter\bin\flutter.bat test test/mis_reservas_acciones_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implementar**

Si `_reservasDeLaPestana().isEmpty` → bloque vacío del Global Constraints en lugar del `ListView`; `Explorar canchas` → `widget.onVolver?.call()`.

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test test/mis_reservas_acciones_test.dart`
Expected: PASS ( 6 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/mis_reservas/mis_reservas_screen.dart src/FrontEnd/test/mis_reservas_acciones_test.dart
git commit -m "feat(mis-reservas): estados vacios con Explorar canchas (RD mis-reservas-acciones RF-03)"
```

### Task 4: Registro desde el flujo ( RF-02 )

**Files:**
- Modify: `src/FrontEnd/lib/features/detalle/detalle_screen.dart`
- Test: `src/FrontEnd/test/mis_reservas_acciones_test.dart` ( +2 )

**Interfaces:**
- Consumes: `registrarReserva` + `Cancha.sector`.
- Produces: el flujo de éxito alimenta el store.

- [ ] **Step 1: Write the failing tests**

```dart
testWidgets('flujo_exitoso_registra_en_próximas', ...)  // Detalle Elite 20:00 → Confirmar → éxito → Ver mis reservas → card nueva: '20:00 - 21:00', 'Cancha A (5v5)', 'CONFIRMADA', 'Ver QR'
testWidgets('flujo_error_no_registra', ...)              // Detalle Elite 18:00 (conflicto) → error → Ver mis reservas → las 2 semillas intactas (sin nueva)
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `C:\src\flutter\bin\flutter.bat test test/mis_reservas_acciones_test.dart`
Expected: FAIL ( el flujo no registra ).

- [ ] **Step 3: Implementar**

`_confirmarReserva` registra antes del push ( solo en éxito ) según Global Constraints.

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` ( suite completo )
Expected: PASS — 168/168 ( 155 previos + 5 store + 4 acciones + 2 vacío + 2 flujo ), sin edits en otros tests.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/detalle/detalle_screen.dart src/FrontEnd/test/mis_reservas_acciones_test.dart
git commit -m "feat(mis-reservas): el flujo exitoso registra la reserva en el store (RD mis-reservas-acciones RF-02)"
```

### Task 5: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/mis-reservas-acciones.md` ( antes de mover el RD )
- Modify: `Specs/README.md`, `AGENTS.md`, `docs/requerimientos/README.md`
- Move: `docs/requerimientos/mis-reservas-acciones.md` → `docs/HistRequerimientos/mis-reservas-acciones.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo** — `flutter analyze` sin issues; `flutter test` 168/168.
- [ ] **Step 2: Verificación visual 375×844 @2x** ( capturas en `%LOCALAPPDATA%\Temp\opencode\shots\mis-reservas-acciones\` ): cancelar/confirmar con cambio de pestañas, diálogo QR, variante sin QR, estado vacío, y reserva creada desde el flujo apareciendo en Próximas.
- [ ] **Step 3: Escribir `Specs/mis-reservas-acciones.md`** + índice.
- [ ] **Step 4: Cierre documental** — `AGENTS.md`, `git mv` del RD, README ( sigue: Perfil / Favoritos / filtrado + estado 06 del Inicio ).
- [ ] **Step 5: Commit final** — `git commit -m "docs: mis reservas acciones y store — spec SDD + RD a HistRequerimientos"`.
