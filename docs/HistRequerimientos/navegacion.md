# Requerimientos — Navegación principal ( Tab Bar )

**Fecha:** 2026-11-12
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — componente **"Component · Tab Bar"** y la zona **"Zona Tab Bar"** de las pantallas 01/03/06/08/09/11/12
- `docs/prototipos/03 · Mis reposas.png` (estado activo del tab "Mis reservas", referencia estática)

---

## 1. Objetivo

Implementar el **Tab Bar** de la app móvil Flutter (`src/FrontEnd/`): la barra
de navegación inferior con 4 tabs ( Inicio / Mis reservas / Favoritos / Perfil )
y el **shell de navegación** que la sostiene. Por esta etapa las 4 pantallas de
destino son **placeholders vacíos**; su contenido llega en RDs propios.

Es la primera parte de la pantalla 01 · Inicio del prototipo: sin navegación no
se puede implementar ninguna pantalla principal.

## 2. Contexto

- Login ( 04/04b ) y registro ( 05 ) están implementados y verificados
  ( `../HistRequerimientos/login.md`, `../HistRequerimientos/registro.md` ).
  Tras un login válido hoy se muestra la pantalla temporal `usuario validado`.
- El shell reemplaza esa pantalla temporal: el login exitoso entra a la app
  ( tab Inicio activo ) y la pantalla `usuario validado` se elimina del código.
- El prototipo define el Tab Bar como **componente reutilizable** ( se instancia
  en todas las pantallas con tab bar: 01, 03, 06, 08, 09, 11, 12 ); en Flutter
  será un widget propio con la misma reutilización.
- Las pantallas 02 ( Detalle ) y las de reserva ( éxito / error ) **no llevan
  tab bar**: son pantallas apiladas con botón volver ( RDs futuros ).
- Tokens visuales en `lib/core/theme/app_colors.dart`; el paquete de íconos
  `lucide_icons_flutter` ya está en el proyecto. Sin nuevas dependencias.

## 3. Alcance

### Dentro del alcance

- Widget **Tab Bar** con los 4 tabs, estados activo/inactivo según §4.
- **Shell de navegación** ( `MainShell` ): las 4 pantallas de destino en
  placeholders ( fondo `$bg`, sin contenido ), conmutables por tab.
- Conexión del login: login válido → entra al shell ( en reemplazo de
  `usuario validado` ) y se elimina esa pantalla temporal del código.
- Token de color nuevo `primarySoft` ( §5 ).
- Tests de widgets del tab bar y del shell, y ajuste de los tests del login.

### Fuera de alcance

- Contenido real de Inicio, Mis reservas, Favoritos y Perfil ( RDs siguientes:
  `inicio-*.md`, `mis-reservas-*.md`, `favoritos.md`, `perfil.md` ).
- Badge de notificaciones, deep links, animaciones de transición entre tabs.
- Pantallas sin tab bar ( 02 · Detalle, reserva exitosa, error de reserva ).

## 4. Espec visual ( componente "Tab Bar" del mockup )

### Tab Bar ( la píldora )

Barra de **375×56** flotando sobre el fondo de la pantalla:

| Propiedad | Valor |
|---|---|
| Fondo | `#FFFFFFE6` ( blanco al 90% ) |
| Radio | 28 ( totalmente redondeada ) |
| Sombra | outer, color `#0F172A1A`, offset (0, 6), blur 20 |
| Padding interno | 6 vertical / 10 horizontal |
| Distribución | los 4 tabs con `space_between`, centrados verticalmente |

Cada tab es una columna ( gap 2, padding 7 vertical / 14 horizontal, radio 20,
centrada ) con: **ícono lucide 21×21** + **label Inter 10px** debajo.

| Tab | Ícono (lucide) | Label |
|---|---|---|
| Inicio | `house` | `Inicio` |
| Mis reservas | `calendar-check` | `Mis reservas` |
| Favoritos | `heart` | `Favoritos` |
| Perfil | `user` | `Perfil` |

Estados:

| Estado | Fondo del tab | Ícono y label |
|---|---|---|
| Inactivo | sin fondo | `#64748B`, label peso 500 |
| Activo | `#DCFCE7` | `#16A34A`, label peso 600 |

### Zona Tab Bar ( posición en pantalla )

Ancho completo, padding **0 arriba / 16 lados / 12 abajo**, fondo transparente
( el `$bg` de la pantalla se ve detrás y debajo ): el Tab Bar queda a **343×56**
con sus bordes redondeados visibles a 16px de los bordes y 12px del borde
inferior. La status bar del sistema queda arriba, como en el login.

## 5. Requerimientos funcionales

### RF-01 — Widget Tab Bar

- Muestra los 4 tabs del §4 con los íconos, labels y estilos exactos.
- Recibe el tab activo ( por defecto **Inicio** ) y el callback de selección;
  **el widget no decide navegación por sí mismo** ( el shell la resuelve ).
- Un solo tab activo a la vez.

### RF-02 — Shell de navegación

- `MainShell` muestra la pantalla del tab activo con las 4 pantallas
  **precargadas** ( `IndexedStack` ): al cambiar de tab las pantallas no se
  reconstruyen y conservan su estado ( por ahora trivial, es la base para las
  pantallas reales ).
- Tocar un tab lo marca activo ( §4 ) y muestra su pantalla. Sin transiciones
  animadas ( cambio directo ).

### RF-03 — Pantallas placeholder

- Las 4 pantallas de destino son `Scaffold` con fondo `$bg`, `SafeArea` y **sin
  contenido**. Son el punto de anclaje de los RDs siguientes.

### RF-04 — Login conectado al shell

- Login con credenciales válidas → `pushReplacement` al shell con tab Inicio.
- La pantalla `usuario validado` se **elimina** ( archivo + test ). Los tests
  del login que afirmaban navegar a ella se actualizan para afirmar la
  navegación al shell.
- El resto del login ( 04b, limpieza de errores, ojo ) y el flujo de registro
  ( 04 ↔ 05 ↔ 04 con snackbar `Cuenta creada` ) no cambian.

## 6. Requerimientos no funcionales

- **Idioma:** labels exactos del §4, español (`es-AR`).
- **Tipografía:** Inter ( o la fuente por defecto de Flutter si Inter no está
  configurada aún — decisión del equipo de implementación, misma decisión que
  `login.md` §5 y `registro.md` §7 ). El mockup muestra Inter; la app usa la
  fuente por defecto hasta que se configure la fuente del proyecto.
- **Tokens:** se agrega **`primarySoft` = `#DCFCE7`** a `app_colors.dart`
  ( fondo del tab activo ). Los demás valores ya existen (`$bg #F5F7FA`,
  `$primary #16A34A`, `$text2 #64748B`) y se usan tal cual.
- **Íconos:** `lucide_icons_flutter` ya instalado; si el nombre `house` no
  existe en la versión del paquete, usar su equivalente (`home`) — anotarlo en
  el reporte.
- **Plataforma:** móvil, viewport 375×844; el layout se adapta sin romperse.
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. Tras un login válido (`igpi7uu@gmail.com` / `igpi7uu`) se llega al shell con
   el tab **Inicio** activo ( píldora `#DCFCE7`, ícono y label `#16A34A` ) y ya
   **no existe** la pantalla `usuario validado` ( ni en el código ni en el flujo ).
2. Los 4 tabs muestran su ícono y label exactos; los inactivos son `#64748B`
   con label peso 500.
3. Tocar cada tab lo activa ( fondo `#DCFCE7`, verde, peso 600 ) y muestra su
   placeholder; el tab activo anterior vuelve al estado inactivo.
4. Cambiar de tab y volver a uno anterior no reconstruye su pantalla ( las 4
   están en `IndexedStack` ).
5. El Tab Bar flota con sus medidas del §4 ( 343×56, bordes a 16px laterales y
   12px inferior, sombra ) y respeta el fondo `$bg` detrás.
6. El flujo de registro ( 04 → 05 → 04 + snackbar `Cuenta creada` ) sigue
   funcionando sin cambios.
7. Todos los textos están en español y coinciden con §4.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Estructura | `MainShell` con `IndexedStack` + widget Tab Bar propio, sin paquetes nuevos |
| Tab por defecto | Inicio |
| Estado entre tabs | Se conserva ( pantallas precargadas, sin rebuild ) |
| Transiciones | Sin animación: cambio directo ( como el prototipo ) |
| Login exitoso | `pushReplacement` al shell; **se elimina** `usuario validado` ( RF-04 ) |
| Token nuevo | `primarySoft #DCFCE7` ( fondo del tab activo ) |
| Placeholders | Pantallas vacías fondo `$bg`; el contenido llega por RD |
| Ícono `house` | Si el paquete lo llama `home`, se usa `home` y se anota |
| Diseño | Se copia el componente del mockup ( §4 ), no se rediseña |

## 9. Riesgos y notas para la siguiente iteración

- `AGENTS.md` menciona la pantalla `usuario validado` como parte del login
  implementado: actualizar ese párrafo al cerrar este RD.
- Las pantallas 06 ( Inicio sin canchas ), 08/09 ( Mis reservas ) reutilizan el
  tab bar: sus RDs solo definen el contenido, no el componente.
- Cuando exista la API REST, la entrada al shell pasará por sesión real
  ( persistencia ), pero el shell no cambia.
- El estado entre tabs es la base para que "Mis reservas" recuerde su tab de
  filtro y favoritos no se recargue al volver — los RDs de esas pantallas lo
  asumen.
