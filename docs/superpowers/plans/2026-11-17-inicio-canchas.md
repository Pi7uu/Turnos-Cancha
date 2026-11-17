# Tarjetas de canchas del Inicio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the "Canchas disponibles" block to the Inicio screen: title row + 3 mock cancha cards (photo, name, tag, distance, rating, price, `Reservar` button) with local asset images.

**Architecture:** Task 1 builds the data layer: `Cancha` model + `canchasSimuladas` const list in `lib/features/inicio/cancha.dart` (unit-testable). Task 2 builds `_Canchas`/`_CardCancha` widgets appended to `inicio_screen.dart`'s column and wraps that column in a `SingleChildScrollView` (the screen now exceeds 568px — the existing no-overflow tests at 320×568 require scrolling). Images are 3 local JPEGs in `assets/img/canchas/` declared in `pubspec.yaml`. All controls (cards, `Reservar`, `Ver todo`) are dead `GestureDetector`s.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas ( assets propios, sin HTTP en runtime ).

**Spec:** `docs/requerimientos/inicio-canchas.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `Canchas disponibles` (17px `FontWeight.w700` `AppColors.text`), `Ver todo` (14px `FontWeight.w600` `AppColors.primary`), nombres `Elite Arena Central`/`Skyline Sports Hub`/`Cancha Municipal`, tags `5v5`/`7v7`, distancias `1.2 km de vos`/`2.8 km de vos`/`3.5 km de vos`, ratings `4.8 (124 reseñas)`/`4.6 (89 reseñas)`/`4.9 (210 reseñas)`, precios `$45`/`$60`/`$40` + `/ hora`, botón `Reservar`.
- Datos (RD §4, en orden): (1) `Elite Arena Central` 5v5 `1.2 km de vos` `4.8 (124 reseñas)` `$45`; (2) `Skyline Sports Hub` 7v7 `2.8 km de vos` `4.6 (89 reseñas)` `$60`; (3) `Cancha Municipal` 5v5 `3.5 km de vos` `4.9 (210 reseñas)` `$40`.
- Modelo: `class Cancha { final String nombre, tag, distancia, rating, precio, foto; }` + `const List<Cancha> canchasSimuladas` ( `rating` incluye el texto `4.8 (124 reseñas)`; `foto` = path del asset ).
- Bloque ( 4º de la columna, hueco 16 bajo el selector de fecha ): fila título `spaceBetween` centrada + lista vertical hueco **12** entre cards y **12** bajo la fila.
- Card: `Container` `$surface`, radio 16, borde `$border` 1px, padding **14**, columna hueco **12**. Fila superior ( hueco 12, centrada ): foto `Image.asset` 92×92 radio 12 + Info ( columna hueco 7 ):
  - Nombre 15px w700 `$text` ( `Expanded` ) + tag: `Container` `$primary`, radio 8, padding 4/8, texto 11px w600 `Colors.white`.
  - Distancia ( hueco 5 ): `LucideIcons.mapPin` 13×13 `$text-2` + texto 13px normal `$text-2`.
  - Rating ( hueco 5 ): `LucideIcons.star` 13×13 `Color(0xFFF59E0B)` + texto 13px normal `$text-2`.
  - Fila inferior `spaceBetween` centrada: precio ( hueco 4 ): monto 17px w700 `$primary` + `/ hora` 12px normal `$text-2`; botón: `Container` `$primary` radio 10 padding 11/20 + `Reservar` 14px w600 blanco.
- Cards con `key: ValueKey('cancha-<nombre>')` ( tests ). Controles inertes: `GestureDetector(onTap: ...)` en card, botón y `Ver todo` ( RD RF-02 ) — el handler vacío **además llama `FocusScope.of(context).unfocus()`** para conservar el comportamiento "tap fuera descarta el teclado" del RD del buscador.
- **Scroll**: la columna del Inicio pasa a `SingleChildScrollView` ( el contenido ya supera 568px; los tests existentes de no-overflow en 320×568 lo requieren ). La columna conserva `crossAxisAlignment: stretch` y su padding.
- Assets: `src/FrontEnd/assets/img/canchas/elite_arena.jpg`, `skyline_sports.jpg`, `cancha_municipal.jpg`, declarados en `pubspec.yaml` ( `flutter:` → `assets:` ). La de **Cancha Municipal** es la foto del mockup ( URL en los metadatos del `.pen` ); las otras 2 son fotos de canchas de Unsplash ( búsqueda libre — decorativas ). **Fallback** ( RD §8 ): si una descarga falla, usar `Container` `$primarySoft` con `Icons.sports_soccer` en vez de `Image.asset` ( dejar el test de fotos en ese caso ).
- Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos. Sin HTTP en runtime.

## Review Focus

1. **Datos exactos en orden** — tags/precios/ratings cruzados entre cards ( `5v5/$45`, `7v7/$60`, `5v5/$40` ) es el error más probable al copiar del PNG. Pinned: Task 2 test `canchas_datos_simulados_en_orden`.
2. **El scroll rompe los tests existentes** — `buscador_sin_overflow`/`fecha_sin_overflow` en 320×568 fallan si la columna no scrollea; y los taps por `find.text` deben seguir funcionando tras el cambio. Pinned: Task 2 — suite completo ( 86 previos sin edits ) + test `canchas_sin_overflow`.
3. **Estilos del card mal copiados** — radio 16 del card vs radio 12 de la foto vs radio 10 del botón vs radio 8 del tag; y la estrella ámbar `#F59E0B` ( no `$primary` ). Pinned: Task 2 test `canchas_card_estilo_del_mockup`.
4. **Controles que no deben navegar** — card, `Reservar` y `Ver todo` inertes. Pinned: Task 2 test `canchas_controles_inertes` ( NavigatorObserver ).
5. **Assets rotos o sin declarar** — las 3 fotos deben renderizar ( `find.byType(Image)` ×3 ) o, en fallback, el placeholder del RD. Pinned: Task 2 test `canchas_fotos_cargadas` + verificación visual.

---

### Task 1: Modelo `Cancha` + datos simulados

**Files:**
- Create: `src/FrontEnd/lib/features/inicio/cancha.dart`
- Test: `src/FrontEnd/test/cancha_test.dart`

**Interfaces:**
- Consumes: nada ( Dart core ).
- Produces ( Task 2 ): `class Cancha { final String nombre; final String tag; final String distancia; final String rating; final String precio; final String foto; }` con constructor `const Cancha({...})`; `const List<Cancha> canchasSimuladas` ( 3 elementos, orden del RD §4; `foto` = `assets/img/canchas/<archivo>` ).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/cancha_test.dart`**

```dart
test('canchas_simuladas_son_3_en_orden_del_mockup', () {
  expect(canchasSimuladas.map((c) => c.nombre).toList(),
      ['Elite Arena Central', 'Skyline Sports Hub', 'Cancha Municipal']);
});

test('canchas_simuladas_datos_exactos', () {
  expect(canchasSimuladas[0].tag, '5v5');
  expect(canchasSimuladas[0].distancia, '1.2 km de vos');
  expect(canchasSimuladas[0].rating, '4.8 (124 reseñas)');
  expect(canchasSimuladas[0].precio, r'$45');
  expect(canchasSimuladas[1].tag, '7v7');
  expect(canchasSimuladas[1].precio, r'$60');
  expect(canchasSimuladas[2].tag, '5v5');
  expect(canchasSimuladas[2].precio, r'$40');
});

test('canchas_simuladas_referencian_assets', () {
  for (final c in canchasSimuladas) {
    expect(c.foto, startsWith('assets/img/canchas/'));
  }
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart` ( desde `src/FrontEnd/` )
Expected: FAIL ( `cancha.dart` no existe ).

- [ ] **Step 3: Implementar `lib/features/inicio/cancha.dart`**

Clase `Cancha` ( 6 campos `final`, constructor `const` ) + `const List<Cancha> canchasSimuladas` con los 3 valores exactos del Global Constraints ( `foto`: `assets/img/canchas/elite_arena.jpg`, `skyline_sports.jpg`, `cancha_municipal.jpg` ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: PASS ( 3 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/cancha.dart src/FrontEnd/test/cancha_test.dart
git commit -m "feat(inicio): modelo Cancha con datos simulados del mockup (RD inicio-canchas RF-01)"
```

### Task 2: Assets + `_Canchas`/`_CardCancha` + scroll de la pantalla

**Files:**
- Create: `src/FrontEnd/assets/img/canchas/elite_arena.jpg`, `skyline_sports.jpg`, `cancha_municipal.jpg`
- Modify: `src/FrontEnd/pubspec.yaml` ( sección `assets:` )
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart`
- Test: `src/FrontEnd/test/inicio_canchas_test.dart`

**Interfaces:**
- Consumes: `Cancha`, `canchasSimuladas` ( Task 1 ), `AppColors`, `LucideIcons.mapPin`, `LucideIcons.star`.
- Produces ( Task 3 ): `InicioScreen` sin cambios de firma; widgets `_Canchas`, `_CardCancha` ( privados ).

- [ ] **Step 1: Descargar los assets y declararlos**

- `cancha_municipal.jpg`: URL de Unsplash de los metadatos del `.pen` ( card "Favorito Cancha Municipal": `https://images.unsplash.com/photo-1614743653196-...` — descargar con `Invoke-WebRequest`, resize razonable ≤1080px si viene enorme ).
- `elite_arena.jpg` y `skyline_sports.jpg`: 2 fotos de Unsplash de canchas de fútbol 5/7 ( búsqueda web libre; decorativas ). **Si alguna descarga falla**: anotarlo y usar el fallback del RD ( `Container` `$primarySoft` + `Icons.sports_soccer` donde iría `Image.asset` ), ajustando el test de fotos.
- `pubspec.yaml`: bajo `flutter: assets:` agregar `assets/img/canchas/` ( o los 3 paths exactos ).

- [ ] **Step 2: Write the failing test `src/FrontEnd/test/inicio_canchas_test.dart`**

Pump: `tester.pumpWidget(const MaterialApp(home: InicioScreen()))`. Helper `_decoCard(tester, nombre)` = `BoxDecoration` del `Container` con `key: ValueKey('cancha-<nombre>')`.

```dart
testWidgets('canchas_muestra_titulo_ver_todo_y_3_cards', (tester) async {
  expect(find.text('Canchas disponibles'), findsOneWidget);
  expect(find.text('Ver todo'), findsOneWidget);
  expect(find.text('Elite Arena Central'), findsOneWidget);
  expect(find.text('Skyline Sports Hub'), findsOneWidget);
  expect(find.text('Cancha Municipal'), findsOneWidget);
  expect(find.text('5v5'), findsNWidgets(2));
  expect(find.text('7v7'), findsOneWidget);
  expect(find.text('Reservar'), findsNWidgets(3));
});

testWidgets('canchas_datos_simulados_en_orden', (tester) async {
  // Los 3 cards en orden de aparición ( y > 0 creciente ):
  // Elite (5v5, '1.2 km de vos', '4.8 (124 reseñas)', '$45'),
  // Skyline (7v7, '2.8 km de vos', '4.6 (89 reseñas)', '$60'),
  // Municipal (5v5, '3.5 km de vos', '4.9 (210 reseñas)', '$40').
  // Asserts por find.text + getRect().top creciente entre nombres.
});

testWidgets('canchas_card_estilo_del_mockup', (tester) async {
  // Card (key cancha-Elite Arena Central): color surface, radio 16, borde
  // border 1px. Foto: Image 92×92 dentro de ClipRRect radio 12. Nombre
  // fontSize 15 w700 text. Tag: Container primary radio 8 padding 4/8 +
  // texto 11 w600 blanco. Pin 13 text2; estrella 13 Color(0xFFF59E0B);
  // textos de distancia/rating 13 text2. Precio: monto 17 w700 primary +
  // '/ hora' 12 text2. Botón: Container primary radio 10, padding
  // EdgeInsets.symmetric(vertical: 11, horizontal: 20), texto 14 w600 blanco.
});

testWidgets('canchas_fotos_cargadas', (tester) async {
  expect(find.byType(Image), findsNWidgets(3)); // ( o fallback del RD §8 )
});

testWidgets('canchas_controles_inertes', (tester) async {
  // NavigatorObserver: taps en 'Ver todo', en el nombre 'Elite Arena Central'
  // y en el primer 'Reservar' → pushes == baseline; la pantalla sigue igual.
});

testWidgets('canchas_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos ( el
  // contenido ahora scrollea ).
});
```

- [ ] **Step 3: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_canchas_test.dart`
Expected: FAIL ( no hay bloque de canchas ).

- [ ] **Step 4: Implementar en `lib/features/inicio/inicio_screen.dart`**

- **Scroll**: envolver la `Column` del body en `SingleChildScrollView` ( conservando el `GestureDetector` de unfocus, el `SafeArea` y el `Padding` ). Los 86 tests previos deben seguir pasando sin edits.
- Bloque `_Canchas` ( 4º hijo, `SizedBox(height: 16)` antes ): `Column( crossAxisAlignment: stretch )` con fila título ( `Row(spaceBetween, center)`: `Text('Canchas disponibles', ...)` + `GestureDetector(onTap: () {}, child: Text('Ver todo', ...))` ), `SizedBox(height: 12)`, y los 3 `_CardCancha` separados con `SizedBox(height: 12)`.
- `_CardCancha({required Cancha cancha})`: `Container(key: ValueKey('cancha-${cancha.nombre}'), padding: 14, decoration: surface/radio16/border1, ...)` envuelto en `GestureDetector` ( handler: solo `unfocus` — inertes por RF-02 ). Estructura según Global Constraints ( fila superior con `Image.asset(cancha.foto, width: 92, height: 92, fit: cover)` dentro de `ClipRRect(borderRadius: 12)` + Info; fila inferior con precio y botón `Reservar` ( mismo handler ) ).
- Datos: `for (final cancha in canchasSimuladas) ...[ _CardCancha(cancha: cancha), SizedBox(height: 12) ]` ( sin SizedBox extra al final: usar separadores condicionales como en los chips ).

- [ ] **Step 5: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` ( suite completo )
Expected: PASS — 95/95 ( 86 previos + 3 Task 1 + 6 nuevos ), sin edits en tests previos.

- [ ] **Step 6: Commit**

```bash
git add src/FrontEnd/pubspec.yaml src/FrontEnd/assets src/FrontEnd/lib/features/inicio/inicio_screen.dart src/FrontEnd/test/inicio_canchas_test.dart
git commit -m "feat(inicio): lista de canchas con cards del mockup y assets (RD inicio-canchas RF-01/02)"
```

### Task 3: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/inicio-canchas.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-17; pendiente sin "canchas" )
- Modify: `docs/requerimientos/README.md` ( quitar `inicio-canchas.md` de activos )
- Move: `docs/requerimientos/inicio-canchas.md` → `docs/HistRequerimientos/inicio-canchas.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 95/95
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-canchas\` )

- [ ] Bloque bajo el selector de fecha con título + `Ver todo` + 3 cards.
- [ ] Cada card con foto real, tag, rating, precio y `Reservar` ( comparar con el PNG del mockup ).
- [ ] Scroll de la pantalla con el contenido completo accesible.
- [ ] Taps en card/`Reservar`/`Ver todo` sin cambios.

- [ ] **Step 3: Escribir `Specs/inicio-canchas.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/inicio-canchas.md docs/HistRequerimientos/inicio-canchas.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: categorías / estado sin canchas ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: canchas del inicio implementadas — spec SDD + RD a HistRequerimientos"
```
