# Spec — Reserva exitosa ( pantalla "Contenido" )

> As-built de `docs/HistRequerimientos/reserva-exitosa.md`
> ( RD 2026-11-17 ). Flujo de reserva, pantalla de éxito.

## Propósito

La pantalla `¡Reserva exitosa!` que confirma la reserva al tocar
`Confirmar reserva` en el Detalle: resumen de la reserva + navegación a
Mis reservas o al Inicio. **El flujo central de la app queda vivo de puna a
punta**: elegir → detalle → horario → reservar → confirmación.

## Cómo funciona

- **`ReservaExitosaScreen`** ( `lib/features/reserva/reserva_exitosa_screen.dart` )
  recibe `cancha`, `fecha` ( label del Inicio, ej `Mié, 16 oct` ) y `hora`
  ( la seleccionada en el Detalle ). Se abre desde
  `_DetalleScreenState._confirmarReserva` ( `push` ).
- **Layout** ( columna scrolleable centrada, padding 24/32, hueco 16 ):
  - **Ilustración**: círculo `$primary` 130 con `check` blanco 56 + punto
    ámbar `#F59E0B` 12 ( arriba-derecha ) + punto azul `#3B82F6` 9 ( izquierda ).
  - **Título** `¡Reserva exitosa!` 24px w700 `$text` centrado.
  - **Descripción** 15px `$text-2` centrada:
    `Tu cancha <nombre> quedó reservada para el <día> de octubre a las <hora>.`
    ( `<día>` = los dígitos del label `fecha`, RegExp `(\d+)` ).
  - **Card** ( `$surface`, radio 16, borde `$border` 1px, padding 20, hueco
    16 ): 3 filas `spaceBetween` con label 11px w600 `letterSpacing` 1
    `$text-2` — `N° DE ORDEN` + orden 15px w600 `$text`; `ESTADO DE PAGO` +
    píldora `PAGADO` ( `$primarySoft`, radio 8, padding 4/9, texto 11px w600
    `$primary` ); `PRECIO TOTAL` + `cancha.precio + '.00'` 20px w700
    `$primary`.
  - **Aviso** `Te enviamos la confirmación a tu email registrado.` 13px
    `$text-2` centrado.
  - **Botones** ancho completo: `Ver mis reservas` ( `$primary`, radio 12,
    texto 15px w600 blanco ) y `Volver al inicio` ( `$surface` + borde
    `$border`, radio 12, texto 15px w600 `$text` ).
- **N° de orden**: contador estático `static int _ultimoOrden = 882910` —
  cada construcción de la pantalla emite `#GB-${_ultimoOrden++}` ( el
  primero coincide con el mockup; **determinista y único** ).
- **Navegación**:
  - `Ver mis reservas` → `pushAndRemoveUntil(MainShell(tabInicial:
    TabApp.misReservas))` — el shell abre en ese tab ( hoy placeholder —
    `navegacion.md` lo llena con su RD ).
  - `Volver al inicio` → `popUntil(isFirst)` — el shell conserva su estado
    ( buscador, día, scroll ).
- `MainShell` gana `tabInicial` ( `navegacion.md` lo menciona ): parámetro
  opcional que define el tab activo al entrar.

## Archivos

- `lib/features/reserva/reserva_exitosa_screen.dart` — pantalla,
  `_Ilustracion`, `_CardResumen`, `_FilaResumen`.
- `lib/features/detalle/detalle_screen.dart` — `_confirmarReserva` ( el
  botón `Confirmar reserva` ya no está inerte ).
- `lib/features/navegacion/main_shell.dart` — `tabInicial`.
- `test/reserva_exitosa_test.dart` ( 6 tests ) + `test/detalle_horarios_test.dart`
  ( flujo: `barra_confirmar_abre_reserva_exitosa`, `flujo_completo_volver_conserva_estado`,
  `flujo_ver_mis_reservas_abre_el_tab` ) + `test/main_shell_test.dart`.

## Decisiones

- N° de orden con **contador determinista desde 882910** ( el del mockup es
  el primero, los siguientes difieren ) — único por reserva sin `Random`.
- `PAGADO` fijo y sin persistencia: la pantalla de **error** ( frame 10 del
  `.pen` ) definirá cuándo no hay éxito.
- `Ver mis reservas` reconstruye el shell con `tabInicial` ( no resetea el
  Inicio con `popUntil`, porque hay que cambiar de tab ).
- Ilustración vectorial simplificada ( sin assets: el PNG la trae como
  imagen ).
- Día de la frase derivado por regex del label de fecha ( `Mié, 16 oct` →
  `16` ).

## Límites ( NO hace )

- No persiste la reserva ( al reiniciar la app no queda registro ).
- `Ver mis reservas` muestra el **placeholder** del tab hasta que exista la
  pantalla Mis reservas ( RD aparte ).
- Sin pantalla de error todavía ( siguiente RD del flujo ).

## Conexiones

- Se abre desde `Confirmar reserva` del Detalle ( `detalle-horarios.md` ).
- `Ver mis reservas` → tab Mis reservas ( `navegacion.md` + futuro RD de
  Mis reservas, que mostrará las reservas creadas ).
- El **error de reserva** ( frame 10 ) será el próximo: definirá la
  condición de éxito/error del `Confirmar`.
