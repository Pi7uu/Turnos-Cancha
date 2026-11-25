# Spec — Error de reserva ( pantalla 10 )

> As-built de `docs/HistRequerimientos/reserva-error.md` ( RD 2026-11-25 ).
> Flujo de reserva, pantalla de error. Completa el flujo central.

## Propósito

La pantalla `No se pudo completar la reserva` para cuando otro usuario tomó
el horario antes de confirmar ( carrera simulada ). Define la **condición de
éxito/error** del `Confirmar reserva` que quedó pendiente en
`reserva-exitosa.md`.

## Cómo funciona

- **Regla** ( RD RF-01 ): `_confirmarReserva` en el Detalle abre
  **`ReservaErrorScreen`** si `cancha.horasEnConflicto.contains(hora)`, y
  **`ReservaExitosaScreen`** si no ( misma firma de datos
  `cancha/fecha/hora` ). Data simulada: Elite `['18:00']`, Skyline `[]`,
  Municipal `[]` — una sola regla para poder ver el error sin romper el
  flujo feliz ( default 19:00 ).
- **Layout** ( frame 10; columna **centrada verticalmente** con el patrón
  `LayoutBuilder`+`ConstrainedBox(minHeight)` del login; padding 32/24,
  hueco 20; círculo+título con hueco 18 ):
  - Círculo 96×96 `#FEE2E2` radio 48 con `LucideIcons.x` 46×46 `$danger`.
  - Título `No se pudo completar la reserva` 24px w700 `$text` centrado.
  - Subtítulo 15px `$text-2` `height: 1.5` centrado:
    `La cancha <nombre> del <día> de octubre a las <hora> ya fue reservada
    por otro usuario.` ( día = dígitos del label `fecha`, RegExp `(\d+)` ).
  - Card ( `$surface`, radio 16, borde `$border` 1px, padding 20 ) con 3
    filas `spaceBetween` ( label 11px w600 `letterSpacing` 1 `$text-2` ) y
    separadores 1px `$border` con hueco 14: `MOTIVO` + `Horario ocupado`
    ( 14px w700 `$text`, fijo ); `ESTADO DE PAGO` + badge `SIN COBRO`
    ( `$primarySoft`, radio 6, padding 5/9, texto 10px w700 `letterSpacing`
    0.5 `$primary`, fijo ); `ALTERNATIVAS` + **`<N> canchas libres`** (
    14px w700 `$primary`, **derivado**: otras canchasSimuladas con esa hora
    libre ( no ocupada ni en conflicto ); pluralización `1 cancha libre` /
    `<N> canchas libres` ).
  - Nota `Te avisamos por email en cuanto se libere un horario.` 13px
    `$text-2` centrada.
  - Botones ( ancho completo, radio 12, padding 15 ): `Elegir otro horario`
    ( `$primary`, texto 16px w600 blanco ) y `Volver al inicio`
    ( `$surface` + borde `$border`, texto 16px w600 `$text` ).
- **Acciones** ( RD RF-03 ): `Elegir otro horario` → `pop` ( vuelve al
  Detalle **con la selección viva** para elegir otra hora );
  `Volver al inicio` → `popUntil(isFirst)` ( conserva el estado del shell ).
  Claves `ValueKey('error-elegir-otro')` / `ValueKey('error-volver')`.

## Archivos

- `lib/features/reserva/reserva_error_screen.dart` — pantalla,
  `_IconoError`, `_CardError`, `_FilaError`, `_BadgeSinCobro`.
- `lib/features/detalle/detalle_screen.dart` — `_confirmarReserva`
  condicional.
- `lib/features/inicio/cancha.dart` — `horasEnConflicto`.
- `test/reserva_error_test.dart` ( 5 tests ) + `test/detalle_horarios_test.dart`
  ( flujo: conflicto→error, elegir otro→detalle con selección, volver→estado )
  + `test/cancha_test.dart`.

## Decisiones

- Conflicto simulado con **una sola regla** ( Elite 18:00 ): ver el error
  con un tap sin romper el flujo feliz. El ejemplo del mockup dice 19:00,
  pero hacer fallar el default rompería el camino de éxito ( decisión del
  RD §8 ).
- `ALTERNATIVAS` derivado de la data ( no fijo como en el mockup ) con
  pluralización correcta en es-AR.
- `Elegir otro horario` = `pop` al Detalle: la selección de hora vive en el
  Detalle y sigue viva ( no se resetea ).
- `MOTIVO`/`SIN COBRO` fijos ( el mockup define un solo motivo ).
- Círculo con `borderRadius: 48` ( no `shape: circle` ) para igualar el
  assert del spec — mismo patrón que el botón del hero.

## Límites ( NO hace )

- No persiste el intento fallido ni avisa por email ( la nota es texto ).
- Sin motivos distintos de `Horario ocupado` ni estados de cobro.
- `ALTERNATIVAS` no navega a una lista de alternativas.

## Conexiones

- `Confirmar reserva` del Detalle ( `detalle-horarios.md` ) abre esta
  pantalla o la de éxito ( `reserva-exitosa.md` ) según la regla.
- Con la API REST, el conflicto vendrá del backend y las alternativas de
  disponibilidad real. Con **Mis reservas**, los intentos fallidos podrían
  registrarse.
