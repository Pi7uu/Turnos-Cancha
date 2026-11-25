# Requerimientos — Mis reservas · lista y pestañas ( pantalla 03, parte 1 )

**Fecha:** 2026-11-25
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"08 · Mis reservas · Sin QR"**, bloques **"Header"**, **"Pestañas"** y la card **"Reserva Elite Arena Central"** ( vectorial )
- `docs/prototipos/03 · Mis reservas.png` ( referencia estática: estado base con las 2 cards y sus acciones )

---

## 1. Objetivo

Implementar la **parte 1 de la pantalla Mis reservas** ( 03 ): el header
( volver + título ), las **pestañas** Próximas / Completadas / Canceladas
con su estado activo y la **lista de reservas** con las cards del mockup
( foto, fecha, badge de estado, horario, cancha ).

Es la pantalla que cierra el círculo del flujo de reserva: `Ver mis reservas`
hoy lleva a un tab vacío.

## 2. Contexto

- Es uno de los 4 tabs del shell ( `navegacion.md` ) — hoy placeholder. El
  `Ver mis reservas` de la pantalla de éxito ya abre este tab.
- El mockup define 3 estados de la lista: **Próximas** ( 2 cards en el PNG ),
  **Completadas** y **Canceladas** ( el frame 09 muestra el estado vacío ).
- Este RD usa **data simulada fija**; la conexión con las reservas creadas en
  el flujo ( store en memoria ) y las acciones llegan en la **parte 2**.

## 3. Alcance

### Dentro del alcance

- Pantalla **MisReservasScreen** ( §4 ): header + pestañas + lista de cards.
- **Pestañas activas**: tocar una pestaña muestra su lista ( un solo activo
  con subrayado verde; los otros grises ).
- **Modelo `Reserva`** en memoria con data simulada fija ( §4 ): 2 Próximas
  ( las del mockup ), 1 Completada y 1 Cancelada ( inventadas para ver las
  3 pestañas con contenido ).
- Cards con el estilo del mockup; sus **acciones son visuales** ( `Cancelar
  reserva`, `Ver QR`, `Confirmar` inertes — parte 2 ).

### Fuera de alcance

- **Acciones reales** ( cancelar / confirmar / ver QR ) y el **store
  compartido** con el flujo de reserva ( parte 2 ).
- Estados **vacíos** de las pestañas ( frame 09 — parte 2, junto con las
  acciones que vacían listas ).
- Variante **"Sin QR"** ( frame 08 — parte 2: define cuándo `Ver QR` no
  está ).
- Filtros por fecha de las reservas, recordatorios, reseñas.

## 4. Espec visual ( frame 08 / PNG 03 )

Pantalla 375×844 sobre `$bg`. Content ( padding 8 arriba / 16 lados /
16 abajo, hueco **18** entre bloques ):

### Header ( fila, hueco 14, centrada )

| Elemento | Especificación |
|---|---|
| Volver | 40×40, `$surface`, radio 20, borde `$border` 1px, `chevron-left` (lucide) 20×20 `$text` |
| Título | `Mis reservas` — 24px, bold (700), `$text` |

### Pestañas ( fila, los 3 reparten el ancho por igual )

Cada pestaña ( vertical, hueco 9, padding 0/10, centrada ): label 15px +
subrayado ( alto 3, radio 2, ancho completo ):

| Estado | Label | Subrayado |
|---|---|---|
| Activa | `$primary`, semibold (600) | `$primary` |
| Inactiva | `$text-2`, medium (500) | transparente |

Labels: `Próximas`, `Completadas`, `Canceladas` ( activa por defecto:
**Próximas** ).

### Card de reserva ( lista vertical, hueco 12 entre cards )

Card: `$surface`, radio 16, borde `$border` 1px, padding 16, vertical
hueco 14:

| Bloque | Especificación |
|---|---|
| Superior ( fila, hueco 12, centrada ) | Foto 48×48 radio 10 ( asset de la cancha ) + Info ( columna, hueco 3 ): nombre 15px w700 `$text` + fecha `Mar, 15 oct 2026` 13px `$text-2` + **badge de estado** ( radio 6, padding 5/9, texto 10px w700 `letterSpacing` 0.5 ) |
| Detalle ( fila `spaceBetween` ) | `HORARIO` ( 10px w600 `letterSpacing` 1 `$text-2` ) + `19:00 - 20:00` ( 17px w700 `$text` ) · `CANCHA` + `Cancha A (5v5)` ( 17px w700, alineado a la derecha ) |
| Acciones ( fila, hueco 10 ) | botones de la card ( inertes en esta parte — §5 ) |

Estados del badge:

| Estado | Fondo | Texto |
|---|---|---|
| `CONFIRMADA` | `$primary` | blanco |
| `PENDIENTE` | `#F59E0B` | blanco |
| `COMPLETADA` ( extensión ) | `$primarySoft` | `$primary` |
| `CANCELADA` ( extensión ) | `#FEE2E2` | `$danger` |

Botones de la card ( visuales ahora ): `Cancelar reserva` ( `$surface` +
borde `$border` 1px, radio 10, padding 12, texto 14px w600 `$text` ),
`Ver QR` y `Confirmar` ( `$primary`, radio 10, padding 12, texto 14px w600
blanco ) — según el PNG: `Ver QR` en CONFIRMADA, `Confirmar` en PENDIENTE.

### Datos simulados ( §8: 2 del mockup + 2 inventadas )

| Estado | Cancha | Fecha | Horario | Cancha (lado) |
|---|---|---|---|---|
| Próximas · CONFIRMADA | Elite Arena Central | `Mar, 15 oct 2026` | `19:00 - 20:00` | `Cancha A (5v5)` |
| Próximas · PENDIENTE | Skyline Sports Hub | `Sáb, 19 oct 2026` | `10:00 - 11:30` | `Cancha principal (7v7)` |
| Completadas · COMPLETADA | Cancha Municipal | `Lun, 12 oct 2026` | `18:00 - 19:00` | `Cancha B (5v5)` |
| Canceladas · CANCELADA | Elite Arena Central | `Vie, 23 oct 2026` | `20:00 - 21:00` | `Cancha A (5v5)` |

## 5. Requerimientos funcionales

### RF-01 — Pantalla con pestañas

- Muestra header, las 3 pestañas y la lista de la pestaña **Próximas**
  ( activa al entrar ).
- Tocar una pestaña la activa ( subrayado verde, label verde semibold ) y
  muestra **su** lista; las demás quedan inactivas ( un solo activo ).

### RF-02 — Cards de reserva

- Cada card muestra foto, nombre, fecha, badge de estado, `HORARIO` con el
  rango, `CANCHA` con el nombre del sector y sus botones ( §4 ).
- Los botones de la card son **visuales**: tocarlos no hace nada ( RF-03 —
  las acciones llegan en la parte 2 ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `Mis reservas`, `Próximas`, `Completadas`,
  `Canceladas`, `HORARIO`, `CANCHA`, `CONFIRMADA`, `PENDIENTE`,
  `COMPLETADA`, `CANCELADA`, `Cancelar reserva`, `Ver QR`, `Confirmar`
  (`es-AR`); fecha `Mar, 15 oct 2026`.
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$bg`, `$surface`, `$border`, `$text`, `$text-2`, `$primary`,
  `$primarySoft`, `$danger` — existentes; ámbar `#F59E0B` y rosa `#FEE2E2`
  literales ( ya usados en el flujo de reserva ).
- **Íconos:** `LucideIcons.chevronLeft`.
- **Assets:** las fotos de las cards usan los assets existentes de las
  canchas ( `cancha.foto` ) — sin assets nuevos.
- **Plataforma:** móvil, 375×844; sin overflow en 320×568 ( lista
  scrolleable ).
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. El tab Mis reservas muestra `Mis reservas` con el botón Volver, las 3
   pestañas ( `Próximas` activa con subrayado verde ) y las 2 cards de
   Próximas del mockup ( Elite CONFIRMADA `19:00 - 20:00` `Cancha A (5v5)`;
   Skyline PENDIENTE `10:00 - 11:30` `Cancha principal (7v7)` ).
2. Tocar `Completadas` la activa ( subrayado verde ) y muestra la card
   COMPLETADA ( Cancha Municipal ); `Próximas` vuelve a inactiva.
3. Tocar `Canceladas` muestra la card CANCELADA con su badge rosa.
4. Cada card muestra foto 48×48, fecha `Mar, 15 oct 2026`-style y sus
   botones según el estado ( `Ver QR` en CONFIRMADA, `Confirmar` en
   PENDIENTE, `Cancelar reserva` en Próximas ).
5. Tocar los botones de las cards no produce ningún cambio.
6. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Data | **Fija simulada** ( 2 del mockup + COMPLETADA y CANCELADA inventadas ) — el store compartido con el flujo llega en la parte 2 |
| Pestañas | Cambio visual real ( un activo con subrayado ) con las 3 listas; sin swipe entre pestañas ( solo tap ) |
| Botones de card | **Visuales/inertes** en esta parte ( acciones: parte 2 ) |
| Badges | `COMPLETADA` y `CANCELADA` son **extensiones** ( el mockup solo define CONFIRMADA/PENDIENTE ) — colores coherentes con el resto de la app |
| Fotos | Reutilizan `cancha.foto` ( assets existentes ) — el mockup usa la foto de Mis reservas de Elite ( distinta a la del card del Inicio ), pero se prioriza la consistencia de datos |
| Volver | El prototipo lo muestra como pantalla apilada; en nuestra arquitectura es un **tab** — `Volver` **cambia al tab Inicio** ( decisión propia ) |

## 9. Riesgos y notas para la siguiente iteración

- **Parte 2**: acciones reales ( `Cancelar reserva` mueve a Canceladas;
  `Confirmar` pasa PENDIENTE→CONFIRMADA; `Ver QR` abre el QR ) + **store en
  memoria** compartido ( las reservas creadas en el flujo aparecen en
  Próximas ) + estados vacíos ( frame 09 ) + variante "Sin QR" ( frame 08 ).
- Con la API REST, `Reserva` se alimenta del backend ( `ReservaCancha` del
  modelo Django ) y las acciones llaman a sus endpoints.
