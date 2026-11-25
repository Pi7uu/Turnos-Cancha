# Favoritos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Favoritos screen (frame 12): favorite court cards with data, heart to unfavorite (with empty state) and `Reservar` → Detalle.

**Architecture:** Task 1 creates `lib/features/favoritos/favoritos_locales.dart` (in-memory list seeded from `canchasSimuladas`). Task 2 builds `lib/features/favoritos/favoritos_screen.dart` (header + cards per RD §4) and wires it into `MainShell`, replacing the last placeholder. Task 3 adds the actions: heart → `quitarFavorito` + empty state + `Explorar canchas` → tab Inicio; `Reservar` → `DetalleScreen` (fecha `Mar, 15 oct`). Task 4: verification + SDD spec + docs closure.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/favoritos.md` (RD 2026-11-25). Valores de su §4; decisiones de su §8.

## Global Constraints

- Store ( `favoritos_locales.dart` ): `final List<Cancha> favoritosLocales = [...canchasSimuladas]`; `void quitarFavorito(Cancha)` ( remove por identidad ); `void resetFavoritos()` ( `@visibleForTesting` ). Sembrado en orden Elite / Skyline / Municipal.
- `FavoritosScreen` ( `favoritos_screen.dart` ): lee `favoritosLocales`. Header: `Favoritos` 24px w700 `$text` + contador `${n} cancha${n == 1 ? '' : 's'}` 14px `$text-2` ( space_between, centrado ). Lista con `ListView.separated` ( hueco 12 — el `space_between` del mockup se aproxima con hueco fijo + scroll; documentado en el spec ).
- Card ( RD §4 ): `$surface` radio 16 borde `$border` 1px, vertical hueco 12 padding 14 — Superior ( fila hueco 12 centrada: foto `Image.asset(cancha.foto)` 92×92 radio 12 + Info vertical hueco 7: nombre fila space_between ( nombre 15px w700 `$text` fill + `heart` 18×18 #EF4444 clave `ValueKey('quitar-<nombre>')` ), distancia fila hueco 5 ( `map-pin` 13×13 `$text-2` + `cancha.distancia` 13px `$text-2` ), rating fila hueco 5 ( `star` 13×13 #F59E0B + `cancha.puntuacion` 13px `$text-2` ) ) + Inferior ( fila space_between centrada: precio hueco 4 ( `cancha.precio` 17px w700 `$primary` + `/ hora` 12px `$text-2` ) + `Reservar` ( `$primary` radio 10 padding 11/20, texto 14px w600 blanco, clave `ValueKey('reservar-<nombre>')` ) ).
- Acciones ( RF-02/03 ): corazón → `setState(() => quitarFavorito(cancha))`; lista vacía → `_EstadoVacio` ( círculo 88×88 `$primarySoft` radio 44 con `heart` 40×40 `$primary`, `Todavía no tenés favoritos` 19px w700, `Cuando marques una cancha como favorita va a aparecer acá.` 14px `$text-2` `height: 1.5` ancho máx 270 centrado, botón `Explorar canchas` `$primary` radio 12 padding 14/30 15px w600 blanco clave `ValueKey('explorar-favoritos')` → `widget.onExplorar?.call()` ). `Reservar` → `Navigator.push(DetalleScreen(cancha: cancha, fecha: 'Mar, 15 oct'))`.
- `MainShell`: tab Favoritos deja de ser placeholder → `FavoritosScreen(key: ValueKey('favoritos-screen'), onExplorar: () => setState(() => _activo = TabApp.inicio))`. Clave vieja `placeholder-favoritos` **se elimina** — actualizar `main_shell_test.dart` ( cambio de alcance documentado en el spec ).
- Datos: se reutilizan `canchasSimuladas` sin campos nuevos. Sin tokens nuevos. Sin HTTP.

## Review Focus

1. **Card conforme al frame 12** — foto 92×92, corazón 18×18 rojo, distancia/rating con sus glyphs, precio + `Reservar`. Pinned: Task 2 test `favoritos_muestra_las_cards_del_mockup`.
2. **Quitar favorito actualiza todo** — corazón saca la card y el contador ( `3 canchas` → `2 canchas` ); vaciar muestra el estado vacío y `Explorar canchas` cambia al tab Inicio. Pinned: Task 3 tests.
3. **Reservar abre el Detalle de esa cancha** con fecha `Mar, 15 oct` y Volver regresa. Pinned: Task 3 test `reservar_abre_el_detalle`.
4. **Suite previa ( 175 ) sin edits injustificados** — solo los tests que referencien `placeholder-favoritos` cambian. Pinned: suite completo.

---

### Task 1: Store `favoritos_locales`

**Files:**
- Create: `src/FrontEnd/lib/features/favoritos/favoritos_locales.dart`
- Test: `src/FrontEnd/test/favoritos_locales_test.dart`

- [ ] **Step 1: Write the failing tests** ( `setUp(resetFavoritos)` ): `store_arranca_con_las_3` ( orden Elite/Skyline/Municipal ), `quitar_favorito_elimina_de_la_lista` ( quitar Skyline → quedan 2, sin Skyline ), `reset_vuelve_a_la_semilla`.
- [ ] **Step 2: Run tests to verify they fail** — `flutter test test/favoritos_locales_test.dart` → FAIL.
- [ ] **Step 3: Implementar** — store según Global Constraints.
- [ ] **Step 4: Run tests to verify they pass** — PASS ( 3 tests ).
- [ ] **Step 5: Commit** — `git commit -m "feat(favoritos): store de favoritos en memoria (RD favoritos)"`.

### Task 2: `FavoritosScreen` + wiring en `MainShell`

**Files:**
- Create: `src/FrontEnd/lib/features/favoritos/favoritos_screen.dart`
- Modify: `src/FrontEnd/lib/features/navegacion/main_shell.dart`, `src/FrontEnd/test/main_shell_test.dart`
- Test: `src/FrontEnd/test/favoritos_test.dart`

- [ ] **Step 1: Write the failing tests**: `favoritos_muestra_header_y_contador` ( `Favoritos` + `3 canchas` ), `favoritos_muestra_las_cards_del_mockup` ( 3 cards: `Elite Arena Central`, `1.2 km de vos`, `4.8 (124 reseñas)`, `$45`, `/ hora`, `Reservar`×3, corazones×3 ), `favoritos_card_estilos_del_mockup` ( foto 92×92 radio 12, botón `$primary` radio 10 padding 11/20 ).
- [ ] **Step 2: Run tests to verify they fail** — FAIL ( el screen no existe ).
- [ ] **Step 3: Implementar** — screen + wiring según Global Constraints; actualizar `main_shell_test.dart` ( `placeholder-favoritos` → `favoritos-screen` ).
- [ ] **Step 4: Run tests to verify they pass** — `flutter test` completo: PASS ( 181 = 175 + 3 store + 3 screen ).
- [ ] **Step 5: Commit** — `git commit -m "feat(favoritos): pantalla Favoritos con cards del mockup (RD favoritos RF-01)"`.

### Task 3: Acciones ( RF-02/RF-03 )

**Files:**
- Modify: `src/FrontEnd/lib/features/favoritos/favoritos_screen.dart`
- Test: `src/FrontEnd/test/favoritos_test.dart` ( +3 )

- [ ] **Step 1: Write the failing tests**: `corazon_quita_favorito_y_actualiza_contador` ( tap corazón Elite → 2 cards, `2 canchas` ), `lista_vacia_muestra_estado_vacio` ( quitar las 3 → `Todavía no tenés favoritos` + `Explorar canchas` ), `reservar_abre_el_detalle` ( tap `Reservar` de Skyline → Detalle de Skyline con `Mar, 15 oct`; `Volver` regresa a Favoritos ).
- [ ] **Step 2: Run tests to verify they fail** — FAIL.
- [ ] **Step 3: Implementar** — acciones según Global Constraints.
- [ ] **Step 4: Run tests to verify they pass** — `flutter test` completo: PASS ( 184 = 181 + 3 ).
- [ ] **Step 5: Commit** — `git commit -m "feat(favoritos): quitar favorito, estado vacio y Reservar al Detalle (RD favoritos RF-02/03)"`.

### Task 4: Verificación final + spec SDD + cierre documental

- [ ] **Step 1: Análisis y suite completo** — `flutter analyze` sin issues; `flutter test` 184/184.
- [ ] **Step 2: Verificación visual 375×844 @2x** ( capturas en `%LOCALAPPDATA%\Temp\opencode\shots\favoritos\` ): pantalla completa, corazón quitando una card, estado vacío, `Reservar` en el Detalle.
- [ ] **Step 3: Escribir `Specs/favoritos.md`** + índice.
- [ ] **Step 4: Cierre documental** — `AGENTS.md`, `git mv` del RD, README ( sigue: filtrado + estado 06 del Inicio / fase backend ).
- [ ] **Step 5: Commit final** — `git commit -m "docs: pantalla favoritos — spec SDD + RD a HistRequerimientos"`.
