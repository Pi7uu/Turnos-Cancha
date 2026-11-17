# Requerimientos — Tarjetas de canchas del Inicio

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/01 · Inicio.png` — lista "Canchas disponibles" con las 3 cards ( única fuente del card del Inicio )
- `docs/prototipos/mockups.pen` — frame **"12 · Favoritos"**, card **"Favorito Cancha Municipal"** ( mismo estilo de card en vectores: medidas, tipografías y botón `Reservar` ) y frame **"06 · Inicio · Sin canchas"**, bloque **"Seccion"** ( título `Canchas disponibles` + `Ver todo` )

---

## 1. Objetivo

Implementar la **lista de canchas de la pantalla Inicio**: el bloque
`Canchas disponibles` con el link `Ver todo` y las **3 tarjetas de canchas**
del mockup ( foto, nombre, tag, distancia, rating, precio y botón
`Reservar` ). Es la **parte 5 de la pantalla 01 · Inicio**.

Los datos son **simulados fijos** ( las 3 canchas del mockup ): no hay
filtrado ni backend todavía.

## 2. Contexto

- La pantalla Inicio ya tiene header, buscador y selector de fecha
  ( RDs `inicio-header.md`, `inicio-buscador.md`, `inicio-fecha.md` ) sobre
  la columna con hueco 16. Este es el cuarto bloque.
- El estilo del card está en vectores en el frame de Favoritos ( el card del
  Inicio solo existe en el PNG, y solo difiere en que el ícono de favorito
  es reemplazado por el **tag** `5v5`/`7v7` ).
- Las fotos del mockup son de Unsplash ( metadatos del `.pen` ). Sin HTTP en
  la app: se empaquetan como **assets locales** ( §8 ).

## 3. Alcance

### Dentro del alcance

- Bloque **Canchas disponibles** ( §4 ): fila de título + lista de 3 cards.
- Cards con datos simulados fijos ( §4 ) — modelo local `Cancha`.
- Assets de las 3 fotos descargadas del mockup.

### Fuera de alcance

- **Filtrado** por buscador/fecha/categoría ( RD propio: "filtrado del
  Inicio" ).
- Navegación al **Detalle de cancha**: card y botón `Reservar` quedan
  **inertes** por ahora ( la navegación se cablea con el RD del Detalle ).
- Link `Ver todo`: **inerte** ( el prototipo no define la pantalla "todas
  las canchas" ).
- Estado "sin canchas" ( pantalla 06 — RD propio ) y categorías ( RD propio ).

## 4. Espec visual

### Bloque ( del mockup )

Cuarto bloque de la columna del Inicio ( hueco 16 bajo el selector de
fecha ):

| Elemento | Especificación |
|---|---|
| Fila título | ancho completo, `spaceBetween`, centrada |
| Título | `Canchas disponibles` — 17px, bold (700), `$text` |
| Link | `Ver todo` — 14px, semibold (600), `$primary` ( **sin funcionalidad** ) |
| Lista | vertical, hueco **12** entre cards y **12** bajo la fila de título |

### Card de cancha ( del card vectorial "Favorito Cancha Municipal" + tag del PNG )

| Propiedad | Valor |
|---|---|
| Card | fondo `$surface`, radio 16, borde `$border` 1px, padding **14**, vertical, hueco **12** |
| Fila superior | hueco 12, centrada |
| Foto | 92×92, radio 12, imagen ( asset local ) |
| Info | columna ( hueco 7, ancho completo ) |
| Nombre | `Elite Arena Central` — 15px, bold (700), `$text`, ocupa el ancho disponible |
| Tag | píldora del nombre: fondo `$primary`, radio 8, padding 4/8, texto `5v5`/`7v7` — 11px, semibold (600), blanco |
| Distancia | fila ( hueco 5 ): ícono `map-pin` (lucide) 13×13 `$text-2` + `1.2 km de vos` — 13px, normal, `$text-2` |
| Rating | fila ( hueco 5 ): ícono `star` (lucide) 13×13 `#F59E0B` + `4.8 (124 reseñas)` — 13px, normal, `$text-2` |
| Fila inferior | ancho completo, `spaceBetween`, centrada |
| Precio | fila ( hueco 4 ): `$45` — 17px, bold (700), `$primary` + `/ hora` — 12px, normal, `$text-2` |
| Botón | `Reservar` — fondo `$primary`, radio 10, padding 11/20, texto 14px semibold (600) blanco |

### Datos simulados ( fijos, en orden )

| Foto | Nombre | Tag | Distancia | Rating | Precio |
|---|---|---|---|---|---|
| (1) | `Elite Arena Central` | `5v5` | `1.2 km de vos` | `4.8 (124 reseñas)` | `$45` / hora |
| (2) | `Skyline Sports Hub` | `7v7` | `2.8 km de vos` | `4.6 (89 reseñas)` | `$60` / hora |
| (3) | `Cancha Municipal` | `5v5` | `3.5 km de vos` | `4.9 (210 reseñas)` | `$40` / hora |

## 5. Requerimientos funcionales

### RF-01 — Bloque con la lista

- Muestra la fila de título y las 3 cards del §4 en orden.
- Los datos viven en un modelo local `Cancha` ( nombre, tag, distancia,
  rating, reseñas, precio, foto ) con la lista fija simulada.

### RF-02 — Controles inertes ( por esta etapa )

- Tocar una card, su botón `Reservar` o el link `Ver todo` **no navegan ni
  cambian nada** ( la navegación al Detalle se cablea con su RD ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos del §4 (`es-AR`), incluidos `km de vos`,
  `reseñas`, `/ hora`.
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$surface`, `$border`, `$text`, `$text-2`, `$primary` —
  existentes. El ámbar de la estrella (`#F59E0B`) va literal ( igual que
  otros colores puntuales del mockup, sin token nuevo ).
- **Íconos:** `LucideIcons.mapPin`, `LucideIcons.star` ( instalados ).
- **Assets:** 3 imágenes JPEG en `src/FrontEnd/assets/img/canchas/`,
  declaradas en `pubspec.yaml` ( sin HTTP: son locales ).
- **Plataforma:** móvil, viewport 375×844; se adapta sin romperse.

## 7. Criterios de aceptación

1. Bajo el selector de fecha aparece `Canchas disponibles` + `Ver todo` y
   las 3 cards del §4 en orden, con sus textos exactos.
2. Cada card muestra foto 92×92, nombre, tag ( `5v5`/`7v7` ), distancia con
   pin, rating con estrella ámbar, precio verde + `/ hora` y botón
   `Reservar`.
3. Los tags y precios coinciden con la tabla de datos ( 5v5/$45, 7v7/$60,
   5v5/$40 ).
4. Tocar cards, `Reservar` y `Ver todo` no produce ningún cambio.
5. Las 3 fotos se ven ( assets cargados, sin placeholder ).
6. Sin overflow en 375×844 ni en pantallas chicas ( 320×568 ).

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Datos | Fijos simulados ( las 3 canchas del mockup ) en un modelo `Cancha` local |
| Fotos | **Assets locales** descargadas de las URLs de Unsplash del mockup ( sin HTTP en runtime ); si no se pudieran descargar, fallback: contenedor `$primarySoft` con ícono pelota |
| Card | Estilo del card vectorial de Favoritos ( radio 16, borde, padding 14 ) con el **tag** del PNG en lugar del corazón |
| Card / `Reservar` / `Ver todo` | Inertes: la navegación al Detalle llega con su RD; `Ver todo` no tiene pantalla en el prototipo |
| Filtrado | Fuera de alcance ( RD propio "filtrado del Inicio" ) |
| Estrella | Ámbar `#F59E0B` literal, sin token nuevo |

## 9. Riesgos y notas para la siguiente iteración

- Con el **Detalle de cancha** ( pantalla 02 ), la card y `Reservar`
  navegan pasando la cancha seleccionada.
- Con el **filtrado**, la lista se vuelve derivada de ( texto del buscador,
  día activo, categoría ) sobre el mismo modelo `Cancha`.
- Cuando exista la API REST, `Cancha` se alimenta del backend ( mismos
  campos ) y las fotos pasan a URLs con caché.
