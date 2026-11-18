# Spec — Detalle de cancha · comodidades y descripción ( pantalla 02, parte 2 )

> As-built de `docs/HistRequerimientos/detalle-comodidades.md`
> ( RD 2026-11-17 ). Pantalla 02 del prototipo, parte 2 de 3.

## Propósito

Los bloques `Comodidades` ( 5 ítems con estado disponible/no disponible +
aviso de faltantes ) y `Sobre esta cancha` ( descripción ) del Detalle.

## Cómo funciona

- Van en la columna del Detalle ( hueco 16, después de nombre/dirección;
  estructura en `detalle-hero.md` ).
- **`_Comodidades`** ( hueco 12 ): título 17px w700 + fila `spaceBetween`
  ( padding horizontal 6 ) con los **5 ítems fijos** en orden: Duchas
  (`shower-head`), Estac. (`square-parking`), Aire a/c (`snowflake`), Agua
  (`droplet`), WiFi (`wifi`) — cada uno en `Flexible` ( clave
  `ValueKey('comodidad-<slug>')` ).
  - Ítem: columna ( hueco 6 ) — círculo 48×48 ( `BoxDecoration(shape:
    circle)` ) con glyph 21×21 centrado + label 11px w500 `$text-2`.
  - **Disponible**: círculo `$surface`, glyph `$text`.
  - **No disponible**: círculo `#F1F5F9`, glyph `$text-2` en
    `Opacity(0.45)`, label `$text-2` en `Opacity(0.5)`.
  - Estado por cancha: `cancha.comodidadesNoDisponibles` ( lista de labels
    exactos; vacío = todo disponible ).
- **Aviso** ( solo si hay faltantes ): `Row` — `info` (lucide) 14×14 ámbar
  `#F59E0B` + texto **generado**: nombres completos de los faltantes
  ( mapa `{ 'Estac.': 'Estacionamiento' }`, resto = label ) unidos con ` y `
  + ` no disponibles hoy` ( 12px w500 ámbar ).
- **`_Sobre`** ( hueco 8 ): título `Sobre esta cancha` 17px w700 + párrafo
  `cancha.descripcion` 14px `$text-2` con `height: 1.55` ( wrap natural ).
- **Sin interacción** ( RF-03 ): los ítems son indicadores.

## Archivos

- `lib/features/detalle/detalle_screen.dart` — `_Comodidades`,
  `_ItemComodidad`, `_Aviso`, `_Sobre`.
- `lib/features/inicio/cancha.dart` — modelo + `comodidadesNoDisponibles`
  ( `List<String>` ) y `descripcion`.
- `test/detalle_comodidades_test.dart` ( 6 tests ) + `test/cancha_test.dart`
  ( datos ).

## Decisiones

- Los 5 ítems son **fijos** ( no dinámicos ); el estado por cancha vive en
  `comodidadesNoDisponibles` con labels exactos.
- La **variante "no disponibles"** del mockup la cubren los datos de
  **Skyline** ( `Estac.` y `WiFi` off ): el frame 07 no nombra la cancha;
  Elite y Municipal quedan con el estado base.
- El aviso se **genera** ( nombres completos ) en vez de ser texto fijo:
  coincide con el mockup y se mantiene si cambian los datos.
- `Estac.` se expande a `Estacionamiento` solo en el aviso ( el label del
  chip se mantiene abreviado, como el mockup ).
- Colores literales `#F1F5F9` y ámbar `#F59E0B` ( sin tokens nuevos ).

## Límites ( NO hace )

- Sin horarios ni barra `Precio total / Confirmar reserva` ( parte 3 ).
- Los ítems no son tappable ni filtros.

## Conexiones

- Completa el contenido del Detalle ( `detalle-hero.md` ); la **parte 3**
  agrega horarios + `Confirmar reserva` y desencadena el flujo de reserva.
- Con la API REST, `comodidadesNoDisponibles` vendrá del backend y el aviso
  se regenera igual.
