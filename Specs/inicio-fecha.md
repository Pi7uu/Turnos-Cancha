# Spec — Selector de fecha del Inicio

> As-built de `docs/HistRequerimientos/inicio-fecha.md` ( RD 2026-11-17 ).
> Parte 4 de la pantalla 01 · Inicio.

## Propósito

El bloque `Elegí la fecha` de la pantalla Inicio: tira de 5 días fijos con
uno seleccionado ( por defecto MAR 15 ). La selección es **estado visual
local**: no filtra nada hasta que llegue la lista de canchas.

## Cómo funciona

- Tercer bloque de la columna del Inicio ( hueco 16 bajo el buscador;
  estructura en `inicio-header.md` ). Bloque vertical con hueco 10 entre el
  título y la tira.
- **Título** ( fila `spaceBetween` ): `Elegí la fecha` 16px w700 `$text` +
  **mes** ( fila hueco 4 ): `Octubre` 14px w600 `$primary` + `chevron-down`
  (lucide) 15×15 `$primary`. El mes es **visual inerte**
  ( `GestureDetector` vacío — sin picker, el prototipo no lo define ).
- **Tira de días** ( fila, hueco 8, padding derecho 1 ): 5 chips en
  `Expanded` ( reparto igual ). Chip: vertical centrado, hueco 2, padding
  9/0, radio 12, clave `ValueKey('dia-<numero>')`:
  - día `LUN`/`MAR`/`MIÉ`/`JUE`/`VIE` — 11px w500;
  - número `14`…`18` — 17px w600.
  - **Inactivo**: fondo `$surface`, día `$text-2`, número `$text`.
  - **Activo**: fondo `$primary`, día `$primarySoft`, número blanco.
- **Selección**: tocar un chip lo activa y desmarca el anterior ( índice en
  el estado de `_InicioScreenState`, por defecto **1** = MAR 15 ). Tocar el
  activo lo mantiene. La selección se conserva al cambiar de tab ( el shell
  precarga las pantallas — `navegacion.md` ).
- **Días fijos** ( `('LUN',14)…('VIE',18)` ): sin lógica de calendario.

## Archivos

- `lib/features/inicio/inicio_screen.dart` — `_Fecha`, `_ChipDia` y el
  estado `_diaActivo` en `_InicioScreenState`.
- `test/inicio_fecha_test.dart` ( 7 tests: textos, estados de color/tipografía,
  reparto igual + hueco 8, cambio de selección, conservación entre tabs,
  mes inerte, sin overflow ).

## Decisiones

- Días hardcodeados del mockup: el calendario real llega con la
  disponibilidad ( RD propio que reemplaza estos datos ).
- `Octubre ▾` inerte: el prototipo no define picker de mes.
- Siempre hay un día activo ( no existe estado "sin selección" ).
- Título con `Flexible` + ellipsis: en la fuente de test la fila no cabe en
  375px ( el decorador de tests es más ancho ); en dispositivo real nunca
  trunca.

## Límites ( NO hace )

- No filtra canchas por fecha ( la selección es solo visual ).
- Sin calendario, cambio de mes, semanas deslizables ni días dinámicos.

## Conexiones

- Comparte la columna con el **header** y el **buscador** ( `inicio-header.md`,
  `inicio-buscador.md` ).
- Con la lista de canchas ( parte 5 ), el día activo se vuelve criterio de
  búsqueda junto con el texto del buscador: el estado sube a un estado
  compartido del Inicio.
