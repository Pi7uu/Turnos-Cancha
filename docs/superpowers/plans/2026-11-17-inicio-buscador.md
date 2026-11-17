# Buscador del Inicio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the mockup's search field (`Buscá canchas cerca tuyo...`) as the second block of the Inicio screen — editable input, no filtering yet.

**Architecture:** One widget `_Buscador` added to `inicio_screen.dart`'s content column (below `_Header`, gap 16). It's a real `TextField` whose decoration replicates the mockup (surface fill, border 1px, radius 12, lucide `search` 18px + hint 14px). Value state is local to the screen (a `TextEditingController` in a now-Stateful `InicioScreen`); the keyboard's "search" action does nothing. Tests in a new `test/inicio_buscador_test.dart`.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/inicio-buscador.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Placeholder exacto: `Buscá canchas cerca tuyo...` — hint 14px `FontWeight.normal` `AppColors.text2`; texto ingresado 14px `AppColors.text`.
- Campo (RD §4): ancho completo, `fillColor: AppColors.surface`, borde `AppColors.border` 1px (mismo borde en todos los estados), radio 12, `contentPadding` vertical 13 / horizontal 14, fila interna con hueco **10** entre el ícono y el texto.
- Ícono: `LucideIcons.search` 18×18 `AppColors.text2`, a la izquierda (el padding izquierdo del mockup es 14: ícono a 14px del borde, hueco 10 hasta el texto).
- Posición: segundo bloque de la columna del Inicio — `SizedBox(height: 16)` entre `_Header` y `_Buscador` (columna con padding 8/16/16/16 ya existente).
- Interacción (RD RF-01/RF-02): `TextField` editable con `keyboardType: TextInputType.text`, `textInputAction: TextInputAction.search` **sin efecto**; tap fuera descarta el teclado (`GestureDetector`/`unfocus`) sin alterar el valor; el texto escrito se conserva al perder foco. Sin autofoco al entrar (mismo criterio que las etapas previas).
- `InicioScreen` pasa a `StatefulWidget` con `TextEditingController` propio (dispose incluido); su key `ValueKey('placeholder-inicio')` y el resto del layout **no cambian**.
- Tipografía: fuente por defecto de Flutter si Inter no está configurada (cláusula de las etapas previas). Sin tokens nuevos. Sin HTTP.
- Cierre documental incluye el **spec as-built** `Specs/inicio-buscador.md` (flujo SDD acordado) antes de mover el RD a Hist.

## Review Focus

1. **Geometría exacta del campo** — ícono a 14px del borde, hueco 10 ícono→texto, padding 13/14: copiar mal el hueco o invertir padding son los errores probables. Pinned: Task 1 test `buscador_estilo_del_mockup` (posiciones relativas medidas con `getRect`).
2. **El texto se conserva** — perder foco no debe vaciar el campo ni pisar el valor; tap fuera solo descarta el teclado. Pinned: Task 1 test `buscador_acepta_texto_y_lo_conserva`.
3. **La acción "search" no hace nada** — ni navega, ni limpia, ni lanza excepciones. Pinned: Task 1 test `buscador_teclado_search_no_hace_nada` (NavigatorObserver + pantalla intacta).
4. **El resto del Inicio no cambia** — header intacto, mismo orden de bloques, sin overflow en 320px (la fila de decoración del campo con la fuente de test). Pinned: Task 1 tests `buscador_debajo_del_header_con_hueco_16` y `buscador_sin_overflow_375x844_y_chica`.
5. **Regresión del shell y el login** — 73 tests previos sin edits; la key del tab Inicio intacta. Pinned: Task 2 suite completo.

---

### Task 1: `_Buscador` en `inicio_screen.dart` (RD RF-01/RF-02)

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart`
- Test: `src/FrontEnd/test/inicio_buscador_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `LucideIcons.search`, la estructura de columna existente de `InicioScreen`.
- Produces (Task 2): `InicioScreen` sigue exportándose igual (ahora `StatefulWidget`, misma key `ValueKey('placeholder-inicio')`).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/inicio_buscador_test.dart`**

Pump: `tester.pumpWidget(const MaterialApp(home: InicioScreen()))` (viewport por defecto salvo el test de overflow).

```dart
testWidgets('buscador_muestra_campo_con_lupa_y_placeholder', (tester) async {
  expect(find.text('Buscá canchas cerca tuyo...'), findsOneWidget); // hint
  expect(find.byIcon(LucideIcons.search), findsOneWidget);
  expect(find.byType(TextField), findsOneWidget);
});

testWidgets('buscador_debajo_del_header_con_hueco_16', (tester) async {
  // getRect(Text 'TurnosCancha') → header; getRect(TextField).top -
  // headerRow.bottom == 16 (usar el find del Row del header: ancestor
  // del texto con tipo Row, el más externo del bloque de marca).
});

testWidgets('buscador_estilo_del_mockup', (tester) async {
  // TextField decoration: fillColor AppColors.surface; enabledBorder
  // OutlineInputBorder(borderRadius 12, borderSide(color border, width 1));
  // contentPadding EdgeInsets.symmetric(vertical: 13, horizontal: 14);
  // hintStyle fontSize 14, fontWeight normal, color text2.
  // Geometría: getRect(icono.search).left - getRect(TextField).left == 14;
  // getRect(Text hint).left - (getRect(icono).left + 18) == 10.
  // Ícono: size 18, color text2.
});

testWidgets('buscador_acepta_texto_y_lo_conserva', (tester) async {
  // tap campo, enterText('futbol') → find.text('futbol') visible y hint
  // desaparecido; tap fuera (offset en el fondo) + pumpAndSettle →
  // find.text('futbol') sigue y el teclado perdió foco (sin excepciones).
});

testWidgets('buscador_teclado_search_no_hace_nada', (tester) async {
  // NavigatorObserver + texto 'futbol' + testTextInput.receiveAction(search):
  // pushes == baseline, find.text('futbol') intacto, header intacto.
});

testWidgets('buscador_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_buscador_test.dart` (desde `src/FrontEnd/`)
Expected: FAIL (no hay TextField ni lupa en la pantalla).

- [ ] **Step 3: Implementar en `lib/features/inicio/inicio_screen.dart`**

- `InicioScreen` → `StatefulWidget` con `final TextEditingController _busquedaController` (dispose). `build`: columna existente con `children: const? no` — `[_Header(), const SizedBox(height: 16), _Buscador(controller: _busquedaController)]`.
- `_Buscador` (StatelessWidget, recibe el controller): `TextField(controller, keyboardType: TextInputType.text, textInputAction: TextInputAction.search, style: TextStyle(fontSize: 14, color: AppColors.text), decoration: InputDecoration(...))` con:
  - `filled: true, fillColor: AppColors.surface`;
  - `contentPadding: EdgeInsets.symmetric(vertical: 13, horizontal: 14)`;
  - `hintText: 'Buscá canchas cerca tuyo...'`, `hintStyle: TextStyle(fontSize: 14, color: AppColors.text2)`;
  - `prefixIcon: Padding(padding: EdgeInsets.only(left: 14, right: 10), child: Align(alignment: Alignment.centerLeft, widthFactor: 1, heightFactor: 1, child: Icon(LucideIcons.search, size: 18, color: AppColors.text2)))` con `prefixIconConstraints: BoxConstraints(maxWidth: 42, minHeight: 0)` (14 + 18 + 10 = 42 = padding izq + ícono + hueco; `contentPadding` horizontal pasa a aplicarse a la derecha del texto: usar `EdgeInsets.only(left: 0, right: 14, top: 13, bottom: 13)` si la geometría no cuadra — el test de posiciones manda );
  - bordes: `enabledBorder`/`focusedBorder`/`border` = `OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border, width: 1))`.
- "Tap fuera descarta el teclado": envolver el `body` del Scaffold en `GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => FocusScope.of(context).unfocus())` sin romper los taps de la tab bar ni del campo.
- La acción "search" no se maneja ( sin `onSubmitted` ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_buscador_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/inicio_screen.dart src/FrontEnd/test/inicio_buscador_test.dart
git commit -m "feat(inicio): buscador del mockup editable sin filtrado (RD inicio-buscador RF-01/02)"
```

### Task 2: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/inicio-buscador.md` ( spec as-built — **antes** de mover el RD )
- Modify: `AGENTS.md` ( filas de implementación + verificación con fecha 2026-11-17; actualizar el pendiente )
- Modify: `docs/requerimientos/README.md` ( quitar `inicio-buscador.md` de activos )
- Move: `docs/requerimientos/inicio-buscador.md` → `docs/HistRequerimientos/inicio-buscador.md`
- Modify: `Specs/README.md` ( fila nueva en el índice )

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 79/79 ( 73 previos + 6 nuevos )
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-buscador\` )

- [ ] Campo bajo el header con lupa + placeholder exacto.
- [ ] Escribir muestra el texto y oculta el hint; tap fuera lo conserva.
- [ ] Tab bar y header intactos; otros tabs sin cambios.

- [ ] **Step 3: Escribir `Specs/inicio-buscador.md`** ( formato del `Specs/README.md`: Propósito · Cómo funciona · Archivos · Decisiones · Límites · Conexiones ) y agregar su fila al índice de `Specs/README.md`.

- [ ] **Step 4: Cierre documental**

- `AGENTS.md` → filas: implementación ( RD 2026-11-17 ) + verificación ( resultados del Step 1/2 ); pendiente: quitar "buscador" de los bloques restantes del Inicio.
- `git mv docs/requerimientos/inicio-buscador.md docs/HistRequerimientos/inicio-buscador.md`
- `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente parte: selector de fecha ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: buscador implementado — spec SDD + RD a HistRequerimientos"
```
