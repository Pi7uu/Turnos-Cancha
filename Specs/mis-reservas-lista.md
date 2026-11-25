# Spec — Mis reservas · lista y pestañas ( pantalla 03, parte 1 )

> As-built de `docs/HistRequerimientos/mis-reservas-lista.md`
> ( RD 2026-11-25 ). Pantalla 03, parte 1 de 2.

## Propósito

La pantalla **Mis reservas** ( tab del shell ): header, las 3 pestañas
Próximas/Completadas/Canceladas y las cards de reserva con su estado.
Reemplaza el tab vacío al que llegaba `Ver mis reservas`.

## Cómo funciona

- **`MisReservasScreen`** ( `lib/features/mis_reservas/mis_reservas_screen.dart` )
  es el tab del shell ( clave `placeholder-mis-reservas` — sin cambios ).
  Estado local: `int _pestana` ( 0=Próximas, 1=Completadas, 2=Canceladas ).
- **Header** ( fila gap 14 ): botón **Volver** ( 40×40 `$surface` radio 20
  borde `$border`, `chevron-left` 20×20, `Semantics(button, 'Volver')` ) +
  `Mis reservas` 24px w700 `$text`. `onVolver` lo inyecta `MainShell`:
  cambia al tab Inicio **conservando su estado** ( IndexedStack ).
- **Pestañas** ( 3 en `Expanded`, clave `ValueKey('pestana-<slug>')` ):
  label 15px ( activa `$primary` w600 / inactiva `$text-2` w500 ) + gap 9 +
  subrayado `Container(height: 3, radio 2)` ( activo `$primary`, inactivo
  `transparent` ). Tap cambia `_pestana` ( sin swipe ).
- **Lista** ( `ListView.separated`, hueco 12 ) de `_CardReserva` ( clave
  `ValueKey('reserva-<índice>')` ) filtrada por pestaña: Próximas =
  confirmada|pendiente; Completadas = completada; Canceladas = cancelada.
- **Card** ( `$surface`, radio 16, borde `$border` 1px, padding 16, hueco 14 ):
  - Superior ( gap 12 ): foto `Image.asset` 48×48 `ClipRRect` radio 10 +
    Info ( nombre 15px w700 `$text` + fecha 13px `$text-2` ) + **badge de
    estado** ( radio 6, padding 5/9, texto 10px w700 `letterSpacing` 0.5 ).
  - Detalle ( `spaceBetween` ): `HORARIO` + rango ( 17px w700 ) · `CANCHA` +
    sector ( alineado a la derecha ); labels 10px w600 `letterSpacing` 1
    `$text-2`.
  - **Acciones** ( solo en Próximas ): `Cancelar reserva` ( `$surface` +
    borde, radio 10, padding 12, texto 14px w600 `$text` ) + `Ver QR` /
    `Confirmar` ( `$primary`, radio 10, padding 12, texto blanco ). En
    Completadas/Canceladas **no hay botones** ( decisión del plan: la
    reserva ya terminó ).
- **Badges**: `CONFIRMADA` `$primary`/blanco · `PENDIENTE` `#F59E0B`/blanco
  · `COMPLETADA` `$primarySoft`/`$primary` · `CANCELADA` `#FEE2E2`/`$danger`
  ( los dos últimos son extensiones — el mockup solo define CONFIRMADA y
  PENDIENTE ).

## Archivos

- `lib/features/mis_reservas/reserva.dart` — `EstadoReserva`, `Reserva`,
  `reservasSimuladas` ( 4: las 2 del mockup + 1 completada + 1 cancelada ).
- `lib/features/mis_reservas/mis_reservas_screen.dart` — pantalla,
  `_Header`, `_Pestana`, `_CardReserva`, `_CampoDetalle`, `_BadgeEstado`.
- `lib/features/navegacion/main_shell.dart` — el tab Mis reservas es la
  pantalla real ( `onVolver` cambia al tab Inicio ).
- `test/reserva_test.dart` ( 3 tests ) + `test/mis_reservas_test.dart`
  ( 8 tests ).

## Decisiones

- Data **fija simulada** ( 4 reservas ); el store compartido con el flujo
  ( "la reserva creada aparece en Próximas" ) llega en la **parte 2**.
- `Volver` cambia al tab Inicio vía callback ( no `popUntil` ): la pantalla
  es un tab del shell y el IndexedStack conserva el estado del Inicio.
- **Sin botones** en Completadas/Canceladas ( refinamiento del RD: esas
  reservas ya terminaron ).
- Badges `COMPLETADA`/`CANCELADA` = extensiones con colores coherentes con
  el resto de la app.
- Fotos = `cancha.foto` ( assets existentes; el mockup muestra otra foto
  para Elite en esta pantalla — se prioriza consistencia de datos ).

## Límites ( NO hace )

- **Acciones inertes**: `Cancelar reserva`, `Ver QR` y `Confirmar` no hacen
  nada ( parte 2 ).
- Sin estados vacíos ( frame 09 ) ni variante "Sin QR" ( frame 08 ) — parte 2.
- Sin swipe entre pestañas, recordatorios ni reseñas.

## Conexiones

- Tab del shell ( `navegacion.md` ); llega desde `Ver mis reservas` del
  flujo de reserva ( `reserva-exitosa.md` ).
- **Parte 2** ( próximo RD ): acciones reales + store en memoria compartido
  con el flujo + estados vacíos + variante Sin QR. Con la API REST, el
  modelo `Reserva` se alimenta de `ReservaCancha`.
