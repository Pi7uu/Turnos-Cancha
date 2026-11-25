# Requerimientos — Mis reservas · acciones y store ( pantalla 03, parte 2 )

**Fecha:** 2026-11-25
**Estado:** Listo para implementar ( ciclo autónomo: sin aprobación intermedia )
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"09 · Mis reservas · Vacío"** ( estado vacío en vectores ), frame **"08 · Mis reservas · Sin QR"** ( variante sin QR ) y el PNG `03 · Mis reservas.png` ( acciones de las cards )

---

## 1. Objetivo

Completar la pantalla **Mis reservas**: las **acciones reales** de las cards
( cancelar / confirmar / ver QR ), el **store en memoria** que conecta el
flujo de reserva con esta pantalla ( ¡la reserva creada aparece en
Próximas! ), los **estados vacíos** de las pestañas y la **variante "Sin
QR"**.

Con esto la pantalla 03 queda **completa**.

## 2. Contexto

- La parte 1 ya tiene header, pestañas y cards con acciones **inertes**
  ( RD `mis-reservas-lista.md` ).
- Hoy las reservas del flujo ( pantalla de éxito ) **no se guardan en
  ningún lado** — este RD agrega el store en memoria ( mismo patrón que
  `usuarios_locales` del registro ).

## 3. Alcance

### Dentro del alcance

- **Store en memoria** `reservas_locales.dart`: lista sembrada con
  `reservasSimuladas` + `registrarReserva`, `cancelarReserva`,
  `confirmarReserva`, `resetReservas` ( tests ).
- **Acciones reales** ( RF-01 ): `Cancelar reserva` → estado cancelada ( se
  mueve a la pestaña Canceladas ); `Confirmar` ( solo PENDIENTE ) → estado
  confirmada; `Ver QR` → diálogo con un QR simulado.
- **Registro desde el flujo** ( RF-02 ): al confirmar una reserva con éxito
  ( pantalla `¡Reserva exitosa!` ) se registra en el store → aparece en
  **Próximas**.
- **Estados vacíos** ( frame 09, RF-03 ): pestaña sin reservas → `No tenés
  reservas` + botón `Explorar canchas` ( cambia al tab Inicio ).
- **Variante "Sin QR"** ( frame 08, RF-04 ): campo `tieneQr` en `Reserva` —
  una confirmada sin QR muestra solo `Cancelar reserva`.

### Fuera de alcance

- QR real ( el diálogo es una simulación visual ), reseñas, reprogramación.
- Persistencia entre arranques ( el store vive en memoria ).
- Compartir el QR, recordatorios.

## 4. Espec visual

### Estado vacío ( frame 09 )

Centrado verticalmente ( padding 40/24, hueco 14 ):

| Elemento | Especificación |
|---|---|
| Ícono | círculo 88×88 `$primarySoft` radio 44, centrado: `calendar-days` (lucide) 40×40 `$primary` |
| Título | `No tenés reservas` — 19px, bold (700), `$text`, centrado |
| Descripción | `Cuando reserves una cancha va a aparecer acá. ¡Buscá la tuya y empezá a jugar!` — 14px, normal, `$text-2`, interlineado **1.5**, ancho máx 270, centrada |
| Botón | `Explorar canchas` — `$primary`, radio 12, padding 14/30, texto 15px w600 blanco |

### Diálogo "Tu QR" ( extensión — el mockup no define pantalla de QR )

Diálogo centrado ( `$surface`, radio 16, padding 24, hueco 16 ): título
`Tu QR` ( 18px w700 `$text` ), cuadro 160×160 ( borde `$border` 1px, radio 12 )
con `qr-code` (lucide) 96×96 `$text-2` centrado, texto
`Mostrá este código en la entrada.` ( 13px `$text-2`, centrado ) y botón
`Cerrar` ( `$primary`, radio 12, texto 15px w600 blanco ).

### Datos

- `Reserva` + `final bool tieneQr` ( §8 ).
- `Cancha` + `final String sector` ( `Cancha A (5v5)` / `Cancha principal
  (7v7)` / `Cancha B (5v5)` ) — lo usa el store para las reservas del
  flujo y las semillas.
- Semillas ( parte 1 ): Elite Mar 15 **`tieneQr: false`** ( muestra la
  variante 08 ); las demás `true`.
- Reservas del flujo: `registrarReserva` crea una `Reserva` **confirmada**
  con `tieneQr: true`, `fecha = <label del Inicio> 2026`,
  `horario = <hora> - <hora+1>` y `sector = cancha.sector`.

## 5. Requerimientos funcionales

### RF-01 — Acciones de las cards

- **`Cancelar reserva`**: la reserva pasa a **cancelada** ( aparece en la
  pestaña Canceladas, desaparece de Próximas ).
- **`Confirmar`** ( solo en PENDIENTE ): pasa a **confirmada** ( badge
  cambia; el botón se reemplaza por `Ver QR` si `tieneQr` ).
- **`Ver QR`** ( en CONFIRMADA con QR ): abre el diálogo `Tu QR`.

### RF-02 — Store compartido con el flujo

- Al confirmar una reserva con éxito en el Detalle, se **registra** en el
  store → aparece en la pestaña **Próximas** de Mis reservas con sus datos.
- El store es en memoria: `resetReservas()` lo devuelve al estado semilla
  ( tests ).

### RF-03 — Estados vacíos

- Pestaña sin reservas → estado vacío del frame 09.
- **`Explorar canchas`** cambia al tab Inicio ( mismo `onVolver` ).

### RF-04 — Variante "Sin QR"

- Una reserva **confirmada con `tieneQr: false`** muestra solo
  `Cancelar reserva` ( frame 08 ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `No tenés reservas`,
  `Cuando reserves una cancha va a aparecer acá. ¡Buscá la tuya y empezá a
  jugar!`, `Explorar canchas`, `Tu QR`,
  `Mostrá este código en la entrada.`, `Cerrar` (`es-AR`).
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada ).
- **Tokens:** `$surface`, `$border`, `$text`, `$text-2`, `$primary`,
  `$primarySoft` — existentes. Sin tokens nuevos.
- **Íconos:** `LucideIcons.calendarDays`, `LucideIcons.qrCode` ( instalados ).
- **Plataforma:** móvil, 375×844; sin overflow en 320×568.
- **Sin red; sin persistencia** entre arranques.

## 7. Criterios de aceptación

1. `Cancelar reserva` en la card de Elite ( Próximas ) la mueve a
   **Canceladas** ( badge `CANCELADA` ) y Próximas queda con la de Skyline.
2. `Confirmar` en la card PENDIENTE de Skyline la convierte en
   **CONFIRMADA** ( badge verde ) y le aparece `Ver QR` ( `tieneQr: true` ).
3. `Ver QR` abre el diálogo `Tu QR` con el cuadro y `Cerrar` lo cierra.
4. La card Elite Mar 15 ( `tieneQr: false` ) muestra **solo**
   `Cancelar reserva` ( variante Sin QR ).
5. Reservar Elite 20:00 desde el flujo → al abrir Mis reservas aparece en
   **Próximas** con `20:00 - 21:00`, `Cancha A (5v5)` y badge `CONFIRMADA`.
6. Vaciar una pestaña ( cancelando sus reservas ) muestra `No tenés
   reservas` + `Explorar canchas`, que cambia al tab Inicio.
7. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Store | `reservas_locales.dart` en memoria ( patrón `usuarios_locales` ); sembrado con `reservasSimuladas` |
| Registro del flujo | `_confirmarReserva` registra solo en el camino de éxito; estado confirmada, `tieneQr: true` |
| `tieneQr` | Flag por reserva: la semilla Elite Mar 15 es `false` ( variante 08 visible ); las creadas en la sesión `true` ( estado base del PNG 03 ) |
| `Cancha.sector` | Campo nuevo ( `Cancha A (5v5)` etc. ) para que las reservas del flujo tengan el mismo dato que las semillas |
| QR | Diálogo simulado ( el mockup no define pantalla de QR ) — extensión documentada |
| Estado vacío | `Explorar canchas` cambia al tab Inicio ( mismo `onVolver` del header ) |
| Fecha del flujo | `<label del Inicio> 2026` ( `Mié, 16 oct` → `Mié, 16 oct 2026` ); horario `<hora> - <hora+1>` |

## 9. Riesgos y notas para la siguiente iteración

- Con la API REST, el store se reemplaza por llamadas a `ReservaCancha`
  ( `services.py` ) y el QR llega real del backend.
- La pantalla de **Perfil** y **Favoritos** siguen pendientes, más el
  filtrado y el estado "sin canchas" del Inicio.
