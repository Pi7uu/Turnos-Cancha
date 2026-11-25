# Inicio · filtrado + estado sin canchas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Real filtering on the Inicio (search by name + category chips) and the "Sin canchas" empty state (frame 06). This completes the prototype.

**Architecture:** Task 1 wires the filtering state in `InicioScreen`: `_query` (buscador) + `_categoria` (`'5v5'`/`'7v7'`/null) → `_canchasFiltradas()`; the chips toggle `_categoria`. Task 2 renders the frame-06 card when the filtered list is empty and wires `Elegir otra fecha` + `Ver todo` to clear the filters. Task 3: verification + SDD spec + docs closure.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/inicio-filtrado.md` (RD 2026-11-25). Valores de su §4; decisiones de su §8.

## Global Constraints

- Estado en `_InicioScreenState`: `String _query = ''` ( ya existe parcialmente el manejo del buscador — integrar ), `String? _categoria` ( `'5v5'` | `'7v7'` | null ). `List<Cancha> _canchasFiltradas()` = `canchasSimuladas.where((c) => c.nombre.toLowerCase().contains(_query.toLowerCase()) && (_categoria == null || c.tag == _categoria))`.
- Chips `Fútbol 5`/`Fútbol 7` ( RD RF-02 ): `onTap` → `setState(() => _categoria = (_categoria == tag) ? null : tag)` — el chip activo se deselecciona al tocarlo. Visual: el chip activo usa el estilo `$primarySoft`/`$primary` del Tab Bar ( pill activa ) — extensión documentada; los chips siguen viéndose como hoy cuando están inactivos. Claves: `ValueKey('chip-5v5')`, `ValueKey('chip-7v7')`.
- Estado "sin canchas" ( RF-03, frame 06 ): si `_canchasFiltradas().isEmpty`, en lugar de la lista de cards → Container `$surface` radio 16 borde `$border` 1px, vertical, hueco 14, padding 30/24, centrado: círculo 76×76 `$primarySoft` radio 38 con `LucideIcons.calendarX` 36×36 `$primary`, `No hay canchas disponibles` 17px w700 `$text` centrado, `No quedan canchas libres para esta fecha en tu zona. Probá con otro día.` 14px `$text-2` `height: 1.5` centrado, botón `Elegir otra fecha` ( `$primary`, radio 12, padding 13/26, texto 15px w600 blanco, clave `ValueKey('elegir-otra-fecha')` ) → `_limpiarFiltros()`. El bloque `Categorías` queda debajo igual.
- `_limpiarFiltros()`: `setState(() { _query = ''; _categoria = null; _controller.clear(); })` ( con el `TextEditingController` del buscador — crearlo si hoy no existe ). `Ver todo` ( RF-04, clave `ValueKey('ver-todo')` si no la tiene ) → `_limpiarFiltros()`.
- El buscador filtra **en vivo** ( `onChanged` → `setState` ). La fecha NO filtra. El bloque `Canchas disponibles` + `Ver todo` se mantiene visible con la card vacía también ( el frame 06 los muestra ).
- Tipografía por defecto si Inter no está configurada. Sin tokens nuevos. Sin HTTP.

## Review Focus

1. **Filtrado combinado** — buscador `contains` case-insensitive Y categoría; chip activo se deselecciona. Pinned: Task 1 tests `buscador_filtra_por_nombre` y `categorías_filtran_y_se_deseleccionan`.
2. **Estado 06 conforme al frame** — card con `calendar-x`, título, descripción y `Elegir otra fecha`; aparece solo sin resultados. Pinned: Task 2 test `sin_resultados_muestra_estado_06`.
3. **Las acciones limpian todo** — `Elegir otra fecha` y `Ver todo` dejan buscador vacío, sin categoría y las 3 cards. Pinned: Task 2 test `acciones_limpian_filtros`.
4. **Suite previa ( 184 ) sin edits** — los tests existentes del Inicio ( cards, buscador, categorías ) siguen pasando; solo cambian si la interacción antes inerte ahora muta estado ( documentar rulings ). Pinned: suite completo.

---

### Task 1: Filtrado ( RF-01/RF-02 )

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart`
- Test: `src/FrontEnd/test/inicio_filtrado_test.dart`

- [ ] **Step 1: Write the failing tests** ( pump `InicioScreen` a 375×844 ):
  `buscador_filtra_por_nombre` ( escribir `elite` → solo Elite; borrar → 3 ),
  `categorías_filtran_y_se_deseleccionan` ( tap `Fútbol 7` → solo Skyline; tap de nuevo → 3 ),
  `filtros_se_combinan` ( `sky` + `Fútbol 5` → 0 cards ).
- [ ] **Step 2: Run tests to verify they fail** — FAIL.
- [ ] **Step 3: Implementar** — estado + `_canchasFiltradas()` + `onTap` de chips según Global Constraints.
- [ ] **Step 4: Run tests to verify they pass** — PASS ( 3 tests ) + suite previo sin edits injustificados.
- [ ] **Step 5: Commit** — `git commit -m "feat(inicio): filtrado por buscador y categorias (RD inicio-filtrado RF-01/02)"`.

### Task 2: Estado "sin canchas" + acciones ( RF-03/RF-04 )

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart`
- Test: `src/FrontEnd/test/inicio_filtrado_test.dart` ( +3 )

- [ ] **Step 1: Write the failing tests**:
  `sin_resultados_muestra_estado_06` ( `xyz` → `No hay canchas disponibles` + descripción + `Elegir otra fecha` + `calendar-x`; sin cards ),
  `acciones_limpian_filtros` ( filtrar a 0 → tap `Elegir otra fecha` → buscador vacío y 3 cards; filtrar a 0 → tap `Ver todo` → 3 cards ),
  `estado_06_estilos` ( card `$surface` radio 16, círculo 76×76 `$primarySoft`, botón `$primary` radio 12 padding 13/26 ).
- [ ] **Step 2: Run tests to verify they fail** — FAIL.
- [ ] **Step 3: Implementar** — card del frame 06 + `_limpiarFiltros()` en `Elegir otra fecha` y `Ver todo`.
- [ ] **Step 4: Run tests to verify they pass** — `flutter test` completo: PASS ( 190 = 184 + 6 ).
- [ ] **Step 5: Commit** — `git commit -m "feat(inicio): estado sin canchas y limpiar filtros (RD inicio-filtrado RF-03/04)"`.

### Task 3: Verificación final + spec SDD + cierre documental

- [ ] **Step 1: Análisis y suite completo** — `flutter analyze` sin issues; `flutter test` 190/190.
- [ ] **Step 2: Verificación visual 375×844 @2x** ( capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-filtrado\` ): buscador filtrando, chip activo, estado 06 completo, `Elegir otra fecha` restaurando la lista.
- [ ] **Step 3: Escribir `Specs/inicio-filtrado.md`** + índice.
- [ ] **Step 4: Cierre documental** — `AGENTS.md`, `git mv` del RD, README ( queda: fase backend ).
- [ ] **Step 5: Commit final** — `git commit -m "docs: inicio filtrado y estado sin canchas — spec SDD + RD a HistRequerimientos"`.
