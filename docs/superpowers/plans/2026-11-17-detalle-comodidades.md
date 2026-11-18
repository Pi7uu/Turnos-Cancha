# Detalle de cancha · comodidades y descripción Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the "Comodidades" block (5 chips with available/unavailable states + amber warning) and "Sobre esta cancha" paragraph to the Detalle screen.

**Architecture:** Task 1 extends `Cancha` with `comodidadesNoDisponibles` (List<String> of exact labels) and `descripcion`. Task 2 adds `_Comodidades` and `_Sobre` widgets to `detalle_screen.dart`'s content column; the 5 items are a fixed const list `(label, icon)` and each renders available/unavailable per the cancha; the warning row is generated from the unavailable labels (full names joined with ` y ` + ` no disponibles hoy`) and only renders when non-empty. All display-only (no taps).

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/detalle-comodidades.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `Comodidades`, `Sobre esta cancha` (17px `FontWeight.w700` `AppColors.text`); labels `Duchas`/`Estac.`/`Aire a/c`/`Agua`/`WiFi` (11px `FontWeight.w500` `AppColors.text2`); aviso `Estacionamiento y WiFi no disponibles hoy` (12px `FontWeight.w500` `Color(0xFFF59E0B)`); párrafo (14px normal `AppColors.text2`, `height: 1.55`).
- Bloques nuevos en la columna del Detalle ( hueco 16, después de nombre/dirección ): `_Comodidades` ( hueco 12 interno ) y `_Sobre` ( hueco 8 interno ).
- Lista de comodidades: fila `spaceBetween` con `padding: EdgeInsets.symmetric(horizontal: 6)`; 5 ítems fijos en orden: `('Duchas', LucideIcons.showerHead)`, `('Estac.', LucideIcons.squareParking)`, `('Aire a/c', LucideIcons.snowflake)`, `('Agua', LucideIcons.droplet)`, `('WiFi', LucideIcons.wifi)` ( claves `ValueKey('comodidad-duchas')`, `comodidad-estac`, `comodidad-aire-ac`, `comodidad-agua`, `comodidad-wifi` ).
- Ítem: `Column(mainAxisSize: min, center)` hueco 6: círculo `Container` 48×48 radio 24 ( `BoxDecoration(shape: circle)` ) centrado con glyph 21×21 + label.
- Estados ( RD §4 ): disponible = círculo `AppColors.surface`, glyph `AppColors.text`, label `AppColors.text2`. No disponible = círculo `Color(0xFFF1F5F9)`, glyph `AppColors.text2` envuelto en `Opacity(opacity: 0.45)`, label `AppColors.text2` envuelto en `Opacity(opacity: 0.5)`.
- Aviso ( solo si `comodidadesNoDisponibles` no vacío ): `Row(gap 6, center)` — `LucideIcons.info` 14×14 `Color(0xFFF59E0B)` + texto generado: nombres completos de los faltantes ( mapa `{ 'Estac.': 'Estacionamiento' }`, resto = label ) unidos con ` y ` + ` no disponibles hoy`.
- `Sobre`: `Column(gap 8)` — título + `Text(cancha.descripcion, 14, normal, text2, height: 1.55)` con wrap natural.
- Modelo ( Task 1 ): `Cancha` + `final List<String> comodidadesNoDisponibles;` + `final String descripcion;` ( constructor `const` ). Datos ( RD §4 ): Elite `[]` + texto del mockup; Skyline `['Estac.', 'WiFi']` + texto inventado; Municipal `[]` + texto inventado.
- Sin interacción en los chips ( RD RF-03 ). Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos ( `#F1F5F9` y ámbar `#F59E0B` literales ). Sin HTTP.

## Review Focus

1. **Íconos cruzados entre comodidades** — `shower-head`→Duchas, `square-parking`→Estac., `snowflake`→Aire a/c, `droplet`→Agua, `wifi`→WiFi ( cada uno dentro de SU ítem, no solo presentes ). Pinned: Task 2 test `comodidades_muestra_titulo_y_5_items_con_iconos` ( asserts por ítem ).
2. **Estados invertidos o mal atenuados** — el no disponible usa círculo `#F1F5F9` + `Opacity` 0.45 ( glyph ) y 0.5 ( label ); el disponible NO lleva `Opacity`. Pinned: Task 2 test `comodidades_estados_disponible_y_no_disponible`.
3. **El aviso es condicional y bien escrito** — solo con faltantes; texto generado `Estacionamiento y WiFi no disponibles hoy` ( nombre completo de `Estac.` ). Pinned: Task 2 test `comodidades_aviso_solo_si_hay_no_disponibles`.
4. **Datos cruzados por cancha** — Skyline muestra la variante; Elite y Municipal la base. Pinned: Task 2 test `comodidades_estados_disponible_y_no_disponible` ( 3 canchas ) + Task 1 test de datos.
5. **Sin overflow** — la fila de 5 ítems en 320px con la fuente de test ( labels anchos: `Aire a/c` = 7×11 = 77px ). Pinned: Task 2 test `comodidades_sin_overflow_375x844_y_chica` + suite previo ( 109 sin edits ).

---

### Task 1: Modelo `Cancha` + comodidades y descripción

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/cancha.dart`
- Test: `src/FrontEnd/test/cancha_test.dart` ( +1 test )

**Interfaces:**
- Consumes: nada.
- Produces ( Task 2 ): `Cancha` + `final List<String> comodidadesNoDisponibles;` + `final String descripcion;` con los valores del Global Constraints.

- [ ] **Step 1: Write the failing test ( agregar a `test/cancha_test.dart` )**

```dart
test('canchas_simuladas_comodidades_y_descripcion', () {
  expect(canchasSimuladas[0].comodidadesNoDisponibles, isEmpty);
  expect(canchasSimuladas[0].descripcion,
      'Césped sintético de grado profesional, iluminación LED de alta intensidad para partidos nocturnos y vestuarios con aire acondicionado. Perfecto para quinta con amigos o torneos competitivos.');
  expect(canchasSimuladas[1].comodidadesNoDisponibles, ['Estac.', 'WiFi']);
  expect(canchasSimuladas[1].descripcion,
      'Cancha techada de última generación, ideal para partidos nocturnos y torneos corporativos. Vestuarios amplios y acceso controlado.');
  expect(canchasSimuladas[2].comodidadesNoDisponibles, isEmpty);
  expect(canchasSimuladas[2].descripcion,
      'Cancha al aire libre en el corazón de la ciudad, con césped renovado y fácil acceso en transporte público. Ideal para partidos con amigos.');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: FAIL ( los campos no existen ).

- [ ] **Step 3: Implementar en `lib/features/inicio/cancha.dart`**

+ `final List<String> comodidadesNoDisponibles;` + `final String descripcion;` ( constructor `const` ); `canchasSimuladas` con los valores del Global Constraints ( listas `const` ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: PASS ( 5 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/cancha.dart src/FrontEnd/test/cancha_test.dart
git commit -m "feat(detalle): Cancha con comodidadesNoDisponibles y descripcion (RD detalle-comodidades §4)"
```

### Task 2: `_Comodidades` + `_Sobre` en `detalle_screen.dart` ( RD RF-01..03 )

**Files:**
- Modify: `src/FrontEnd/lib/features/detalle/detalle_screen.dart`
- Test: `src/FrontEnd/test/detalle_comodidades_test.dart`

**Interfaces:**
- Consumes: `Cancha` ( Task 1 ), `AppColors`, `LucideIcons.showerHead/squareParking/snowflake/droplet/wifi/info`.
- Produces ( Task 3 ): widgets privados `_Comodidades`, `_Sobre` en la columna del Detalle; `DetalleScreen` sin cambios de firma.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/detalle_comodidades_test.dart`**

Pump: `MaterialApp(home: DetalleScreen(cancha: <cancha>))` con viewport 375×844 @2x. Helper `_item(tester, slug)` = subtree con `key: ValueKey('comodidad-<slug>')`.

```dart
testWidgets('comodidades_muestra_titulo_y_5_items_con_iconos', (tester) async {
  // pump Elite: 'Comodidades' findsOneWidget; los 5 labels; cada glyph
  // DENTRO de su ítem ( descendant de su clave ): showerHead en duchas,
  // squareParking en estac, snowflake en aire-ac, droplet en agua, wifi en
  // wifi.
});

testWidgets('comodidades_estados_disponible_y_no_disponible', (tester) async {
  // Elite: los 5 círculos con color surface y glyph text sin Opacity.
  // Skyline: 'Estac.' y 'WiFi' — círculo Color(0xFFF1F5F9), glyph envuelto
  // en Opacity(0.45), label en Opacity(0.5); Duchas/Aire/Agua disponibles.
  // Municipal: los 5 disponibles.
});

testWidgets('comodidades_aviso_solo_si_hay_no_disponibles', (tester) async {
  // Skyline: texto 'Estacionamiento y WiFi no disponibles hoy' + icono
  // LucideIcons.info 14 Color(0xFFF59E0B) + estilo 12 w500 ámbar.
  // Elite y Municipal: sin ese texto.
});

testWidgets('sobre_muestra_titulo_y_parrafo', (tester) async {
  // 'Sobre esta cancha' (17 w700 text); párrafo de la cancha con
  // fontSize 14, color text2, height 1.55.
});

testWidgets('comodidades_no_son_tapables', (tester) async {
  // NavigatorObserver: tap sobre 'Duchas' → pushes == baseline; pantalla
  // intacta.
});

testWidgets('comodidades_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_comodidades_test.dart`
Expected: FAIL ( los bloques no existen ).

- [ ] **Step 3: Implementar en `lib/features/detalle/detalle_screen.dart`**

- Columna del content: después de `_NombreDireccion` → `SizedBox(16), _Comodidades(cancha: cancha), SizedBox(16), _Sobre(cancha: cancha)`.
- `_Comodidades`: `Column(gap 12, stretch)` — título + `Padding(EdgeInsets.symmetric(horizontal: 6), child: Row(mainAxisAlignment: spaceBetween, children: [5 × _ItemComodidad]))` + (si hay faltantes) `SizedBox` + `_Aviso`.
- Lista fija: `static const _comodidades = [('Duchas', 'duchas', LucideIcons.showerHead), ('Estac.', 'estac', LucideIcons.squareParking), ('Aire a/c', 'aire-ac', LucideIcons.snowflake), ('Agua', 'agua', LucideIcons.droplet), ('WiFi', 'wifi', LucideIcons.wifi)];`
- `_ItemComodidad({label, slug, icono, disponible})`: `Container(key: ValueKey('comodidad-<slug>'), Column(gap 6, center)` — círculo 48×48 ( `BoxDecoration(color: disponible ? surface : Color(0xFFF1F5F9), shape: circle)` ) con `Center(Icon(21, color: text))` **envuelto en `Opacity(0.45)` si no disponible**; label 11 w500 text2 **envuelto en `Opacity(0.5)` si no disponible**. Los ítems en `Expanded`/`Flexible` si hiciera falta para 320 ( el test manda: primero sin `Expanded`, y si la fila desborda, envolver cada ítem en `Flexible` con label ellipsis — decisión del test de overflow ).
- `_Aviso`: `Row(gap 6, center)` — `Icon(LucideIcons.info, 14, Color(0xFFF59E0B))` + texto generado ( nombres completos con `{ 'Estac.': 'Estacionamiento' }`, unidos ` y ` + ` no disponibles hoy` ) 12 w500 ámbar.
- `_Sobre`: `Column(gap 8, stretch)` — título + `Text(cancha.descripcion, fontSize 14, color text2, height: 1.55)`.

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_comodidades_test.dart`
Expected: PASS ( 6 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/detalle/detalle_screen.dart src/FrontEnd/test/detalle_comodidades_test.dart
git commit -m "feat(detalle): comodidades con estados y sobre esta cancha (RD detalle-comodidades RF-01..03)"
```

### Task 3: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/detalle-comodidades.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-17 )
- Modify: `docs/requerimientos/README.md` ( quitar `detalle-comodidades.md` de activos )
- Move: `docs/requerimientos/detalle-comodidades.md` → `docs/HistRequerimientos/detalle-comodidades.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 116/116 ( 109 previos + 1 Task 1 + 6 Task 2 )
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\detalle-comodidades\` )

- [ ] Elite: 5 comodidades disponibles + `Sobre esta cancha` con el párrafo.
- [ ] Skyline: `Estac.` y `WiFi` atenuadas + aviso ámbar exacto.
- [ ] Comparar con el mockup ( frame 07 ).

- [ ] **Step 3: Escribir `Specs/detalle-comodidades.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/detalle-comodidades.md docs/HistRequerimientos/detalle-comodidades.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: parte 3 del Detalle — horarios y reserva ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: comodidades y descripcion del detalle — spec SDD + RD a HistRequerimientos"
```
