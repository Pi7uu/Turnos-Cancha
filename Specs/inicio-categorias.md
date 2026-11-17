# Spec — Categorías del Inicio

> As-built de `docs/HistRequerimientos/inicio-categorias.md` ( RD 2026-11-17 ).
> Parte 6 de la pantalla 01 · Inicio. Con este bloque el layout del Inicio
> queda completo.

## Propósito

El bloque `Categorías` de la pantalla Inicio: 2 chips (`Fútbol 5`,
`Fútbol 7`) con ícono y label. **Solo visuales**: no filtran ni navegan.

## Cómo funciona

- Quinto y último bloque de la columna del Inicio ( hueco 16 bajo la lista
  de canchas; estructura en `inicio-header.md` ). Bloque vertical con hueco
  10 entre el título y la fila de chips.
- **Título**: `Categorías` 17px w700 `$text`.
- **Fila de chips** ( hueco 12, reparto igual por `Expanded` ):
  - Chip ( clave `ValueKey('categoria-futbol5')` / `-futbol7` ): `Container`
    `$surface`, radio 14, borde `$border` 1px, padding 18/12, vertical
    centrado, hueco 8.
  - Caja de ícono 44×44, `$primarySoft`, radio 22, centrada: glyph lucide
    20×20 `$primary` ( **`users`** en Fútbol 5, **`layout-grid`** en
    Fútbol 7 ).
  - Label 14px w600 `$text` ( elipsa si no cabe ).
- **Chips inertes** ( RF-02 ): `GestureDetector` que solo llama `unfocus`
  ( mismo patrón que cards/`Reservar`/`Ver todo` ).

## Archivos

- `lib/features/inicio/inicio_screen.dart` — `_Categorias`, `_ChipCategoria`.
- `test/inicio_categorias_test.dart` ( 5 tests: textos e íconos por chip,
  estilo/geometría, reparto igual + hueco 12, inertes, sin overflow ).

## Decisiones

- Chips inertes: el filtrado por categoría llega con el RD "filtrado del
  Inicio" ( que definirá el estado de chip seleccionado, que hoy no existe ).
- Solo las 2 categorías del prototipo.
- Label con ellipsis preventivo ( en la fuente de test entra justo en 320 ).

## Límites ( NO hace )

- No filtra, no selecciona, no navega. Sin estado activo de categoría.
- Sin categorías adicionales ni dinámicas.

## Conexiones

- Último bloque de la columna del Inicio ( `inicio-header.md`,
  `inicio-buscador.md`, `inicio-fecha.md`, `inicio-canchas.md` ).
- Con el **filtrado**, los chips pasan a ser selectores de categoría sobre
  `canchasSimuladas`.
