# Selector de fecha del Inicio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the mockup's date strip to the Inicio screen (`Elegí la fecha` + `Octubre ▾` + 5 day chips LUN 14…VIE 18 with MAR 15 active), with tap-to-select behavior.

**Architecture:** One widget `_Fecha` (presentational: `activo` index + `onSelect` callback, same pattern as `AppTabBar`) added as the third block of `inicio_screen.dart`'s column (gap 16 below the buscador). The 5 days are a fixed const list; selection lives in `_InicioScreenState` (`int _diaActivo`, default MAR 15). The month control is a dead `GestureDetector`. Chips are `Expanded` (equal split) inside a row with gap 8.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas.

**Spec:** `docs/requerimientos/inicio-fecha.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `Elegí la fecha` (16px `FontWeight.w700` `AppColors.text`), `Octubre` (14px `FontWeight.w600` `AppColors.primary`), días `LUN`/`MAR`/`MIÉ`/`JUE`/`VIE` (11px `FontWeight.w500`) y números `14`/`15`/`16`/`17`/`18` (17px `FontWeight.w600`).
- Bloque vertical hueco **10** (título ↔ tira); el bloque entero va con `SizedBox(height: 16)` debajo del buscador (columna existente: padding 8/16/16/16).
- Fila título: `spaceBetween` centrada. Mes: fila hueco 4 + `LucideIcons.chevronDown` 15×15 `AppColors.primary`, envuelto en `GestureDetector(onTap: () {})` (inerte — RD RF-03).
- Tira de días: fila con hueco **8** y padding derecho **1** (`EdgeInsets.only(right: 1)`); los 5 chips van en `Expanded` (reparto igual — RD §4 `fill_container`).
- Chip: `Container` vertical centrado ( `Column(mainAxisSize: min)` ), hueco 2, padding 9 vertical / 0 horizontal, radio 12. Clave `ValueKey('dia-<numero>')` por chip ( los tests la usan ).
- Estados del chip ( RD §4 ): inactivo = fondo `AppColors.surface`, día `AppColors.text2`, número `AppColors.text`; activo = fondo `AppColors.primary`, día `AppColors.primarySoft`, número `Colors.white`.
- Días fijos en orden: LUN 14, MAR 15, MIÉ 16, JUE 17, VIE 18. `_diaActivo` = índice ( por defecto **1** = MAR 15 ). Tocar el activo lo mantiene ( sin estado "sin selección" ).
- La selección vive en `_InicioScreenState` ( se conserva al cambiar de tab porque el shell precarga las pantallas ).
- Tipografía: fuente por defecto si Inter no está configurada ( cláusula de las etapas previas ). Sin tokens nuevos. Sin HTTP.

## Review Focus

1. **Colores invertidos del chip activo** — el día va en `primarySoft` y el número en blanco ( no al revés ni todo blanco ); mezclarlos es el error más probable. Pinned: Task 1 test `fecha_estados_activo_e_inactivo`.
2. **Reparto igual de los 5 chips + hueco 8** — anchos iguales entre sí ( `Expanded`, no ancho fijo ) y separación exacta 8. Pinned: Task 1 test `fecha_chips_mismo_ancho_hueco_8`.
3. **La selección se mueve y se conserva** — tocar un día desmarca el anterior ( un solo activo ) y la selección sobrevive al cambio de tab. Pinned: Task 1 tests `fecha_tocar_dia_cambia_seleccion` y `fecha_seleccion_se_conserva_al_cambiar_de_tab`.
4. **El mes es inerte** — tocar `Octubre ▾` no navega ni cambia nada. Pinned: Task 1 test `fecha_mes_no_hace_nada` ( NavigatorObserver ).
5. **Sin overflow en 320px** — 5 chips con la fuente de test ( ancha ) no desbordan la fila. Pinned: Task 1 test `fecha_sin_overflow_375x844_y_chica` + suite previo intacto ( Task 2 ).

---

### Task 1: `_Fecha` en `inicio_screen.dart` ( RD RF-01/RF-02/RF-03 )

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart`
- Test: `src/FrontEnd/test/inicio_fecha_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `LucideIcons.chevronDown`, la columna existente de `InicioScreen`.
- Produces ( Task 2 ): `InicioScreen` sin cambios de firma; widgets `_Fecha` ( privado ).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/inicio_fecha_test.dart`**

Pump base: `tester.pumpWidget(const MaterialApp(home: InicioScreen()))`. Helper `_decoChip(tester, numero)` = `BoxDecoration` del `Container` con `key: ValueKey('dia-<numero>')`; `_estiloDia`/`_estiloNumero` = estilos de los `Text` descendientes ( por `find.descendant` + orden: el primer `Text` es el día, el segundo el número ).

```dart
testWidgets('fecha_muestra_titulo_mes_y_5_dias', (tester) async {
  expect(find.text('Elegí la fecha'), findsOneWidget);
  expect(find.text('Octubre'), findsOneWidget);
  expect(find.byIcon(LucideIcons.chevronDown), findsOneWidget);
  for (final [dia, numero] in [['LUN','14'],['MAR','15'],['MIÉ','16'],['JUE','17'],['VIE','18']]) {
    expect(find.text(dia), findsOneWidget);
    expect(find.text(numero), findsOneWidget);
  }
});

testWidgets('fecha_estados_activo_e_inactivo', (tester) async {
  // Activo ( MAR 15 ): _decoChip(15).color == AppColors.primary; día
  // (primer Text) color primarySoft w500 fontSize 11; número (segundo Text)
  // Colors.white w600 fontSize 17.
  // Inactivo ( LUN 14 ): _decoChip(14).color == AppColors.surface; día
  // text2; número text. ( el bloque usa los mismos tamaños )
});

testWidgets('fecha_chips_mismo_ancho_hueco_8', (tester) async {
  // Los 5 chips: getSize de cada ValueKey('dia-N') → todos el mismo ancho
  // ( igualdad exacta ); gap entre rect contiguos == 8.
});

testWidgets('fecha_tocar_dia_cambia_seleccion', (tester) async {
  // tap find.text('MIÉ') → _decoChip(16).color == primary y
  // _decoChip(15).color == surface; los demás inactivos ( un solo activo ).
});

testWidgets('fecha_seleccion_se_conserva_al_cambiar_de_tab', (tester) async {
  // pump MaterialApp(home: MainShell()) con viewport 375×844 @2x;
  // tap 'MIÉ' → tap tab 'Favoritos' → tap tab 'Inicio' →
  // _decoChip(16).color == primary ( la selección persistió ).
});

testWidgets('fecha_mes_no_hace_nada', (tester) async {
  // NavigatorObserver + tap 'Octubre': pushes == baseline; la pantalla
  // sigue igual ( find.text('Elegí la fecha') findsOneWidget ).
});

testWidgets('fecha_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_fecha_test.dart` ( desde `src/FrontEnd/` )
Expected: FAIL ( no hay bloque Fecha en la pantalla ).

- [ ] **Step 3: Implementar en `lib/features/inicio/inicio_screen.dart`**

- Estado: `int _diaActivo = 1;` en `_InicioScreenState` ( índice de MAR 15 ). Lista const de datos: `static const _dias = [('LUN', 14), ('MAR', 15), ('MIÉ', 16), ('JUE', 17), ('VIE', 18)];` en `_Fecha`.
- Columna: `[_Header(), SizedBox(16), _Buscador(...), SizedBox(16), _Fecha(activo: _diaActivo, onSelect: (i) => setState(() => _diaActivo = i))]`.
- `_Fecha` ( presentacional, recibe `int activo` + `ValueChanged<int> onSelect` ): `Column` ( `crossAxisAlignment: stretch`, hueco 10 ):
  - `_FechaTitulo`: `Row(spaceBetween, center)` → `Text('Elegí la fecha', 16, w700, text)` + `GestureDetector(onTap: () {}, child: Row(mainAxisSize: min, children: [Text('Octubre', 14, w600, primary), SizedBox(4), Icon(chevronDown, 15, primary)]))`.
  - `_Dias`: `Row(children: [for (i, (dia, numero)) ...[if (i>0) SizedBox(8), Expanded(child: GestureDetector(onTap: () => onSelect(i), child: _ChipDia(...))]])` envuelto en `Padding(EdgeInsets.only(right: 1))`.
- `_ChipDia`: `Container(key: ValueKey('dia-<numero>'), padding: EdgeInsets.symmetric(vertical: 9), decoration: BoxDecoration(color: activo ? primary : surface, borderRadius: 12), alignment: Alignment.center, child: Column(mainAxisSize: min, children: [Text(dia, 11, w500, activo ? primarySoft : text2), SizedBox(2), Text(numero, 17, w600, activo ? Colors.white : text)]))`.

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_fecha_test.dart`
Expected: PASS ( 7 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/inicio_screen.dart src/FrontEnd/test/inicio_fecha_test.dart
git commit -m "feat(inicio): selector de fecha con dias fijos y seleccion (RD inicio-fecha RF-01..03)"
```

### Task 2: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/inicio-fecha.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva en el índice; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-17; pendiente sin "fecha" )
- Modify: `docs/requerimientos/README.md` ( quitar `inicio-fecha.md` de activos )
- Move: `docs/requerimientos/inicio-fecha.md` → `docs/HistRequerimientos/inicio-fecha.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 86/86 ( 79 previos + 7 nuevos )
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-fecha\` )

- [ ] Bloque bajo el buscador: título + `Octubre ▾` verde + 5 chips repartidos.
- [ ] MAR 15 activo ( verde, día en `primarySoft`, número blanco ).
- [ ] Tocar MIÉ 16 lo activa y MAR 15 queda inactivo.
- [ ] Cambiar de tab y volver conserva la selección.

- [ ] **Step 3: Escribir `Specs/inicio-fecha.md`** ( formato del `Specs/README.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/inicio-fecha.md docs/HistRequerimientos/inicio-fecha.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: tarjetas de canchas ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: selector de fecha implementado — spec SDD + RD a HistRequerimientos"
```
