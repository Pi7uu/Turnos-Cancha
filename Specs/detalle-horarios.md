# Spec — Detalle de cancha · horarios y barra de reserva ( pantalla 02, parte 3 )

> As-built de `docs/HistRequerimientos/detalle-horarios.md`
> ( RD 2026-11-17 ). Pantalla 02 del prototipo, parte 3 de 3 — cierra el
> layout del Detalle.

## Propósito

El bloque `Elegí el horario` ( 6 slots con estados y selección real ) y la
**barra fija de reserva** ( `PRECIO TOTAL` + `Confirmar reserva` ) del
Detalle. Con esto la pantalla 02 está completa salvo el flujo de reserva.

## Cómo funciona

- **`_Horarios`** ( hueco 16 bajo `Sobre esta cancha`, hueco 12 interno ):
  fila `spaceBetween` ( `Elegí el horario` 17px w700 `$text` + fecha 13px
  `$text-2` ) y 2 filas de 3 slots ( hueco 10, cada slot `Expanded` ).
  - Slot ( clave `ValueKey('hora-<HH:MM>')` ): `Container` radio 10, padding
    13/0, centrado: hora 15px w600. **Disponible** `$surface`/`$text-2`;
    **seleccionado** `$primary`/blanco; **ocupado** `#F1F5F9`/`$text-2` en
    `Opacity(0.5)`.
  - Horas fijas: 17:00…22:00. Ocupadas según `cancha.horasOcupadas`
    ( Elite `['21:00']`, Skyline `['17:00','21:00']`, Municipal `['20:00']` ).
  - **Selección**: estado de `_DetalleScreenState` ( `String _seleccionado =
    '19:00'` — default del mockup ); tap en disponible lo cambia y desmarca
    el anterior; ocupado y seleccionado no reaccionan. El monto no cambia
    con la selección.
- **`_BarraReserva`** ( `bottomNavigationBar` del `Scaffold`, como la tab
  bar del shell ): `Container` `$surface` con borde superior `$border` 1px,
  padding 16/20, `Row(spaceBetween)`:
  - `PRECIO TOTAL` 11px w600 `letterSpacing` 1 `$text-2` + monto
    `cancha.precio + '.00'` 24px w700 `$text`.
  - Botón `Confirmar reserva` ( `$primary`, radio 12, padding 15/22, texto
    15px w600 blanco + `arrow-right` 16×16 blanco ) — **inerte** ( RF-03: el
    flujo de reserva lo cablea su RD ).
- **Fecha del bloque**: parámetro `fecha` de `DetalleScreen` ( default
  `Mar, 15 oct` ) derivado del **día seleccionado en el Inicio**
  ( `['Lun','Mar','Mié','Jue','Vie'][_diaActivo] + ', ${n} oct'`, pasado por
  `_Canchas` → `_CardCancha` al abrir el Detalle ).
- **Layout note ( importante para el futuro )**: en `RenderFlex` los hijos
  **NO-flexibles nunca se encogen** ( se les pasa el eje principal sin
  límite ): por eso el `Flexible` de la barra va sobre el **botón** ( cuyo
  texto elipsa ) y el precio va natural. Mismo motivo por el que la marca y
  los títulos van en `Flexible`.

## Archivos

- `lib/features/detalle/detalle_screen.dart` — `DetalleScreen` ( StatefulWidget,
  `fecha` + `_seleccionado` ), `_Horarios`, `_SlotHora`, `_BarraReserva`.
- `lib/features/inicio/inicio_screen.dart` — `_fechaLabel()` y el paso de
  `fecha` hasta `DetalleScreen`.
- `lib/features/inicio/cancha.dart` — `horasOcupadas`.
- `test/detalle_horarios_test.dart` ( 7 tests ) + `test/cancha_test.dart`.

## Decisiones

- Horas ocupadas como data fija en `Cancha`; selección default `19:00` (
  libre en las 3 canchas de la data actual ).
- Fecha derivada del día elegido en el Inicio ( coherencia entre pantallas );
  default `Mar, 15 oct` en el constructor para los tests.
- Monto `precio + '.00'` ( `$45` → `$45.00` ), fijo por hora como el mockup.
- `Confirmar reserva` inerte hasta el RD del flujo de reserva.
- El `Flexible` de la barra va sobre el botón, no sobre el precio ( ver
  "Layout note" ).

## Límites ( NO hace )

- **No reserva**: `Confirmar reserva` no navega ni registra nada ( flujo de
  reserva: éxito / error — próximos RDs ).
- Sin disponibilidad real por fecha/hora; sin cambios de precio por horario.

## Conexiones

- Completa la pantalla 02 ( `detalle-hero.md`, `detalle-comodidades.md` ).
- El **flujo de reserva** ( próximo ) usará la cancha, la fecha y el horario
  seleccionado para generar la reserva y mostrar `¡Reserva exitosa!` o el
  error.
