# Spec — Navegación principal ( Tab Bar + shell )

> As-built de `docs/HistRequerimientos/navegacion.md` ( RD 2026-11-12 ).

## Propósito

La estructura principal de la app: un shell con **Tab Bar inferior de 4
tabs** ( Inicio / Mis reservas / Favoritos / Perfil ) y las pantallas de
cada tab precargadas. Es la puerta de entrada tras el login.

## Cómo funciona

- **Entrada**: login exitoso → `pushReplacement` al `MainShell` con tab
  **Inicio** activo ( la pantalla `usuario validado` fue eliminada ).
- **`MainShell`** ( stateful ): `IndexedStack` con las 4 pantallas —
  precargadas y **sin rebuild** al cambiar de tab ( conservan estado ). El
  tab activo vive en el estado del shell ( `TabApp _activo`, por defecto
  `inicio` ).
- **`AppTabBar`** ( widget presentacional, `tab_bar.dart` ): píldora
  **343×56** ( dentro de la zona con padding 16 lateral / 12 inferior ),
  fondo blanco 90% ( `#FFFFFFE6` ), radio 28, sombra
  `BoxShadow(#0F172A1A, offset (0,6), blur 20)`. Cada tab: ícono lucide
  21×21 + label 10px debajo.
  - **Inactivo**: sin fondo, `$text-2`, label peso 500.
  - **Activo**: píldora `primarySoft` ( `#DCFCE7` ), ícono y label
    `$primary`, label peso 600.
  - Tabs: Inicio `house/home`, Mis reservas `calendar-check`, Favoritos
    `heart`, Perfil `user` ( nombres lucide del paquete: `home`,
    `calendarCheck`, `heart`, `user` ).
  - Semántica: cada tab es `button` y el activo `selected` ( accesibilidad ).
- **Contenido de los tabs** ( estado actual ): Inicio = pantalla real
  ( `inicio-screen` con header — ver `inicio-header.md` ); Mis reservas,
  Favoritos y Perfil = **placeholders vacíos** ( fondo `$bg` ).
- El shell usa fondo `$bg` y el Tab Bar flota en `bottomNavigationBar`
  ( `SafeArea(top: false)` + padding del mockup ).

## Archivos

- `lib/features/navegacion/main_shell.dart` — shell + placeholders.
- `lib/features/navegacion/tab_bar.dart` — `TabApp`, `AppTabBar`.
- `lib/core/theme/app_colors.dart` — token `primarySoft`.
- `test/main_shell_test.dart`, `test/tab_bar_test.dart`.

## Decisiones

- Sin paquetes de navegación: `IndexedStack` + widget propio ( el mockup
  define un look exacto que Material `NavigationBar` no replica ).
- Sin animaciones entre tabs ( cambio directo, como el prototipo ).
- **Truco de layout**: la fila de tabs va dentro de un
  `FittedBox(fit: scaleDown)` con gaps fijos de 13px ( equivalente al
  `spaceBetween` del mockup ). En el ancho real no escala nunca; en
  pantallas angostas o con texto ampliado **achica el grupo** en vez de
  desbordar o truncar labels.
- La key `ValueKey('placeholder-<tab>')` identifica cada pantalla ( los
  tests la usan; se mantiene aunque Inicio ya sea real ).
- Token nuevo `primarySoft` ( `#DCFCE7` ) — único agregado.

## Límites ( NO hace )

- No restaura el tab activo al reiniciar ( siempre arranca en Inicio ).
- Sin transiciones animadas, deep links ni badge de notificaciones en la
  tab bar.
- Los tabs vacíos no tienen contenido todavía ( sus RDs vienen después ).

## Conexiones

- Recibe al **login** ( `login.md` ) como entrada única.
- El tab Inicio muestra **inicio-header** ( `inicio-header.md` ); los demás
  tabs se llenarán con sus pantallas ( mis reservas, favoritos, perfil ).
