# Spec — Tarjetas de canchas del Inicio

> As-built de `docs/HistRequerimientos/inicio-canchas.md` ( RD 2026-11-17 ).
> Parte 5 de la pantalla 01 · Inicio.

## Propósito

El bloque `Canchas disponibles` de la pantalla Inicio: las 3 cards de canchas
del mockup con foto, nombre, tag, distancia, rating, precio y botón
`Reservar`. Datos **simulados fijos**; sin filtrado ni navegación todavía.

## Cómo funciona

- Cuarto bloque de la columna del Inicio ( hueco 16 bajo el selector de
  fecha ). La columna ahora vive en un **`SingleChildScrollView`**: el
  contenido con las cards supera los 568px y la pantalla scrollea.
- **Bloque** ( `_Canchas` ): fila `spaceBetween` con `Canchas disponibles`
  17px w700 `$text` + `Ver todo` 14px w600 `$primary` ( **inerte** ) y la
  lista de 3 `_CardCancha` con hueco 12.
- **Card** ( `_CardCancha`, estilo del card vectorial de Favoritos + tag del
  PNG ): `Container` `$surface`, radio 16, borde `$border` 1px, padding 14.
  - Fila superior ( hueco 12 ): foto `Image.asset` 92×92 (`ClipRRect` radio
    12, `fit: cover`) + Info ( columna hueco 7 ): nombre 15px w700 `$text`
    ( elipsa si no cabe ) con **tag** `5v5`/`7v7` ( píldora `$primary` radio
    8, padding 4/8, texto 11px w600 blanco ); distancia ( `map-pin` 13
    `$text-2` + texto 13 `$text-2` ); rating ( `star` 13 **ámbar
    `#F59E0B`** + texto 13 `$text-2` ).
  - Fila inferior ( `spaceBetween` ): precio ( monto 17px w700 `$primary` +
    `/ hora` 12px `$text-2` ) y botón `Reservar` ( `$primary`, radio 10,
    padding 11/20, texto 14px w600 blanco ).
- **Datos** ( modelo `Cancha` en `lib/features/inicio/cancha.dart`,
  `canchasSimuladas` ): Elite Arena Central (5v5, `1.2 km de vos`,
  `4.8 (124 reseñas)`, `$45` ), Skyline Sports Hub (7v7, `2.8 km de vos`,
  `4.6 (89 reseñas)`, `$60` ), Cancha Municipal (5v5, `3.5 km de vos`,
  `4.9 (210 reseñas)`, `$40` ). `rating` y `distancia` son textos ya armados;
  `precio` es el monto ( la unidad la dibuja la UI ).
- **Assets**: las 3 fotos del mockup ( Unsplash, descargadas de los metadatos
  del `.pen` — frame Favoritos ) en
  `src/FrontEnd/assets/img/canchas/`, declaradas en `pubspec.yaml`. Sin HTTP
  en runtime.
- **Controles inertes** ( RF-02 ): card, `Reservar` y `Ver todo` solo
  descartan el teclado ( `unfocus` — conservan el comportamiento del RD del
  buscador ) y **no navegan**.

## Archivos

- `lib/features/inicio/cancha.dart` — modelo `Cancha` + `canchasSimuladas`.
- `lib/features/inicio/inicio_screen.dart` — `_Canchas`, `_CardCancha`, el
  `SingleChildScrollView` de la columna.
- `src/FrontEnd/assets/img/canchas/` ( 3 JPEG ) + `pubspec.yaml`.
- `test/cancha_test.dart` ( 3 unit tests ) y `test/inicio_canchas_test.dart`
  ( 6 widget tests ).

## Decisiones

- Fotos = **assets locales** con las imágenes exactas del mockup ( las URLs
  están en los metadatos del `.pen` ); sin HTTP en runtime.
- Card idéntico al card vectorial de Favoritos; en el Inicio el ícono de
  favorito se reemplaza por el **tag** ( como muestra el PNG ).
- Datos fijos en un modelo propio: cuando llegue el filtrado y la API, solo
  cambia la fuente de `canchasSimuladas`.
- La fila precio/botón usa `Flexible` + ellipsis en `/ hora` ( en la fuente
  de test no cabe en 320px; en dispositivo real nunca trunca ).
- Título del bloque con `Flexible` + ellipsis ( misma política de las
  etapas previas ).

## Límites ( NO hace )

- **No filtra** por buscador/fecha/categoría ( RD propio "filtrado del
  Inicio" ).
- **No navega**: card y `Reservar` no abren el Detalle de cancha ( llega con
  su RD ); `Ver todo` no tiene pantalla.
- Sin favoritos, paginación ni "cargar más".

## Conexiones

- Comparte la columna con header, buscador y selector de fecha
  ( `inicio-header.md`, `inicio-buscador.md`, `inicio-fecha.md` ).
- Con el **Detalle de cancha**, la card y `Reservar` navegan pasando la
  `Cancha` seleccionada. Con el **filtrado**, la lista se vuelve derivada
  de los estados del buscador/fecha/categoría sobre `canchasSimuladas`.
