# Categorías del Inicio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the "Categorías" block to the Inicio screen: title + 2 chips (`Fútbol 5`, `Fútbol 7`) with icon boxes, per the mockup.

**Architecture:** One presentational widget `_Categorias` appended as the 5th block of `inicio_screen.dart`'s scrollable column (gap 16). Chips are `Expanded` (equal split) inside a row with gap 12; each chip is a dead `GestureDetector` (that also unfocuses, consistent with the other inert controls). No data layer, no state — the chips are static until the filtering RD.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/inicio-categorias.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `Categorías` (17px `FontWeight.w700` `AppColors.text`), `Fútbol 5`, `Fútbol 7` (14px `FontWeight.w600` `AppColors.text`).
- Bloque vertical hueco **10** (título ↔ fila); 5º hijo de la columna con `SizedBox(height: 16)` antes (columna scrolleable existente).
- Fila de chips: hueco **12**, los 2 chips en `Expanded` (reparto igual — RD §4 `fill_container`).
- Chip: `Container` ( clave `ValueKey('categoria-futbol5')` / `ValueKey('categoria-futbol7')` ) — vertical centrado, hueco 8, padding 18 vertical / 12 horizontal, radio 14, fondo `AppColors.surface`, borde `AppColors.border` 1px. Caja de ícono: 44×44, fondo `AppColors.primarySoft`, radio 22, centrada: glyph lucide 20×20 `AppColors.primary` ( `LucideIcons.users` en Fútbol 5, `LucideIcons.layoutGrid` en Fútbol 7 ).
- Chips inertes ( RD RF-02 ): `GestureDetector` con handler que solo llama `FocusScope.of(context).unfocus()` ( mismo patrón que cards/`Reservar`/`Ver todo` ).
- Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos. Sin HTTP. Sin estado seleccionado ( el mockup no lo dibuja ).

## Review Focus

1. **Íconos cruzados entre chips** — `users` en Fútbol 5 y `layout-grid` en Fútbol 7 ( no al revés ). Pinned: Task 1 test `categorias_muestra_titulo_y_2_chips` ( asserts por chip ).
2. **Geometría del chip** — padding 18/12, radio 14 del chip vs radio 22 de la caja de ícono, caja 44×44 con glyph 20. Pinned: Task 1 test `categorias_estilo_del_mockup`.
3. **Reparto igual + hueco 12** — anchos iguales y separación exacta ( como los chips de días ). Pinned: Task 1 test `categorias_chips_mismo_ancho_hueco_12`.
4. **Chips inertes** — sin navegación ni cambios. Pinned: Task 1 test `categorias_chips_inertes` ( NavigatorObserver ).
5. **Sin overflow** — `Fútbol 5` a 14px en la fuente de test ocupa 112px y el chip tiene 138px de ancho en 320: entra justo; si no, el label elipsa. Pinned: Task 1 test `categorias_sin_overflow_375x844_y_chica` + suite previo ( 95 tests sin edits ).

---

### Task 1: `_Categorias` en `inicio_screen.dart` ( RD RF-01/RF-02 )

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart`
- Test: `src/FrontEnd/test/inicio_categorias_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `LucideIcons.users`, `LucideIcons.layoutGrid`, la columna scrolleable existente.
- Produces ( Task 2 ): `InicioScreen` sin cambios de firma; widget `_Categorias` ( privado ).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/inicio_categorias_test.dart`**

Pump: `tester.pumpWidget(const MaterialApp(home: InicioScreen()))`. Helper `_decoChip(tester, slug)` = `BoxDecoration` del `Container` con `key: ValueKey('categoria-<slug>')`.

```dart
testWidgets('categorias_muestra_titulo_y_2_chips', (tester) async {
  expect(find.text('Categorías'), findsOneWidget);
  expect(find.text('Fútbol 5'), findsOneWidget);
  expect(find.text('Fútbol 7'), findsOneWidget);
  // Íconos por chip ( no cruzados ):
  expect(find.descendant(of: find.byKey(const ValueKey('categoria-futbol5')),
      matching: find.byIcon(LucideIcons.users)), findsOneWidget);
  expect(find.descendant(of: find.byKey(const ValueKey('categoria-futbol7')),
      matching: find.byIcon(LucideIcons.layoutGrid)), findsOneWidget);
});

testWidgets('categorias_estilo_del_mockup', (tester) async {
  // Chip (futbol5): color surface, radio 14, borde border 1px, padding
  // EdgeInsets.symmetric(vertical: 18, horizontal: 12).
  // Caja de ícono: Container 44×44 (getSize) con color primarySoft y
  // borderRadius 22; glyph Icon size 20 color primary.
  // Label: fontSize 14, fontWeight w600, color text.
});

testWidgets('categorias_chips_mismo_ancho_hueco_12', (tester) async {
  // getSize de los 2 chips → mismo ancho; getRect().left(b) - getRect().right(a) == 12.
});

testWidgets('categorias_chips_inertes', (tester) async {
  // NavigatorObserver: tap 'Fútbol 5' y tap 'Fútbol 7' → pushes == baseline;
  // la pantalla sigue igual ( find.text('Categorías') findsOneWidget ).
});

testWidgets('categorias_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_categorias_test.dart` ( desde `src/FrontEnd/` )
Expected: FAIL ( no hay bloque de categorías ).

- [ ] **Step 3: Implementar en `lib/features/inicio/inicio_screen.dart`**

- Columna: agregar `const SizedBox(height: 16), const _Categorias()` después de `_Canchas()`.
- `_Categorias` ( presentacional ): `Column(crossAxisAlignment: stretch, children: [ Text('Categorías', 17, w700, text), SizedBox(10), Padding? no, Row(gap 12, children: [Expanded(_ChipCategoria(...futbol5)), Expanded(_ChipCategoria(...futbol7))]) ])`.
- `_ChipCategoria({required String slug, required IconData icono, required String label})`: `GestureDetector` ( handler: solo `unfocus` ) → `Container(key: ValueKey('categoria-<slug>'), padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12), decoration: surface/radio14/border1, alignment: center, child: Column(mainAxisSize: min, children: [Container(44×44, primarySoft, radio 22, child: Center(Icon(icono, 20, primary))), SizedBox(8), Text(label, 14, w600, text)]))`. Si el label no cupiera ( fuente de test, <320px ), envolver en `Flexible` + ellipsis ( decisión del test de overflow: el test manda ).

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_categorias_test.dart`
Expected: PASS ( 5 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/inicio_screen.dart src/FrontEnd/test/inicio_categorias_test.dart
git commit -m "feat(inicio): bloque categorias del mockup (RD inicio-categorias RF-01/02)"
```

### Task 2: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/inicio-categorias.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-17; pendiente sin "categorías" )
- Modify: `docs/requerimientos/README.md` ( quitar `inicio-categorias.md` de activos )
- Move: `docs/requerimientos/inicio-categorias.md` → `docs/HistRequerimientos/inicio-categorias.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 100/100 ( 95 previos + 5 nuevos )
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-categorias\` )

- [ ] Bloque bajo la lista de canchas: título + 2 chips con ícono y label.
- [ ] Taps en los chips sin cambios.
- [ ] Layout completo del Inicio ( los 5 bloques ) con scroll.

- [ ] **Step 3: Escribir `Specs/inicio-categorias.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/inicio-categorias.md docs/HistRequerimientos/inicio-categorias.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: estado "sin canchas" ( 06 ) o filtrado ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: categorias del inicio implementadas — spec SDD + RD a HistRequerimientos"
```
