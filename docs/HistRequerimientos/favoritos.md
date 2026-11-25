# Requerimientos — Favoritos ( pantalla 12 )

**Fecha:** 2026-11-25
**Estado:** Listo para implementar ( ciclo autónomo: sin aprobación intermedia )
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"12 · Favoritos"** ( vectores, id `EB782` )

---

## 1. Objetivo

Implementar la pantalla **Favoritos** del Tab Bar: lista de canchas
favoritas con sus datos, quitar favoritos con el corazón y `Reservar` que
abre el Detalle.

## 2. Contexto

- El tab Favoritos es el último placeholder del shell.
- Ya existen: shell, Detalle completo, flujo de reserva, Mis reservas,
  Perfil, y el modelo `Cancha` con todos los datos de las cards.

## 3. Alcance

### Dentro del alcance

- **Pantalla Favoritos** ( RF-01 ): header `Favoritos` + contador `N canchas`,
  lista de cards ( foto 92×92, nombre + corazón, distancia, rating, precio,
  botón `Reservar` ) con los datos del mockup.
- **Quitar favorito** ( RF-02 ): el corazón de la card la saca de la lista (
  actualiza el contador ); con la lista vacía se muestra un estado vacío.
- **`Reservar`** ( RF-03 ): abre el Detalle de esa cancha ( misma navegación
  que las cards del Inicio ).

### Fuera de alcance

- Agregar favoritos desde el Detalle ( el corazón del hero sigue inerte —
  enlace futuro ).
- Persistencia de favoritos entre arranques.

## 4. Espec visual ( frame 12 )

Fondo `$bg`. Content: vertical, hueco 16, padding 8/16/16/16.

| Elemento | Especificación |
|---|---|
| Header | fila space_between centrada: `Favoritos` 24px w700 `$text` + `N canchas` 14px normal `$text-2` |
| Lista | vertical, reparte las cards por el alto ( espacio entre cards ) |
| Card | `$surface`, radio 16, borde `$border` 1px, vertical, hueco 12, padding 14 |
| Superior | fila, hueco 12, centrada: **foto** 92×92 radio 12 + **Info** ( vertical, hueco 7 ) |
| Nombre fila | space_between centrada: nombre 15px w700 `$text` ( fill ) + `heart` 18×18 #EF4444 |
| Distancia | fila hueco 5: `map-pin` 13×13 `$text-2` + texto 13px `$text-2` ( `1.2 km de vos` ) |
| Rating | fila hueco 5: `star` 13×13 ámbar ( #F59E0B ) + texto 13px `$text-2` ( `4.8 (124 reseñas)` ) |
| Inferior | fila space_between centrada: precio ( hueco 4: monto 17px w700 `$primary` + `/ hora` 12px `$text-2` ) + botón `Reservar` ( `$primary`, radio 10, padding 11/20, texto 14px w600 blanco ) |

### Datos ( §8 )

Las 3 canchas del mockup = `canchasSimuladas` ( se reutilizan sus campos
`foto`, `nombre`, `distancia`, `puntuacion`, `precio` ): Elite Arena Central
( `1.2 km de vos`, `4.8 (124 reseñas)`, `$45` ), Skyline Sports Hub ( `2.8 km
de vos`, `4.6 (89 reseñas)`, `$60` ), Cancha Municipal ( `3.5 km de vos`,
`4.9 (210 reseñas)`, `$40` ). Nota: el frame 12 dice `134 reseñas` para
Elite pero el Inicio ( implementado ) dice `124` — se usa el dato del modelo
( 124 ), inconsistencia menor del mockup.

### Estado vacío ( extensión — el mockup no lo define )

Igual estilo que el frame 09 de Mis reservas: círculo 88×88 `$primarySoft`
con `heart` 40×40 `$primary`, `Todavía no tenés favoritos` 19px w700,
descripción `Cuando marques una cancha como favorita va a aparecer acá.` 14px
`$text-2` ( ancho máx 270, centrada ) y botón `Explorar canchas` ( `$primary`,
radio 12, padding 14/30 ) → tab Inicio.

## 5. Requerimientos funcionales

### RF-01 — Pantalla Favoritos

- Muestra las canchas favoritas con sus datos y el contador `N canchas`
  ( singular: `1 cancha` ).

### RF-02 — Quitar favorito

- El corazón de la card elimina esa cancha de favoritos: desaparece de la
  lista y el contador baja.
- Lista vacía → estado vacío de §4; **`Explorar canchas`** cambia al tab
  Inicio.

### RF-03 — Reservar

- `Reservar` abre el **Detalle** de esa cancha ( como las cards del Inicio ),
  con la fecha por defecto `Mar, 15 oct` ( §8 ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos de §4 (`es-AR`).
- **Tokens:** existentes ( ámbar #F59E0B y rojo #EF4444 ya se usan en las
  cards del Inicio ). Sin tokens nuevos.
- **Íconos:** `LucideIcons.heart`, `mapPin`, `star` ( instalados ).
- **Plataforma:** móvil 375×844; sin overflow en 320×568.
- **Sin red; sin persistencia** entre arranques.

## 7. Criterios de aceptación

1. El tab Favoritos muestra `Favoritos`, `3 canchas` y las 3 cards con foto,
   nombre + corazón rojo, `X km de vos`, rating con estrella ámbar, precio
   y `Reservar`.
2. Tocar el corazón de la card de Elite la saca de la lista: quedan 2 cards
   y el contador dice `2 canchas`.
3. Vaciar la lista muestra el estado vacío con `Todavía no tenés favoritos` y
   `Explorar canchas`, que cambia al tab Inicio.
4. `Reservar` en la card de Skyline abre el Detalle de Skyline ( con fecha
   `Mar, 15 oct` ) y su `Volver` regresa a Favoritos.
5. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Store | `favoritos_locales.dart` en memoria ( patrón `reservas_locales` ): `List<Cancha> favoritosLocales` sembrada con `canchasSimuladas`, `quitarFavorito(Cancha)`, `resetFavoritos()` |
| Datos | Se reutilizan `canchasSimuladas` ( mismos campos que las cards del Inicio ) |
| `Reservar` → fecha | `Mar, 15 oct` ( día por defecto del selector del Inicio ) — no hay selector de fecha en Favoritos |
| Estado vacío | Extensión documentada ( el mockup no lo define ), estilo frame 09 |
| Corazón del Detalle | Sigue inerte ( fuera de alcance ); el enlace favoritos ↔ Detalle llega después |
| Contador | `N canchas` / `1 cancha` ( singular ) |

## 9. Riesgos y notas para la siguiente iteración

- Con backend: favoritos persistidos por usuario; el corazón del Detalle
  debe sincronizar con esta lista.
- Quedan: filtrado + estado "sin canchas" del Inicio ( 06 ) y la fase
  backend.
