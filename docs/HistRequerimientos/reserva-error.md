# Requerimientos — Error de reserva ( pantalla 10 )

**Fecha:** 2026-11-25
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"10 · Error de reserva"** ( completo en vectores )

---

## 1. Objetivo

Implementar la pantalla **Error de reserva**: el estado que ve el usuario
cuando `Confirmar reserva` no puede completarse porque otro usuario tomó el
horario. Completa el flujo de reserva ( éxito ya implementado — RD
`reserva-exitosa.md` ) y **define la condición de éxito/error** pendiente
desde ese RD.

## 2. Contexto

- La pantalla `¡Reserva exitosa!` ya existe y `Confirmar reserva` la abre
  siempre. Este RD agrega la **regla de conflicto** ( simulada, sin backend )
  y la pantalla de error con sus dos acciones reales.
- El error del mockup es un **"Horario ocupado"** por carrera: la cancha fue
  reservada por otro usuario entre que se eligió el horario y se confirmó.

## 3. Alcance

### Dentro del alcance

- Pantalla **ReservaErrorScreen** ( §4 ) con los datos de la reserva
  fallida.
- **Regla de conflicto** ( RF-01 ): `Confirmar reserva` abre la pantalla de
  **error** si la hora elegida está en `horasEnConflicto` de la cancha; si
  no, la de éxito ( comportamiento actual ).
- Campo nuevo `horasEnConflicto` en `Cancha` ( data simulada ).
- Botones reales: **`Elegir otro horario`** ( vuelve al Detalle, donde la
  selección sigue viva ) y **`Volver al inicio`** ( regresa al shell
  conservando su estado ).

### Fuera de alcance

- El aviso real por email ( `Te avisamos por email...` es solo texto ).
- Persistencia del intento fallido, reintentos automáticos o cola de espera.
- Cálculo real de alternativas ( el dato del mockup se deriva de la data
  simulada — RF-02 ).

## 4. Espec visual ( frame 10 del mockup )

Pantalla 375×844 sobre `$bg`, content centrado **verticalmente**
( `justifyContent: center` ), padding 32/24, hueco 20 entre bloques:

| Elemento | Especificación |
|---|---|
| Círculo | 96×96, fondo `#FEE2E2`, radio 48, centrado: `x` (lucide) **46×46** `$danger` |
| Título | `No se pudo completar la reserva` — 24px, bold (700), `$text`, centrado ( hueco 18 del círculo ) |
| Subtítulo | `La cancha <nombre> del <día> de octubre a las <hora> ya fue reservada por otro usuario.` — 15px, normal, `$text-2`, interlineado **1.5**, centrado |
| Card detalle | `$surface`, radio 16, borde `$border` 1px, padding 20, vertical hueco 14 |
| — Fila MOTIVO | `MOTIVO` ( 11px w600 `letterSpacing` 1 `$text-2` ) + `Horario ocupado` ( 14px w700 `$text` ) |
| — Separador | 1px `$border` |
| — Fila ESTADO DE PAGO | label + badge `SIN COBRO` ( `$primarySoft`, radio 6, padding 5/9, texto 10px w700 `letterSpacing` 0.5 `$primary` ) |
| — Separador | 1px `$border` |
| — Fila ALTERNATIVAS | label + `<N> canchas libres` ( 14px w700 `$primary` ) |
| Nota | `Te avisamos por email en cuanto se libere un horario.` — 13px, `$text-2`, centrado |
| Botón primario | `Elegir otro horario` — ancho completo, `$primary`, radio 12, padding 15, texto 16px w600 blanco |
| Botón secundario | `Volver al inicio` — ancho completo, `$surface`, borde `$border` 1px, radio 12, padding 15, texto 16px w600 `$text` |

## 5. Requerimientos funcionales

### RF-01 — Regla de conflicto ( cierra lo pendiente de `reserva-exitosa.md` )

- `Confirmar reserva` abre la pantalla de **error** si
  `cancha.horasEnConflicto.contains(hora)`; en caso contrario abre la de
  **éxito** ( comportamiento actual, sin cambios ).

### RF-02 — Pantalla con datos del intento

- Subtítulo con el **nombre de la cancha**, el **día** y la **hora**
  intentados ( misma derivación que la de éxito: día = dígitos del label
  `fecha` ).
- `MOTIVO` `Horario ocupado` ( fijo: es el único motivo del mockup ).
- `ESTADO DE PAGO` `SIN COBRO` ( fijo: la reserva no se cobró ).
- `ALTERNATIVAS` **`<N> canchas libres`** con N = cantidad de **otras**
  canchas simuladas con esa hora **libre** ( no ocupada ni en conflicto ) —
  dato derivado, no fijo.

### RF-03 — Acciones

- **`Elegir otro horario`**: hace `pop` y regresa al **Detalle** ( la
  selección de horario sigue viva para elegir otro ).
- **`Volver al inicio`**: regresa al shell conservando su estado
  ( `popUntil` a la primera ruta — igual que en la pantalla de éxito ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `No se pudo completar la reserva`,
  `MOTIVO`, `Horario ocupado`, `ESTADO DE PAGO`, `SIN COBRO`,
  `ALTERNATIVAS`, `Te avisamos por email en cuanto se libere un horario.`,
  `Elegir otro horario`, `Volver al inicio` (`es-AR`); subtítulo
  `La cancha ... del ... de octubre a las ... ya fue reservada por otro
  usuario.`
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$bg`, `$surface`, `$border`, `$text`, `$text-2`, `$danger`,
  `$primary`, `$primarySoft` — existentes; `#FEE2E2` ( círculo ) literal.
  Sin tokens nuevos.
- **Ícono:** `LucideIcons.x` ( lucide, instalado ).
- **Plataforma:** móvil, 375×844; sin overflow en 320×568 ( columna
  scrolleable ).
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. En el Detalle de Elite, elegir **18:00** y tocar `Confirmar reserva` abre
   `No se pudo completar la reserva` con subtítulo
   `La cancha Elite Arena Central del <día> de octubre a las 18:00 ya fue
   reservada por otro usuario.`
2. La card muestra `MOTIVO` `Horario ocupado`, `ESTADO DE PAGO` `SIN COBRO`
   ( badge verde ) y `ALTERNATIVAS` `2 canchas libres` ( Skyline y Municipal
   tienen 18:00 libre ).
3. Elegir otra hora ( ej: 20:00 ) y confirmar abre la pantalla de **éxito**
   ( la regla solo afecta a las horas en conflicto ).
4. `Elegir otro horario` regresa al **Detalle** conservando la selección
   anterior ( para elegir otra ).
5. `Volver al inicio` regresa al shell con el estado del Inicio conservado
   ( buscador y día ).
6. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Condición de error | **`horasEnConflicto` en `Cancha`** ( data simulada de "carrera" ): Elite `['18:00']`, Skyline `[]`, Municipal `[]` — **una sola regla** para ver el error fácil ( Elite 18:00 ) sin romper el flujo feliz ( default 19:00 ) |
| `Confirmar reserva` | Condicional ( RF-01 ): error si la hora está en conflicto; éxito si no. Cierra el pendiente del RD `reserva-exitosa.md` |
| ALTERNATIVAS | `<N> canchas libres` **derivado**: otras canchas simuladas con esa hora libre ( no ocupada ni en conflicto ) |
| `Elegir otro horario` | `pop` al Detalle ( la selección sigue viva — no se resetea ) |
| `Volver al inicio` | `popUntil` a la primera ruta ( conserva el estado del shell, igual que en éxito ) |
| MOTIVO / SIN COBRO | Fijos ( el mockup define un solo motivo y un solo estado de cobro ) |

## 9. Riesgos y notas para la siguiente iteración

- Con la API REST, el conflicto vendrá del backend ( 409/conflict ) y
  `ALTERNATIVAS` de una consulta real de disponibilidad.
- El aviso "Te avisamos por email" queda como texto hasta que existan
  notificaciones.
- Cuando exista **Mis reservas**, los intentos fallidos podrían registrarse
  ahí ( hoy no se guardan ).
