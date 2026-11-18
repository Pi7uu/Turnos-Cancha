# Detalle de cancha · hero e info Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first part of the Detalle de cancha screen (hero with floating buttons + premium/rating/price + name + address) and wire the Inicio cards/`Reservar` to open it.

**Architecture:** Task 1 extends `Cancha` with `direccion`, `puntuacion`, `premium`, `hero` (+ the mockup hero asset for Elite). Task 2 builds `lib/features/detalle/detalle_screen.dart`: `DetalleScreen({required Cancha cancha})` — a scrollable `Stack`/`Column` with a 240px hero (image + 3 keyed circular buttons) and the info blocks; it's a pushed route (no tab bar). Task 3 replaces the dead `GestureDetector`s of the Inicio cards/`Reservar` with `push(MaterialPageRoute(DetalleScreen))` and updates the `inicio_canchas_test` inert test accordingly (Ver todo stays inert). `Volver` pops; the shell's IndexedStack preserves the Inicio state.

**Tech Stack:** Flutter stable en `C:\src\flutter` (invocar `C:\src\flutter\bin\flutter.bat`), Dart, `flutter_test`, `lucide_icons_flutter`. Sin dependencias nuevas ( un asset nuevo ).

**Spec:** `docs/requerimientos/detalle-hero.md` (RD 2026-11-17). Valores exactos de su §4; decisiones de su §8.

## Global Constraints

- Textos exactos: `PREMIUM` (10px `FontWeight.w700` blanco, `letterSpacing: 0.8`), `por hora` (11px normal `AppColors.text2`), nombre de la cancha (24px `FontWeight.w700` `AppColors.text`), dirección de la cancha (14px normal `AppColors.text2`), valor del rating (14px `FontWeight.w600` `AppColors.text`), monto (22px `FontWeight.w700` `AppColors.primary`).
- Hero: `Image.asset(cancha.hero, fit: BoxFit.cover)` a todo el ancho, alto **240** + el `SafeArea.top` del dispositivo ( la foto va detrás de la status bar como en el PNG; los botones quedan 16px bajo ella ). En tests ( sin insets ) mide exactamente 240.
- Botones del hero ( claves `ValueKey('detalle-volver')`, `detalle-compartir`, `detalle-favorito` ): `Container` 40×40, `AppColors.surface`, radio 20, `BoxShadow(Color(0x1A0F172A... no: #0F172A26 = Color(0x260F172A)), offset (0, 2), blurRadius 8`, ícono lucide 19×19 `AppColors.text` centrado. Posiciones relativas al hero: Volver (16, 16), Compartir (269, 16), Favorito (319, 16) — `Stack` con `Positioned`.
- Content: padding 18 arriba / 16 lados / 24 abajo, hueco 16 entre bloques, columna scrolleable ( `SingleChildScrollView` — la pantalla crece en las partes 2/3 ).
- Fila precio/rating: `Row(spaceBetween, center)` — izquierda `Row` ( hueco 10 ): badge `Container` `$primary` radio 6 padding `EdgeInsets.symmetric(vertical: 5, horizontal: 9)` + rating `Row` ( hueco 4 ): `LucideIcons.star` 15×15 `Color(0xFFF59E0B)` + `Text(puntuacion)` — derecha `Column` ( `crossAxisAlignment: end` ): monto + `por hora`.
- Dirección: `Row` ( hueco 6 ): `LucideIcons.mapPin` 16×16 `AppColors.text2` + texto.
- Badge `PREMIUM` **solo si `cancha.premium`** ( Municipal: false — sin badge ).
- Modelo ( RD §4, Task 1 ): `Cancha` + `final String direccion; final double puntuacion; final bool premium; final String hero;`. Datos: Elite `Av. de los Deportes 123, Centro` / 4.8 / true / `assets/img/canchas/elite_arena_hero.jpg`; Skyline `Av. del Parque 789, Oeste` / 4.6 / true / su `foto`; Municipal `Calle San Martín 45, Centro` / 4.9 / false / su `foto`.
- Navegación ( RD RF-02 ): card del Inicio y su `Reservar` → `Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetalleScreen(cancha: cancha)))`; `Volver` → `Navigator.pop`; `Ver todo` **sigue inerte**. El `unfocus` de los taps se mantiene ( el push ya oculta el teclado ).
- Tipografía: fuente por defecto si Inter no está configurada. Sin tokens nuevos. Sin HTTP ( el hero nuevo es asset local, descargado del metadato del `.pen` ).
- Tests con claves fijas ( `detalle-volver` / `detalle-compartir` / `detalle-favorito` ).

## Review Focus

1. **Posiciones absolutas de los botones del hero** — (16,16)/(269,16)/(319,16) relativas al hero: desfases de 1-2px o invertir compartir/favorito son los errores probables. Pinned: Task 2 test `detalle_hero_botones_en_posicion`.
2. **Datos cruzados al navegar** — abrir el Detalle desde la card de Skyline debe mostrar los datos de Skyline ( no los de Elite ). Pinned: Task 3 test `canchas_card_abre_el_detalle_con_la_cancha`.
3. **Badge condicional** — `PREMIUM` visible solo con `premium: true`; Municipal sin badge. Pinned: Task 2 test `detalle_sin_premium_oculta_el_badge`.
4. **El estado del Inicio se conserva al volver** — buscador, día y scroll intactos tras el pop. Pinned: Task 3 test `detalle_volver_conserva_el_estado_del_inicio`.
5. **Regresión de los tests de canchas** — `canchas_controles_inertes` queda reemplazado ( card/`Reservar` navegan; `Ver todo` sigue inerte ) y el resto de los 100 tests pasa sin edits. Pinned: Task 3 — suite completo.

---

### Task 1: Modelo `Cancha` ampliado + asset hero

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/cancha.dart`
- Modify: `src/FrontEnd/test/cancha_test.dart` ( +1 test )
- Create: `src/FrontEnd/assets/img/canchas/elite_arena_hero.jpg`

**Interfaces:**
- Consumes: nada.
- Produces ( Task 2/3 ): `Cancha` con 4 campos nuevos ( `direccion`, `puntuacion`, `premium`, `hero` ) — constructor `const` con los 10 campos; `canchasSimuladas` con los valores del Global Constraints.

- [ ] **Step 1: Write the failing test ( agregar a `test/cancha_test.dart` )**

```dart
test('canchas_simuladas_campos_del_detalle', () {
  expect(canchasSimuladas[0].direccion, 'Av. de los Deportes 123, Centro');
  expect(canchasSimuladas[0].puntuacion, 4.8);
  expect(canchasSimuladas[0].premium, isTrue);
  expect(canchasSimuladas[0].hero, 'assets/img/canchas/elite_arena_hero.jpg');
  expect(canchasSimuladas[1].direccion, 'Av. del Parque 789, Oeste');
  expect(canchasSimuladas[1].puntuacion, 4.6);
  expect(canchasSimuladas[2].direccion, 'Calle San Martín 45, Centro');
  expect(canchasSimuladas[2].puntuacion, 4.9);
  expect(canchasSimuladas[2].premium, isFalse);
  expect(canchasSimuladas[2].hero, canchasSimuladas[2].foto,
      reason: 'sin hero propio usa su foto de card');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: FAIL ( los campos no existen ).

- [ ] **Step 3: Implementar + descargar el asset**

- `Cancha`: + `final String direccion; final double puntuacion; final bool premium; final String hero;` ( constructor `const` ). `canchasSimuladas` con los valores del Global Constraints ( hero de Skyline y Municipal = su `foto` ).
- Descargar el hero del mockup a `src/FrontEnd/assets/img/canchas/elite_arena_hero.jpg` ( URL de Unsplash del nodo Hero del `.pen`: `https://images.unsplash.com/photo-1540379708242-14a809bef941?...` ). `pubspec.yaml` ya declara el directorio `assets/img/canchas/` — no cambia.

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/cancha_test.dart`
Expected: PASS ( 4 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/cancha.dart src/FrontEnd/test/cancha_test.dart src/FrontEnd/assets/img/canchas/elite_arena_hero.jpg
git commit -m "feat(detalle): Cancha ampliada con direccion/puntuacion/premium/hero (RD detalle-hero §4)"
```

### Task 2: `DetalleScreen` — hero + info ( RD RF-01/RF-03 )

**Files:**
- Create: `src/FrontEnd/lib/features/detalle/detalle_screen.dart`
- Test: `src/FrontEnd/test/detalle_screen_test.dart`

**Interfaces:**
- Consumes: `Cancha` ( Task 1 ), `AppColors`, `LucideIcons.chevronLeft/share2/heart/star/mapPin`.
- Produces ( Task 3 ): `class DetalleScreen extends StatelessWidget`, `const DetalleScreen({super.key, required this.cancha})`. Los botones del hero tienen las claves del Global Constraints; `Volver` hace `Navigator.pop` ( lo demás inerte ).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/detalle_screen_test.dart`**

Pump base: `MaterialApp(home: DetalleScreen(cancha: canchasSimuladas[0]))` ( Elite ), viewport 375×844 @2x salvo indicación. Helper `_rect(tester, key)` = `getRect(find.byKey(ValueKey(key)))` y `_origenHero` = top-left del hero ( `find.byType(Image)` ).

```dart
testWidgets('detalle_muestra_hero_botones_info_nombre_direccion', (tester) async {
  expect(find.byType(Image), findsOneWidget);
  expect(find.text('PREMIUM'), findsOneWidget);
  expect(find.text('4.8'), findsOneWidget);
  expect(find.text(r'$45'), findsOneWidget);
  expect(find.text('por hora'), findsOneWidget);
  expect(find.text('Elite Arena Central'), findsOneWidget);
  expect(find.text('Av. de los Deportes 123, Centro'), findsOneWidget);
  expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);
  expect(find.byIcon(LucideIcons.share2), findsOneWidget);
  expect(find.byIcon(LucideIcons.heart), findsOneWidget);
  expect(find.byIcon(LucideIcons.star), findsOneWidget);
  expect(find.byIcon(LucideIcons.mapPin), findsOneWidget);
});

testWidgets('detalle_hero_botones_en_posicion', (tester) async {
  // Hero: getSize(find.byType(Image)) == Size(375, 240).
  // Los 3 botones: 40×40; topLeft relativo al hero: volver (16, 16),
  // compartir (269, 16), favorito (319, 16).
  // Decoración de cada botón: color surface, radio 20, sombra
  // (color Color(0x260F172A), offset (0, 2), blurRadius 8); ícono 19 text.
});

testWidgets('detalle_estilos_del_mockup', (tester) async {
  // Badge: color primary, radio 6, padding EdgeInsets.symmetric(vertical: 5,
  // horizontal: 9); texto 10 w700 blanco letterSpacing 0.8.
  // Estrella 15 ámbar Color(0xFFF59E0B); valor '4.8' 14 w600 text.
  // Monto '$45' 22 w700 primary; 'por hora' 11 text2.
  // Nombre 24 w700 text. Pin 16 text2; dirección 14 text2.
});

testWidgets('detalle_sin_premium_oculta_el_badge', (tester) async {
  // pump DetalleScreen(cancha: canchasSimuladas[2]) ( Municipal ):
  // find.text('PREMIUM') findsNothing; el resto de la info visible.
});

testWidgets('detalle_volver_conserva_el_estado_del_inicio', (tester) async {
  // pump MaterialApp(home: MainShell()) 375×844: escribir 'futbol' en el
  // buscador, tap 'MIÉ', tap card 'Elite Arena Central' → Detalle visible;
  // tap ValueKey('detalle-volver') → vuelve al Inicio: find.text('futbol')
  // visible y el chip '16' con fondo primary ( helper local _decoChip, mismo
  // criterio que inicio_fecha_test ).
});

testWidgets('detalle_sin_overflow_375x844_y_chica', (tester) async {
  // 375×844 @2x y 320×568 @2x → takeException() isNull en ambos.
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_screen_test.dart`
Expected: FAIL ( `detalle_screen.dart` no existe ).

- [ ] **Step 3: Implementar `lib/features/detalle/detalle_screen.dart`**

- `DetalleScreen({required this.cancha})`: `Scaffold(backgroundColor: AppColors.bg, body: SingleChildScrollView(child: Column(crossAxisAlignment: stretch, children: [_Hero(cancha), Padding(18/16/24/16, child: Column(gap 16, children: [_PrecioRating(cancha), _NombreDireccion(cancha)]))])))`.
- `_Hero`: `SizedBox(height: 240 + MediaQuery.of(context).padding.top, child: Stack(children: [Positioned.fill(Image.asset(cancha.hero, fit: cover)), SafeArea(top: true, child: Stack(children: [Positioned(left: 16, top: 16, _botonHero('detalle-volver', chevronLeft, Navigator.pop)), Positioned(left: 269, top: 16, _botonHero('detalle-compartir', share2, null)), Positioned(left: 319, top: 16, _botonHero('detalle-favorito', heart, null))])))])`. En tests ( sin insets ) el hero mide 240 y los Positioned coinciden con el §4.
- `_botonHero(String clave, IconData icono, VoidCallback? onTap)`: `GestureDetector(onTap: onTap ?? () {}, child: Container(key: ValueKey(clave), width: 40, height: 40, decoration: BoxDecoration(color: AppColors.surface, shape: circle, boxShadow: [BoxShadow(color: Color(0x260F172A), offset: Offset(0, 2), blurRadius: 8)]), child: Center(Icon(icono, 19, AppColors.text))))`.
- `_PrecioRating`: `Row(spaceBetween, center)`: `Row(gap 10)` [si `premium`: badge `Container` + `Text('PREMIUM', letterSpacing: 0.8, ...)`] + `Row(gap 4)` [star 15 ámbar + `Text('${cancha.puntuacion}')`]; derecha `Column(crossAxisAlignment: end)` [monto 22 + `Text('por hora')` 11].
- `_NombreDireccion`: nombre `Text(cancha.nombre, 24 w700)` + `SizedBox(16)` + `Row(gap 6)` [pin 16 + `Text(cancha.direccion, 14 text2)`].
- El `Volver` es el único con acción ( `Navigator.of(context).pop()` ); compartir/favorito `GestureDetector` vacío ( RF-03 ).

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/detalle_screen_test.dart`
Expected: PASS ( 6 tests ).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/detalle/detalle_screen.dart src/FrontEnd/test/detalle_screen_test.dart
git commit -m "feat(detalle): pantalla con hero e info del mockup (RD detalle-hero RF-01/03)"
```

### Task 3: Navegación desde el Inicio ( RD RF-02 )

**Files:**
- Modify: `src/FrontEnd/lib/features/inicio/inicio_screen.dart` ( `_CardCancha` )
- Modify: `src/FrontEnd/test/inicio_canchas_test.dart` ( reemplazar `canchas_controles_inertes` )

**Interfaces:**
- Consumes: `DetalleScreen` ( Task 2 ), `Cancha`.
- Produces: sin interfaz nueva — card y `Reservar` empujan `DetalleScreen(cancha: cancha)`; `Ver todo` sigue inerte.

- [ ] **Step 1: Reescribir los tests ( primero fallan )**

En `test/inicio_canchas_test.dart`, reemplazar `canchas_controles_inertes` por:

```dart
testWidgets('canchas_card_abre_el_detalle_con_la_cancha', (tester) async {
  // pump MaterialApp(home: InicioScreen()); tap find.text('Elite Arena Central')
  // + pumpAndSettle → find.text('Av. de los Deportes 123, Centro') findsOneWidget
  // ( el Detalle muestra la cancha de la card tocada ).
});

testWidgets('canchas_reservar_abre_el_detalle', (tester) async {
  // tap el 'Reservar' del card Skyline ( descendant del card
  // 'cancha-Skyline Sports Hub' ) + pumpAndSettle →
  // find.text('Skyline Sports Hub') findsOneWidget ( nombre en el Detalle ).
});

testWidgets('canchas_ver_todo_sigue_inerte', (tester) async {
  // NavigatorObserver: tap 'Ver todo' → pushes == baseline.
});
```

( Import de `main_shell.dart`/`detalle_screen.dart` si hiciera falta. )

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/inicio_canchas_test.dart`
Expected: FAIL ( los taps no navegan todavía ).

- [ ] **Step 3: Implementar en `inicio_screen.dart`**

- `_CardCancha`: el `GestureDetector` exterior pasa a
  `onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetalleScreen(cancha: cancha)))` ( el `unfocus` ya no hace falta: el push oculta el teclado ). Import de `../detalle/detalle_screen.dart`.
- El botón `Reservar` ( `GestureDetector` interior ) recibe **el mismo handler** de push ( sin delegar en el exterior: el tap del botón debe abrir el Detalle igual ).
- `Ver todo` y los chips de categorías **no cambian** ( inertes ).

- [ ] **Step 4: Run tests to verify they pass**

Run: `C:\src\flutter\bin\flutter.bat test` ( suite completo )
Expected: PASS — 109/109 ( 100 previos + 4 Task 1 + 6 Task 2 + 3 netos de esta task ), sin edits en otros tests.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/inicio/inicio_screen.dart src/FrontEnd/test/inicio_canchas_test.dart
git commit -m "feat(inicio): cards y Reservar abren el Detalle de cancha (RD detalle-hero RF-02)"
```

### Task 4: Verificación final + spec SDD + cierre documental

**Files:**
- Create: `Specs/detalle-hero.md` ( spec as-built — **antes** de mover el RD )
- Modify: `Specs/README.md` ( fila nueva; mapa de pendientes )
- Modify: `AGENTS.md` ( filas de implementación + verificación 2026-11-17 )
- Modify: `docs/requerimientos/README.md` ( quitar `detalle-hero.md` de activos )
- Move: `docs/requerimientos/detalle-hero.md` → `docs/HistRequerimientos/detalle-hero.md`

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
C:\src\flutter\bin\flutter.bat analyze   # sin issues
C:\src\flutter\bin\flutter.bat test      # 109/109
```

- [ ] **Step 2: Verificación visual 375×844 @2x** ( CDP/Edge headless; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\detalle-hero\` )

- [ ] Inicio → tap card → Detalle con hero, badge, rating, precio, nombre y dirección de esa cancha.
- [ ] Botones del hero en posición ( volver izquierda; compartir/favorito derecha ).
- [ ] Municipal sin badge `PREMIUM`.
- [ ] Volver → Inicio conservando buscador y día seleccionado.

- [ ] **Step 3: Escribir `Specs/detalle-hero.md`** ( formato del `Specs/README.md`; incluir el cambio de alcance del RD `inicio-canchas.md` ) y actualizar el índice.

- [ ] **Step 4: Cierre documental** — `AGENTS.md` ( filas + pendiente ), `git mv docs/requerimientos/detalle-hero.md docs/HistRequerimientos/detalle-hero.md`, `docs/requerimientos/README.md` → "Sin requerimientos activos" ( siguiente: parte 2 del Detalle ).

- [ ] **Step 5: Commit final**

```bash
git add -A AGENTS.md Specs docs/requerimientos docs/HistRequerimientos src/FrontEnd
git commit -m "docs: detalle hero+info implementado — spec SDD + RD a HistRequerimientos"
```
