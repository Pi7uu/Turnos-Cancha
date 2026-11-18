# Spec — Detalle de cancha · hero e info ( pantalla 02, parte 1 )

> As-built de `docs/HistRequerimientos/detalle-hero.md` ( RD 2026-11-17 ).
> Pantalla 02 del prototipo, parte 1 de 3.

## Propósito

La pantalla **Detalle de cancha**: hero con foto y botones + badge/rating/
precio + nombre + dirección, abierta desde las cards del Inicio. Es la
puerta del flujo central ( reservar ).

## Cómo funciona

- **Navegación** ( RD RF-02 ): tocar una **card** del Inicio o su botón
  **`Reservar`** empuja `DetalleScreen(cancha: cancha)` ( `MaterialPageRoute`
  ). **Volver** ( botón del hero ) hace `pop` y el Inicio conserva su estado
  ( buscador, día seleccionado, scroll — pantalla precargada en el shell ).
  `Ver todo` sigue inerte.
- **`DetalleScreen`** ( `lib/features/detalle/detalle_screen.dart` ) es una
  pantalla **apilada** sin tab bar, con `SingleChildScrollView` ( la
  pantalla crece en las partes 2/3 ):
  - **Hero** ( `_Hero` ): `Image.asset(cancha.hero, fit: cover)` a todo el
    ancho, alto **240 + el safe area superior** ( la foto va detrás de la
    status bar; en tests sin insets mide 240 ). Tres botones circulares
    ( 40×40, `$surface`, radio 20, sombra `#0F172A26` offset (0,2) blur 8,
    ícono 19×19 `$text` ) con `Positioned` relativo al hero: **Volver**
    (16, 16) `chevron-left` ( hace `pop` ), **Compartir** (269, 16)
    `share-2` y **Favorito** (319, 16) `heart` ( inertes — RF-03 ). Claves:
    `detalle-volver` / `detalle-compartir` / `detalle-favorito`.
  - **Content** ( padding 18/16/24/16, hueco 16 ): fila
    `spaceBetween` — izquierda ( hueco 10 ): badge `PREMIUM` ( `$primary`,
    radio 6, padding 5/9, texto 10px w700 blanco, `letterSpacing` 0.8,
    **solo si `cancha.premium`** ) + rating ( hueco 4 ): estrella 15 ámbar
    `#F59E0B` + `cancha.puntuacion` ( 14px w600 `$text` ); derecha ( columna
    alineada a la derecha ): monto 22px w700 `$primary` + `por hora` 11px
    `$text-2`. Debajo: nombre 24px w700 `$text` y dirección ( hueco 6 ):
    pin 16 `$text-2` + texto 14px `$text-2`.
- **Datos** ( campos nuevos de `Cancha` en `lib/features/inicio/cancha.dart` ):
  `direccion` ( String ), `puntuacion` ( double ), `premium` ( bool ),
  `hero` ( path; si no hay hero propio, usa `foto` ). Elite: `Av. de los
  Deportes 123, Centro` / 4.8 / true / hero del mockup ( asset
  `elite_arena_hero.jpg` ); Skyline: `Av. del Parque 789, Oeste` / 4.6 /
  true / su foto; Municipal: `Calle San Martín 45, Centro` / 4.9 / **false**
  ( sin badge ) / su foto.

## Archivos

- `lib/features/detalle/detalle_screen.dart` — `DetalleScreen`, `_Hero`,
  `_BotonHero`, `_PrecioRating`, `_NombreDireccion`.
- `lib/features/inicio/cancha.dart` — modelo ampliado ( +4 campos ).
- `lib/features/inicio/inicio_screen.dart` — `_CardCancha` navega al Detalle.
- `assets/img/canchas/elite_arena_hero.jpg` ( foto del hero del mockup ).
- `test/detalle_screen_test.dart` ( 5 tests ) y `test/inicio_canchas_test.dart`
  ( navegación: card, Reservar, Ver todo inerte, volver conserva estado ).

## Decisiones

- Cards y `Reservar` **navegan** al Detalle ( reemplaza la inercia declarada
  en el RD `inicio-canchas.md` RF-02 — cambio de alcance documentado en el
  RD de este feature ).
- El modelo `Cancha` crece 4 campos propios del Detalle en vez de parsear
  los textos de la card.
- Direcciones de Skyline y Municipal **inventadas** ( el mockup solo define
  la de Elite ); `premium: false` en Municipal para cubrir la variante sin
  badge.
- El hero usa la foto del mockup para Elite; las otras canchas usan su foto
  de card ( el mockup solo define el hero de Elite ).
- Botón con `borderRadius: 20` ( no `shape: circle` ): igual en 40×40 y
  consistente con los radios del spec.
- Favorito y Compartir inertes ( sin pantallas destino ).

## Límites ( NO hace )

- Sin comodidades ni "Sobre esta cancha" ( parte 2 ).
- Sin horarios ni barra `Precio total / Confirmar reserva` ( parte 3 — abre
  el flujo de reserva ).
- Favorito no marca nada; Compartir no comparte.

## Conexiones

- Se abre desde las cards del Inicio ( `inicio-canchas.md` ).
- La parte 2 agrega comodidades + descripción ( y la variante "comodidades
  no disponibles" ); la parte 3 agrega horarios y `Confirmar reserva`, que
  desencadena el flujo de reserva ( éxito / error ).
