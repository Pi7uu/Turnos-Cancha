# Header del Inicio Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Inicio screen's top header (brand `TurnosCancha` + bell with badge + profile icon) per the mockup, replacing the Inicio placeholder in the navigation shell.

**Architecture:** One new file `lib/features/inicio/inicio_screen.dart`: `InicioScreen` (StatelessWidget) = `Scaffold` with the mockup's content structure (padding 8/16/16/16, column gap 16) holding a private `_Header` row widget (marca + acciones). Bell and profile are wrapped in `GestureDetector(onTap: () {})` — visible, dead (same pattern as the login's dead links). `MainShell` swaps its `_Placeholder(key: ValueKey('placeholder-inicio'))` for `InicioScreen(key: ValueKey('placeholder-inicio'))` — the key stays so the existing navigation/login tests pass unchanged.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter` (ya instalado). Sin dependencias nuevas.

**Spec:** `docs/requerimientos/inicio-header.md` (RD 2026-11-12). Medidas, colores y textos vienen de su §4; decisiones de su §8.

## Global Constraints

- Texto exacto de marca: `TurnosCancha` — Inter 18px, `FontWeight.w700`, `AppColors.primary`.
- Medidas (RD §4): fila header `spaceBetween` centrada. Marca: hueco 8, logo `Container` 34×34, `AppColors.primary`, radio 10, `Icons.sports_soccer` 20px blanco centrado. Acciones: hueco 16.
- Campana: caja 26×26 (`SizedBox`) con `Stack` (`layout` absoluto del mockup): `LucideIcons.bell` 22×22 `AppColors.text` en (1, 3) (`Positioned(left: 1, top: 3)`); badge `Container` 9×9 en (17, 0), `BoxDecoration(color: AppColors.danger, shape: circle, border: Border.all(color: Colors.white, width: 2))`.
- Perfil: `LucideIcons.user` 23×23 `AppColors.text`.
- Estructura de contenido del Inicio (base de los RDs siguientes): `Scaffold(backgroundColor: AppColors.bg)` + `SafeArea` + `Padding(EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16))` + `Column(crossAxisAlignment: stretch, gap 16)` — por ahora solo el header.
- Campana y perfil: `GestureDetector(onTap: () {})` — visibles, **sin funcionalidad** (RD RF-02). El badge siempre visible (único estado del mockup).
- Tipografía: fuente por defecto de Flutter si Inter no está configurada (misma cláusula que login/registro/navegación). Sin tokens de color nuevos.
- El key `ValueKey('placeholder-inicio')` **no cambia**: los tests existentes de `main_shell_test.dart` y `login_screen_test.dart` lo referencian y deben seguir pasando sin edits.
- Comandos Flutter: `C:\src\flutter\bin\flutter.bat` desde `src/FrontEnd/` (no está en PATH). Sin HTTP.

## Review Focus

1. **Posición y estilo del badge** — el círculo 9×9 rojo con borde blanco 2px debe sobresalir arriba-derecha de la campana en (17, 0) dentro de la caja 26×26; un desfase lo coloca encima del ícono o fuera de la caja. Pinned: Task 1 test `inicio_header_medidas_y_colores` (posición relativa del badge).
2. **Colores exactos por rol** — logo y nombre en `primary`, íconos campana/perfil en `text`, badge en `danger`; confundir `text` con `text2` (gris) es el error más probable al copiar del mockup. Pinned: Task 1 test `inicio_header_medidas_y_colores`.
3. **Los taps muertos no rompen nada** — tocar campana o perfil no debe empujar rutas, mostrar snackbars ni cambiar la pantalla. Pinned: Task 1 test `inicio_campana_y_perfil_no_navegan` (NavigatorObserver + pantalla intacta).
4. **Overflow del header en pantallas chicas** — en la fuente de test (1 char = fontSize) `TurnosCancha` a 18px ocupa 198px y la fila con acciones puede no caber en 320px: sin RenderFlex overflow. Pinned: Task 1 test `inicio_sin_overflow_375x844_y_chica`.
5. **Regresión de la navegación existente** — el shell, el login→shell y los 4 tabs deben seguir pasando con InicioScreen dentro del shell (misma key). Pinned: Task 2 — suite completo sin edits en tests previos.

---

### Task 1: `inicio_screen.dart` — header del mockup (RD RF-01/RF-02)

**Files:**
- Create: `src/FrontEnd/lib/features/inicio/inicio_screen.dart`
- Test: `src/FrontEnd/test/inicio_screen_test.dart`

**Interfaces:**
- Consumes: `AppColors` (tokens existentes), `Icons.sports_soccer`, `LucideIcons.bell`, `LucideIcons.user`.
- Produces (Task 2 consume): `class InicioScreen extends StatelessWidget`, constructor `const InicioScreen({super.key})`.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/inicio_screen_test.dart`**

Helpers: pump `MaterialApp(home: InicioScreen())` (sin override de viewport salvo el test de overflow); `_box(tester, finder)` devuelve el `BoxDecoration` del `Container` encontrado.

```dart
testWidgets('inicio_muestra_header_con_marca_campana_y_perfil', (tester) async {
  // pump InicioScreen
  expect(find.text('TurnosCancha'), findsOneWidget);
  expect(find.byIcon(Icons.sports_soccer), findsOneWidget);
  expect(find.byIcon(LucideIcons.bell), findsOneWidget);
  expect(find.byIcon(LucideIcons.user), findsOneWidget);
});

testWidgets('inicio_header_medidas_y_colores', (tester) async {
  // Logo: Container 34×34 (tester.getSize) con decoration color AppColors.primary
  // y borderRadius 10; pelota Icon size 20 color Colors.white.
  // Nombre: Text 'TurnosCancha' style fontSize 18, fontWeight w700, color primary.
  // Campana: Icon(bell) size 22 color text; badge: Container 9×9 con
  //   decoration color danger, shape circle, border 2px Colors.white, y
  //   posición relativa a la caja 26×26 de la campana == Offset(17, 0)
  //   (tester.getTopLeft(badge) - tester.getTopLeft(campanaBox)).
  // Perfil: Icon(user) size 23 color text.
});

testWidgets('inicio_campana_y_perfil_no_navegan', (tester) async {
  // NavigatorObserver casero (_Observer con contador didPush): pump
  // MaterialApp(navigatorObservers: [_Observer()], home: InicioScreen()).
  // tap LucideIcons.bell, pump; tap LucideIcons.user, pumpAndSettle.
  // expect(_Observer.pushes, 0); la pantalla sigue intacta
  // (find.text('TurnosCancha') findsOneWidget, find.byType(InicioScreen) findsOneWidget).
});

testWidgets('inicio_sin_overflow_375x844_y_chica', (tester) async {
  // tester.view 375×844 @2x → pump → takeException() isNull;
  // luego 320×568 @2x → pump → takeException() isNull.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_screen_test.dart` (desde `src/FrontEnd/`)
Expected: FAIL (`inicio_screen` no existe).

- [ ] **Step 3: Implementar `lib/features/inicio/inicio_screen.dart`**

Estructura (valores exactos en Global Constraints):

- `InicioScreen`: `Scaffold(backgroundColor: AppColors.bg, body: SafeArea(child: Padding(EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: const [_Header()]))))`. Los bloques siguientes se apilan aquí con `SizedBox(height: 16)` (RDs posteriores).
- `_Header`: `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [_Marca(), _Acciones()])`.
- `_Marca`: `Row(mainAxisSize: min, crossAxisAlignment: center)` → logo (`Container` 34×34, `BoxDecoration(color: AppColors.primary, borderRadius: 10)`, `child: Center(child: Icon(Icons.sports_soccer, size: 20, color: Colors.white))`) + `SizedBox(width: 8)` + `Text('TurnosCancha', ...)` **envuelto en `Flexible`** con `maxLines: 1, overflow: TextOverflow.ellipsis` (patrón de la marca del login: en la fuente de test la palabra no cabe en 320px y la fila desbordaría; en el dispositivo real entra holgada).
- `_Acciones`: `Row(mainAxisSize: min, crossAxisAlignment: center)` → `GestureDetector(onTap: () {}, child: _Campana())` + `SizedBox(width: 16)` + `GestureDetector(onTap: () {}, child: Icon(LucideIcons.user, size: 23, color: AppColors.text))`.
- `_Campana`: `SizedBox(width: 26, height: 26, child: Stack(children: [Positioned(left: 1, top: 3, child: Icon(LucideIcons.bell, size: 22, color: AppColors.text)), Positioned(left: 17, top: 0, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))))]))`.
- `Column` sin `mainAxisAlignment` especial (el contenido arranca arriba).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_screen_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/inicio_screen.dart src/FrontEnd/test/inicio_screen_test.dart
git commit -m "feat(inicio): header con marca, campana y perfil del mockup (RD inicio-header RF-01/02)"
```

### Task 2: Wiring al shell + verificación final + cierre documental

**Files:**
- Modify: `src/FrontEnd/lib/features/navegacion/main_shell.dart` (solo el hijo de Inicio del `IndexedStack`)
- Modify: `AGENTS.md` (fila nueva de implementación + verificación con fecha 2026-11-12)
- Modify: `docs/requerimientos/README.md` (quitar `inicio-header.md` de activos)
- Move: `docs/requerimientos/inicio-header.md` → `docs/HistRequerimientos/inicio-header.md`
- Test: `src/FrontEnd/test/main_shell_test.dart` (un test nuevo; los demás **sin edits**)

**Interfaces:**
- Consumes: `InicioScreen` (Task 1), `ValueKey('placeholder-inicio')` (sin cambios).
- Produces: sin interfaz nueva — el shell muestra el header en el tab Inicio.

- [ ] **Step 1: Write the failing test en `test/main_shell_test.dart`**

```dart
testWidgets('shell_tab_inicio_muestra_el_header', (tester) async {
  // pump const MaterialApp(home: MainShell()) con viewport 375×844 @2x
  expect(find.text('TurnosCancha'), findsOneWidget,
      reason: 'el tab Inicio muestra el header, no el placeholder vacío');
  expect(find.byKey(const ValueKey('placeholder-inicio')), findsOneWidget,
      reason: 'la key se mantiene: los tests de navegación no cambian');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/main_shell_test.dart`
Expected: FAIL (`TurnosCancha` no aparece: el Inicio sigue vacío).

- [ ] **Step 3: Implementar en `main_shell.dart`**

Reemplazar `_Placeholder(key: ValueKey('placeholder-inicio'))` por `InicioScreen(key: ValueKey('placeholder-inicio'))` (import `../inicio/inicio_screen.dart`). El resto del shell intacto; `_Placeholder` sigue usándose para los otros 3 tabs.

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` (suite completo desde `src/FrontEnd/`)
Expected: PASS — todos los suites (73 tests: 68 previos + 4 Task 1 + 1 de esta task), **sin edits** en tests previos.

- [ ] **Step 5: Verificación visual 375×844 @2x** (CDP/Edge headless, mismo patrón que la etapa navegación; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-header\`)

Checklist contra el RD §4/§7:
- [ ] Login → Inicio con header completo (logo verde 34×34 con pelota, `TurnosCancha` verde 18 bold, campana con badge rojo, perfil).
- [ ] Badge arriba-derecha de la campana con borde blanco.
- [ ] Tocar campana y perfil: la pantalla no cambia.
- [ ] Los otros 3 tabs siguen vacíos (placeholders).

- [ ] **Step 6: Cierre documental**

- `AGENTS.md` → Estado actual: fila `✅ Header del Inicio implementado (RD 2026-11-12): marca + campana con badge + perfil sobre la pantalla Inicio; campana y perfil sin funcionalidad (por spec)` + fila de verificación con resultados (tests/analyze/visual).
- `git mv docs/requerimientos/inicio-header.md docs/HistRequerimientos/inicio-header.md`
- `docs/requerimientos/README.md` → "Sin requerimientos activos" (con nota de la siguiente parte pendiente del Inicio).

- [ ] **Step 7: Commit final**

```bash
git add -A AGENTS.md docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: header del inicio implementado y verificado — RD a HistRequerimientos"
```
