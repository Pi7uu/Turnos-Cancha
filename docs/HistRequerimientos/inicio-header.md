# Requerimientos — Header del Inicio ( marca, campana, perfil )

**Fecha:** 2026-11-12
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"06 · Inicio · Sin canchas"**, bloque **"Header"** ( el header del Inicio existe en vectores solo dentro de ese frame; la pantalla 01 completa es el estado con canchas )
- `docs/prototipos/01 · Inicio.png` ( referencia estática del estado completo )

---

## 1. Objetivo

Implementar el **header de la pantalla Inicio** de la app Flutter
(`src/FrontEnd/`): la fila superior con la marca `TurnosCancha`, la campana de
notificaciones con badge y el ícono de perfil. Es la **parte 2 de la pantalla
01 · Inicio** ( parte 1: navegación, ya implementada ).

Por esta etapa el header es **solo visual**: campana y perfil no navegan.

## 2. Contexto

- El shell de navegación ( RD `../HistRequerimientos/navegacion.md` ) ya está
  implementado: la pantalla Inicio es un placeholder vacío ( fondo `$bg` ) que
  este RD empieza a llenar.
- El prototipo define el header igual en todos los estados del Inicio
  ( 01 y 06 ); es un bloque reutilizable dentro de esa pantalla.
- Los tokens de color ya existen en `app_colors.dart`. Sin dependencias nuevas.
- Diferencia conocida con el PNG de referencia ( §8 ): el PNG muestra la marca
  un poco más grande y el badge ámbar; este RD adopta las medidas del mockup
  vectorial ( fuente viva del diseño ).

## 3. Alcance

### Dentro del alcance

- Fila **Header** ( marca + acciones ) en la pantalla Inicio, sobre la
  estructura de contenido del §4.
- Badge de la campana ( estado "hay notificaciones" — el único que dibuja el
  mockup ).
- Reemplazo del placeholder de Inicio por una pantalla real con este header
  ( los otros 3 tabs siguen como placeholders ).

### Fuera de alcance

- Pantalla de notificaciones ( la campana **no navega**: el prototipo no
  define esa pantalla ).
- Navegación desde el avatar ( **no navega**; el tab Perfil ya existe en la
  tab bar ).
- Buscador, selector de fecha, lista de canchas y categorías ( partes 3–7 de
  la pantalla 01, RDs propios ).
- Estados del badge "sin notificaciones" ( el mockup no lo dibuja ).

## 4. Espec visual ( bloque "Header" del mockup )

Pantalla 375×844 sobre fondo `$bg`, con la status bar del sistema arriba. El
contenido del Inicio va en columna con padding **8 arriba / 16 los lados /
16 abajo** y hueco **16** entre bloques ( así lo define el mockup; los
bloques siguientes llegan en RDs posteriores ). El Header es el primer bloque:

| Elemento | Especificación |
|---|---|
| Fila Header | ancho completo, `spaceBetween`, centrada verticalmente |
| Marca | fila con hueco 8, centrada: **Logo** 34×34, fondo `$primary`, radio 10, ícono pelota `sports_soccer` (Material) 20×20 blanco centrado + **Nombre** `TurnosCancha` — Inter 18px, bold (700), `$primary` |
| Acciones | fila con hueco 16, centrada: **Campana** + **Perfil** |
| Campana | caja 26×26: ícono `bell` (lucide) 22×22 `$text` en (1, 3); badge: círculo 9×9 en (17, 0), fondo `$danger`, borde blanco 2px |
| Perfil | ícono `user` (lucide) 23×23 `$text` |

( Posiciones "en (x, y)" = dentro de la caja 26×26 de la campana, como en el
mockup: el badge sobresale arriba a la derecha del ícono. )

## 5. Requerimientos funcionales

### RF-01 — Header en la pantalla Inicio

- La pantalla Inicio deja de ser placeholder: muestra el header del §4 en su
  bloque superior ( con el padding y hueco del §4 ).
- El resto de la pantalla queda **vacío** por ahora ( los bloques siguientes
  llegan en RDs propios ).

### RF-02 — Acciones sin funcionalidad ( por esta etapa )

- La campana y el perfil son **visibles pero no navegan** al tocarlos
  ( misma decisión que los links muertos del login; ver §8 ).
- El badge del mockup ( "hay notificaciones" ) se muestra siempre: es el único
  estado que define el prototipo.

## 6. Requerimientos no funcionales

- **Idioma:** `TurnosCancha` es marca ( no se traduce ); sin otros textos.
- **Tipografía:** Inter ( o la fuente por defecto de Flutter si Inter no está
  configurada aún — misma decisión que login/registro/navegación ).
- **Tokens:** `$primary #16A34A`, `$text #0F172A`, `$danger #EF4444` — todos
  existentes. Sin tokens nuevos.
- **Íconos:** pelota `Icons.sports_soccer` (Material, ya usado en el login);
  campana y perfil `LucideIcons.bell` y `LucideIcons.user` (ya en el proyecto).
- **Plataforma:** móvil, viewport 375×844; se adapta sin romperse.
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. Tras un login válido, la pantalla Inicio muestra el header del §4:
   logo 34×34 verde con pelota blanca, `TurnosCancha` 18px bold verde, campana
   con badge rojo de borde blanco e ícono de perfil, en una fila `spaceBetween`.
2. Los íconos y el nombre usan los colores exactos del §4.
3. La campana ( con su badge ) y el perfil **no navegan** al tocarlos: la
   pantalla no cambia.
4. Los otros 3 tabs siguen mostrando sus placeholders vacíos.
5. El layout no se rompe en 375×844 ni en pantallas chicas ( sin overflow ).

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Fuente de medidas | Mockup vectorial ( frame 06 ); el PNG de referencia muestra la marca algo más grande ( ~44×44 / texto ~22px ) y el badge ámbar — se adopta el vector ( 34×34 / 18px / badge rojo `#EF4444` ) |
| Campana y perfil | Visibles pero **sin funcionalidad** ( el prototipo no define pantallas destino ) |
| Badge | Siempre visible ( único estado del mockup ) |
| Pantalla | `inicio_screen.dart` reemplaza el placeholder de Inicio en el shell; header widget propio en el mismo archivo ( privado ) hasta que el archivo crezca |
| Estructura de contenido | Columna con padding 8/16/16/16 y hueco 16 entre bloques ( base de los RDs siguientes del Inicio ) |
| Tipografía | Fuente por defecto si Inter no está configurada ( misma decisión que las etapas previas ) |

## 9. Riesgos y notas para la siguiente iteración

- Si se prefiere el look del PNG ( marca más grande / badge ámbar ), es un
  ajuste de medidas en un solo widget.
- Los RDs siguientes del Inicio ( buscador, fecha, tarjetas, categorías )
  apilan bloques bajo este header respetando el hueco 16 — la estructura de
  este RD es su base.
- Cuando exista la API REST, la campana pasará a mostrar el estado real de
  notificaciones ( con o sin badge ) y el perfil navegará al tab Perfil.
