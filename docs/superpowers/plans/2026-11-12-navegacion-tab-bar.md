# Navegación principal (Tab Bar + shell) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the app's bottom navigation — the mockup's Tab Bar pill (4 tabs: Inicio / Mis reservas / Favoritos / Perfil) plus a `MainShell` with 4 placeholder screens reached after a successful login, retiring the temporary `usuario validado` screen.

**Architecture:** Two small files under `lib/features/navegacion/`: `tab_bar.dart` (pure presentational widget: active tab + callback, no navigation logic) and `main_shell.dart` (stateful shell: `IndexedStack` with 4 placeholder `Scaffold`s + `AppTabBar` in `bottomNavigationBar`). `LoginScreen` swaps its success navigation from `UsuarioValidadoScreen` (push) to `MainShell` (pushReplacement). No new packages; custom widget instead of Material's `NavigationBar` because the mockup defines an exact pill look (radius 28, white-90 fill, specific active state).

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter` (ya instalado). Sin dependencias nuevas.

**Spec:** `docs/requerimientos/navegacion.md` (RD 2026-11-12). Tokens, textos, medidas y estados vienen de ahí (§4 espec visual, §5 RF, §7 criterios).

## Global Constraints

- UI en `es-AR`; labels exactos: `Inicio`, `Mis reservas`, `Favoritos`, `Perfil`.
- Íconos lucide del mockup → nombres reales del paquete `lucide_icons_flutter` (v4: `house` se llama `home`): Inicio=`LucideIcons.home`, Mis reservas=`LucideIcons.calendarCheck`, Favoritos=`LucideIcons.heart`, Perfil=`LucideIcons.user`. Anotar esta decisión en el reporte (RD §8 lo autoriza).
- Medidas del mockup (RD §4): Tab Bar píldora 375×56 de diseño → **343×56 reales** (dentro de la zona con padding 16 lateral / 12 inferior); radio 28; fill `#FFFFFFE6` = `Color(0xE6FFFFFF)`; sombra `BoxShadow(color: Color(0x1A0F172A), offset: Offset(0, 6), blurRadius: 20)`; padding interno 6 vertical / 10 horizontal; tabs distribuidos `spaceBetween`.
- Cada tab: columna con gap 2, padding 7 vertical / 14 horizontal, radio 20, centrada; ícono 21×21 + label Inter 10px debajo.
- Estados (RD §4): inactivo = sin fondo, ícono y label `AppColors.text2`, label peso 500; activo = fondo `AppColors.primarySoft` (token nuevo `#DCFCE7`), ícono y label `AppColors.primary`, label peso 600.
- Zona: `SafeArea(top: false)` + `Padding(left:16, right:16, bottom:12)` alrededor del `AppTabBar` en `bottomNavigationBar` del shell; fondo del shell `AppColors.bg` (sin fill en la zona).
- Shell: `MainShell` con `IndexedStack(index: activo.index)` y las 4 pantallas **precargadas** (no se reconstruyen al cambiar de tab); placeholders = `Scaffold(backgroundColor: AppColors.bg, body: SafeArea(child: SizedBox.expand()))` — **sin contenido**.
- Nombres/keys fijos (los tests de tareas posteriores dependen de ellos): enum `TabApp { inicio, misReservas, favoritos, perfil }` en `tab_bar.dart`; widgets `AppTabBar` y `MainShell`; cada tab con `key: ValueKey('tab-<nombreEnum>')`; cada placeholder con `key: ValueKey('placeholder-<nombreEnum>')`.
- Login (RF-04): éxito → `Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()))`; el resto del login (04b, limpieza de errores, ojo) y el flujo registro (04→05→04 + snackbar `Cuenta creada`) **no cambian**.
- Token nuevo único: `primarySoft = Color(0xFFDCFCE7)` en `app_colors.dart` — no agregar otros.
- Comandos Flutter: `C:\src\flutter\bin\flutter.bat` desde `src/FrontEnd/` (no está en PATH).
- Sin HTTP; nada se persiste.

## Review Focus

1. **Estado activo/inactivo exacto** — un tab activo debe mostrar pill `primarySoft` + verde `primary` + peso 600, y volver a inactivo (`text2`, 500, sin fondo) al activar otro; un solo activo a la vez. Pinned: Task 1 tests `tab_bar_estado_activo_tiene_pill_y_verde` / `tab_bar_solo_un_tab_activo`.
2. **Medidas y sombra de la píldora** — 343×56 con radio 28 y la sombra del mockup flotando sobre `$bg`. Pinned: Task 1 test `tab_bar_medidas_y_estilo_de_la_pildora`.
3. **Tap notifica el tab correcto** — tocar el label/ícono de un tab inactivo invoca el callback con ese `TabApp`; tocar el activo también notifica (no hay estado interno que lo bloquee). Pinned: Task 1 test `tab_bar_tocar_tab_notifica_cambio`.
4. **Pantallas precargadas, no reconstruidas** — las 4 placeholders existen en el árbol (offstage incluidas) desde el arranque y `IndexedStack.index` sigue al tab activo. Pinned: Task 2 test `shell_las_4_pantallas_estan_precargadas`.
5. **El flujo de registro queda intacto** — 04→05→04 con snackbar `Cuenta creada` sigue pasando tras el cambio de navegación. Pinned: Task 3 — suite completo de `login_screen_test.dart` sin regresiones.

---

### Task 1: Token `primarySoft` + widget `AppTabBar` (RD RF-01, §4)

**Files:**
- Modify: `src/FrontEnd/lib/core/theme/app_colors.dart`
- Create: `src/FrontEnd/lib/features/navegacion/tab_bar.dart`
- Test: `src/FrontEnd/test/tab_bar_test.dart`

**Interfaces:**
- Consumes: `AppColors` (agrega `primarySoft`).
- Produces (Task 2/3 dependen de esto): `enum TabApp { inicio, misReservas, favoritos, perfil }` y `class AppTabBar extends StatelessWidget` con constructor `const AppTabBar({super.key, required TabApp activo, required ValueChanged<TabApp> onTab})`.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/tab_bar_test.dart`**

Helpers del test: `_decoTab(tester, TabApp t)` devuelve el `BoxDecoration` del `Container` con `key: ValueKey('tab-${t.name}')`; `_capturado` guarda el último `TabApp` notificado. Pump base: `MaterialApp(home: Scaffold(bottomNavigationBar: AppTabBar(activo: ..., onTab: (t) => capturado = t)))` con viewport 375×844 (`tester.view.physicalSize = const Size(750, 1688)`, `devicePixelRatio = 2`) para el test de medidas.

```dart
testWidgets('tab_bar_muestra_los_4_tabs_con_icono_y_label', (tester) async {
  // pump AppTabBar(activo: TabApp.inicio)
  expect(find.text('Inicio'), findsOneWidget);
  expect(find.text('Mis reservas'), findsOneWidget);
  expect(find.text('Favoritos'), findsOneWidget);
  expect(find.text('Perfil'), findsOneWidget);
  expect(find.byIcon(LucideIcons.home), findsOneWidget);
  expect(find.byIcon(LucideIcons.calendarCheck), findsOneWidget);
  expect(find.byIcon(LucideIcons.heart), findsOneWidget);
  expect(find.byIcon(LucideIcons.user), findsOneWidget);
});

testWidgets('tab_bar_estado_activo_tiene_pill_y_verde', (tester) async {
  // activo: TabApp.inicio
  final deco = _decoTab(tester, TabApp.inicio);
  expect(deco.color, AppColors.primarySoft);
  expect(deco.borderRadius, BorderRadius.circular(20));
  // ícono y label en primary:
  expect(icono-color, AppColors.primary);   // Icon en el tab inicio
  expect(label-style-color, AppColors.primary); // peso w600
});

testWidgets('tab_bar_inactivo_gris_sin_fondo', (tester) async {
  // activo: TabApp.inicio → tab misReservas inactivo
  expect(_decoTab(tester, TabApp.misReservas).color, isNull); // sin fondo
  // ícono/label en text2 y peso w500
});

testWidgets('tab_bar_solo_un_tab_activo', (tester) async {
  // activo: TabApp.favoritos → SOLO favoritos con pill primarySoft;
  // inicio/misReservas/perfil sin fondo
});

testWidgets('tab_bar_tocar_tab_notifica_cambio', (tester) async {
  // activo: TabApp.inicio; tap find.text('Favoritos') → capturado == TabApp.favoritos;
  // tap find.text('Mis reservas') → capturado == TabApp.misReservas
});

testWidgets('tab_bar_medidas_y_estilo_de_la_pildora', (tester) async {
  // pump EN la estructura del shell: Scaffold(bottomNavigationBar:
  //   SafeArea(top: false, child: Padding(EdgeInsets.only(left:16,right:16,bottom:12), child: AppTabBar...)))
  // viewport 375×844 @2x
  expect(tester.getSize(find.byType(AppTabBar)), const Size(343, 56));
  final deco = tester.widget<Container>(
      find.descendant(of: find.byType(AppTabBar), matching: find.byType(Container)).first
  ).decoration! as BoxDecoration;
  expect(deco.color, const Color(0xE6FFFFFF));
  expect(deco.borderRadius, BorderRadius.circular(28));
  expect(deco.boxShadow!.single.color, const Color(0x1A0F172A));
  expect(deco.boxShadow!.single.offset, const Offset(0, 6));
  expect(deco.boxShadow!.single.blurRadius, 20);
});
```

(Los asserts marcados `icono-color`/`label-style-color` se escriben completos: recuperar el `Icon` y el `Text` del tab con `find.descendant(of: find.byKey(ValueKey('tab-inicio')), matching: ...)` y afirmar `color` y `fontWeight`.)

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/tab_bar_test.dart` (desde `src/FrontEnd/`)
Expected: FAIL (`AppTabBar`/`TabApp` no existen).

- [ ] **Step 3: Implementar `app_colors.dart` + `lib/features/navegacion/tab_bar.dart`**

- `AppColors`: agregar `/// Fondo del tab activo — \`#DCFCE7\`` + `static const primarySoft = Color(0xFFDCFCE7);` (único token nuevo).
- `tab_bar.dart`: enum `TabApp` (los 4 valores) + lista privada de datos por tab `(TabApp, label, IconData)` — íconos según Global Constraints (`home`, `calendarCheck`, `heart`, `user`).
- `AppTabBar`: `Container` píldora (decoración completa según Global Constraints, `padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10)`, `Row(mainAxisAlignment: spaceBetween)`); cada tab = `GestureDetector(onTap: () => onTab(tab))` → `Container(key: ValueKey('tab-${tab.name}'), decoration: BoxDecoration(color: activo? primarySoft : null, borderRadius: 20), padding: EdgeInsets.symmetric(vertical: 7, horizontal: 14), child: Column(mainAxisSize: min, children: [Icon(icon, size: 21, color: activo? primary : text2), SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 10, fontWeight: activo? FontWeight.w600 : FontWeight.w500, color: activo? primary : text2))]))`. Sin animaciones (RD RF-02).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/tab_bar_test.dart`
Expected: PASS (6 tests).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/core/theme/app_colors.dart src/FrontEnd/lib/features/navegacion/tab_bar.dart src/FrontEnd/test/tab_bar_test.dart
git commit -m "feat(navegacion): token primarySoft y widget AppTabBar del mockup (RD navegacion RF-01)"
```

### Task 2: `MainShell` con IndexedStack y 4 placeholders (RD RF-02/03)

**Files:**
- Create: `src/FrontEnd/lib/features/navegacion/main_shell.dart`
- Test: `src/FrontEnd/test/main_shell_test.dart`

**Interfaces:**
- Consumes: `TabApp`/`AppTabBar` (Task 1), `AppColors`.
- Produces (Task 3 consume): `class MainShell extends StatefulWidget`, constructor `const MainShell({super.key})`. Pantallas placeholder con `key: ValueKey('placeholder-<nombreEnum>')`.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/main_shell_test.dart`**

Pump base: `tester.pumpWidget(const MaterialApp(home: MainShell()))` con viewport 375×844 @2x.

```dart
testWidgets('shell_arranca_en_inicio_activo', (tester) async {
  // IndexedStack.index == 0; placeholder-inicio visible (find.byKey con
  // skipOffstage true findsOneWidget) y las otras 3 solo con skipOffstage: false;
  // el tab inicio tiene pill primarySoft (_decoTab como Task 1)
});

testWidgets('shell_cambiar_tab_marca_activo_y_muestra_pantalla', (tester) async {
  // tap find.text('Favoritos') → IndexedStack.index == 2, placeholder-favoritos
  // visible, tab favoritos con pill, tab inicio sin fondo
  // tap find.text('Perfil') → index == 3
});

testWidgets('shell_las_4_pantallas_estan_precargadas', (tester) async {
  // find.byKey(placeholder-*), skipOffstage: false → 4 findsOneWidget cada una
  // desde el primer pump (sin haber tocado nada): IndexedStack, no Navigator
  // (además: find.byType(MainShell) findsOneWidget y NO hay rutas apiladas)
});

testWidgets('shell_tab_bar_en_la_zona_del_mockup', (tester) async {
  // el AppTabBar está dentro de bottomNavigationBar del Scaffold:
  // find.ancestor(of: find.byType(AppTabBar), matching: find.byType(SafeArea)) findsOneWidget;
  // el Padding envolvente tiene EdgeInsets.only(left:16,right:16,bottom:12);
  // el Scaffold del shell tiene backgroundColor AppColors.bg
});
```

(Acceso al índice: `tester.state<IndexedStackState>(find.byType(IndexedStack)).index`.)

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/main_shell_test.dart`
Expected: FAIL (`MainShell` no existe).

- [ ] **Step 3: Implementar `lib/features/navegacion/main_shell.dart`**

- `_MainShellState`: `TabApp _activo = TabApp.inicio;` + `_seleccionar(TabApp t) => setState(() => _activo = t);`
- `build`: `Scaffold(backgroundColor: AppColors.bg, body: IndexedStack(index: _activo.index, children: const [4 × _Placeholder(key: ValueKey('placeholder-<nombre>'))]), bottomNavigationBar: SafeArea(top: false, child: Padding(padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12), child: AppTabBar(activo: _activo, onTab: _seleccionar))))`.
- `_Placeholder`: `StatelessWidget` privado — `Scaffold(backgroundColor: AppColors.bg, body: SafeArea(child: SizedBox.expand()))` con el `key` recibido por super.constructor. Un solo widget para las 4 (RD RF-03: idénticas y vacías).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/main_shell_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/navegacion/main_shell.dart src/FrontEnd/test/main_shell_test.dart
git commit -m "feat(navegacion): MainShell con IndexedStack y placeholders (RD navegacion RF-02/03)"
```

### Task 3: Login conectado al shell — jubilación de `usuario validado` (RD RF-04)

**Files:**
- Modify: `src/FrontEnd/lib/features/auth/login_screen.dart` (navegación de éxito + import)
- Delete: `src/FrontEnd/lib/features/auth/usuario_validado_screen.dart`
- Test: `src/FrontEnd/test/login_screen_test.dart` (actualizar los 4 asserts que mencionan `usuario validado`)

**Interfaces:**
- Consumes: `MainShell` (Task 2).
- Produces: sin interfaz nueva — el flujo 04 → shell reemplaza 04 → `UsuarioValidadoScreen`; el snackbar `Cuenta creada` del registro queda igual.

- [ ] **Step 1: Actualizar los tests del login (primero fallan)**

En `test/login_screen_test.dart`, los 4 asserts `expect(find.text('usuario validado'), findsOneWidget)` (líneas ~171, ~205, ~261, ~357) pasan a:

```dart
expect(find.byType(MainShell), findsOneWidget);
expect(find.text('usuario validado'), findsNothing);
```

con `import 'package:turnos_cancha/features/navegacion/main_shell.dart';` y reemplazando el import de `usuario_validado_screen.dart` si lo hubiera. En `login_credenciales_correctas_navega_a_exito` agregar además `expect(find.byKey(const ValueKey('placeholder-inicio')), findsOneWidget)` (entra en Inicio).

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/login_screen_test.dart`
Expected: FAIL (el login aún navega a `UsuarioValidadoScreen`).

- [ ] **Step 3: Implementar en `login_screen.dart`**

En `_submit()`, rama de éxito: `Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const MainShell()))`. Borrar el import de `usuario_validado_screen.dart`, agregar el de `main_shell.dart`, y eliminar el archivo `lib/features/auth/usuario_validado_screen.dart` (ya sin referencias). No tocar nada más (04b, ojo, registro, footer).

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test test/login_screen_test.dart test/main_shell_test.dart test/tab_bar_test.dart`
Expected: PASS — todo el suite del login (sin regresiones, incluida la integración de registro con snackbar `Cuenta creada`) + shell + tab bar.

- [ ] **Step 5: Commit**

```bash
git add -A src/FrontEnd
git commit -m "feat(navegacion): login entra al MainShell; se elimina usuario validado (RD navegacion RF-04)"
```

### Task 4: Verificación final + cierre documental (RD §7 / AGENTS.md / archivo del RD)

**Files:**
- Modify: `AGENTS.md` (párrafo de login: reemplazar la mención de `usuario validado` por la entrada al shell; nueva fila de verificación con fecha 2026-11-12)
- Modify: `docs/requerimientos/README.md` (quitar `navegacion.md` de activos)
- Move: `docs/requerimientos/navegacion.md` → `docs/HistRequerimientos/navegacion.md`
- Test: sin código nuevo (verificación)

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # todos los suites en PASS
```

- [ ] **Step 2: Verificación visual 375×844 @2x** (CDP/Chrome o Edge headless, mismo criterio que etapas login/registro; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\navegacion\`)

Checklist contra el RD §4/§7:
- [ ] Login 04 → Ingresar → shell con tab **Inicio** activo (pill `#DCFCE7`, verde) y placeholder vacío fondo `$bg`.
- [ ] Tab Mis reservas / Favoritos / Perfil: activo con pill, anteriores inactivos grises.
- [ ] La píldora flota: bordes a 16px laterales, 12px inferior, sombra visible, radio 28.
- [ ] Flujo registro 04 → 05 → 04 con snackbar `Cuenta creada` intacto.

- [ ] **Step 3: Actualizar `AGENTS.md`**

- En **Arquitectura**: `login y registro locales` sigue; agregar que el post-login es el shell con tab bar.
- En **Estado actual**: fila nueva `✅ Navegación Flutter implementada (RD 2026-11-12): Tab Bar del mockup + MainShell (IndexedStack, 4 placeholders); el login entra al shell y se eliminó la pantalla "usuario validado"` + fila de verificación con resultados de Step 1/2 (ruta real de Flutter: `C:\src\flutter`).
- En **Estado actual → Pendiente**: agregar "contenido de pantallas principales (Inicio, Detalle, Mis reservas, Favoritos, Perfil)".

- [ ] **Step 4: Archivar el RD**

```bash
git mv docs/requerimientos/navegacion.md docs/HistRequerimientos/navegacion.md
```

Editar `docs/requerimientos/README.md`: quitar la línea de `navegacion.md` (queda "Sin requerimientos activos" hasta el próximo RD).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md docs/requerimientos docs/HistRequerimientos
git commit -m "docs: navegación (tab bar) implementada y verificada — RD a HistRequerimientos"
```
