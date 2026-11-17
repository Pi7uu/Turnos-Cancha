# Spec — Header del Inicio ( marca, campana, perfil )

> As-built de `docs/HistRequerimientos/inicio-header.md` ( RD 2026-11-17 ).
> Parte 2 de la pantalla 01 · Inicio.

## Propósito

La fila superior de la pantalla Inicio: marca `TurnosCancha` a la
izquierda, campana de notificaciones con badge y perfil a la derecha. Por
ahora **solo visual** ( la pantalla completa se va llenando por partes ).

## Cómo funciona

- `InicioScreen` ( `lib/features/inicio/inicio_screen.dart` ) reemplaza al
  placeholder del tab Inicio en el shell. Estructura de contenido del mockup:
  `Scaffold` ( `$bg` ) + `SafeArea` + `Padding( top 8 / lados 16 / abajo 16 )`
  + **Columna con hueco 16 entre bloques** — hoy solo el header; los bloques
  siguientes ( buscador, fecha, canchas, categorías ) se apilan acá.
- **Header** ( fila `spaceBetween`, centrada ):
  - **Marca** ( hueco 8 ): logo `Container` **34×34** `$primary` radio 10 con
    `Icons.sports_soccer` 20px blanco centrado + `TurnosCancha` **18px
    bold** `$primary`.
  - **Acciones** ( hueco 16 ): **campana** caja 26×26 (`Stack`): `bell`
    (lucide) 22×22 `$text` en (1, 3) + badge círculo **9×9** `$danger` con
    borde blanco 2px en (17, 0) ( sobresale arriba-derecha del ícono );
    **perfil**: `user` (lucide) 23×23 `$text`.
- **Campana y perfil no navegan** ( `GestureDetector(onTap: () {})` ): son
  visibles pero inertes — el prototipo no define pantalla de notificaciones y
  el perfil ya existe como tab. El badge está **siempre visible** ( único
  estado del mockup ).
- La marca va en `Flexible` ( con el label en `maxLines 1 + ellipsis` ): en
  pantallas angostas o fuentes anchas **el nombre se elipsa** en vez de
  desbordar la fila; en dispositivos reales nunca se trunca.

## Archivos

- `lib/features/inicio/inicio_screen.dart` — pantalla + `_Header`, `_Marca`,
  `_Acciones`, `_Campana` ( widgets privados en el mismo archivo ).
- `test/inicio_screen_test.dart`.

## Decisiones

- Medidas del **mockup vectorial** ( frame 06 ), no del PNG de referencia:
  el PNG mostraba la marca más grande ( ~44×44 ) y el badge ámbar; se adoptó
  34×34 y badge rojo `#EF4444`.
- Acciones inertes ( mismo criterio que los links muertos del login ).
- Tipografía: fuente por defecto de Flutter si Inter no está configurada
  ( decisión de las etapas previas ).

## Límites ( NO hace )

- La campana no abre notificaciones; el perfil no navega ( taps muertos ).
- No hay estado "sin notificaciones" ( el badge nunca se oculta ).
- El resto de la pantalla está vacío: buscador, fecha, canchas y categorías
  llegan en RDs siguientes.

## Conexiones

- Vive dentro del tab Inicio del **shell** ( `navegacion.md` ).
- La estructura de columna ( padding 8/16/16/16, hueco 16 ) es la base en la
  que se apilan los próximos bloques del Inicio ( el siguiente: buscador ).
