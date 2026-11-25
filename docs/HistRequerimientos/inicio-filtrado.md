# Requerimientos — Inicio · filtrado y estado "sin canchas" ( pantalla 01, cierre )

**Fecha:** 2026-11-25
**Estado:** Listo para implementar ( ciclo autónomo: sin aprobación intermedia )
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"06 · Inicio · Sin canchas"** ( vectores, id `WMKLh` )

---

## 1. Objetivo

Completar el Inicio con el **filtrado real** ( buscador + categorías ) y el
estado **"sin canchas"** del frame 06. Con esto **el prototipo queda
completo**.

## 2. Contexto

- El Inicio tiene buscador, selector de fecha, lista de canchas y categorías
  — todos los filtros están **inertes** ( RDs inicio-* ).
- El frame 06 muestra el Inicio con la lista reemplazada por la card
  `No hay canchas disponibles` ( cuando no hay resultados ).

## 3. Alcance

### Dentro del alcance

- **Buscador filtra** ( RF-01 ): el texto filtra las canchas por **nombre**
  ( coincide parcial, sin distinguir mayúsculas ), en vivo mientras se escribe.
- **Categorías filtran** ( RF-02 ): los chips `Fútbol 5` / `Fútbol 7` filtran
  por `tag` ( 5v5 / 7v7 ); tocar el chip activo lo deselecciona ( muestra
  todas ). Filtros combinables ( buscador Y categoría ).
- **Estado "sin canchas"** ( RF-03, frame 06 ): sin resultados → la card del
  frame 06 con `Elegir otra fecha` ( limpia los filtros y muestra todas ).
- **`Ver todo`** ( RF-04 ): limpia los filtros ( buscador + categoría ) y
  muestra las 3 canchas.

### Fuera de alcance

- Filtrado por **fecha** ( los datos simulados no varían por día; el texto
  del frame 06 menciona la fecha porque en el mockup el estado lo produce el
  día — aquí lo producen los filtros, decisión §8 ).
- Autocompletado, búsqueda por dirección, ordenamiento.

## 4. Espec visual ( frame 06 )

Todo el Inicio es igual que hoy **salvo** la lista de canchas, que se
reemplaza por la card `Sin canchas` cuando no hay resultados:

| Elemento | Especificación |
|---|---|
| Card | `$surface`, radio 16, borde `$border` 1px, vertical, hueco 14, padding 30/24, centrado |
| Ícono | círculo 76×76 `$primarySoft` radio 38, centrado: `calendar-x` (lucide) 36×36 `$primary` |
| Título | `No hay canchas disponibles` — 17px w700 `$text`, centrado |
| Descripción | `No quedan canchas libres para esta fecha en tu zona. Probá con otro día.` — 14px normal `$text-2`, interlineado **1.5**, centrada ( ancho fill ) |
| Botón | `Elegir otra fecha` — `$primary`, radio 12, padding 13/26, texto 15px w600 blanco |

El bloque `Categorías` sigue debajo ( igual que hoy ). El buscador, el
selector de fecha y el header no cambian.

## 5. Requerimientos funcionales

### RF-01 — Buscador filtra

- El texto del buscador filtra la lista `Canchas disponibles` por nombre
  ( `contains` sin distinguir mayúsculas ) mientras se escribe.
- Borrar el texto muestra todas ( según el filtro de categoría activo ).

### RF-02 — Categorías filtran

- `Fútbol 5` muestra las canchas con `tag == '5v5'`; `Fútbol 7` las de
  `'7v7'`. Tocar el chip activo lo deselecciona.
- Los filtros se combinan con el del buscador ( Y lógico ).

### RF-03 — Estado "sin canchas" ( frame 06 )

- Sin resultados → la card de §4 en lugar de la lista.
- **`Elegir otra fecha`** limpia los filtros ( buscador + categoría ) y
  muestra las 3 canchas de nuevo.

### RF-04 — Ver todo

- `Ver todo` limpia los filtros y muestra las 3 canchas.

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos de §4 (`es-AR`).
- **Tokens:** existentes. **Ícono:** `LucideIcons.calendarX` ( librería
  instalada — verificar nombre ).
- **Plataforma:** móvil 375×844; sin overflow en 320×568.
- **Sin red**; datos simulados.

## 7. Criterios de aceptación

1. Escribir `elite` en el buscador deja solo la card de Elite Arena Central;
   escribir `xyz` muestra la card `No hay canchas disponibles`.
2. Tocar `Fútbol 7` muestra solo Skyline Sports Hub ( 7v7 ); con buscador
   `sky` + `Fútbol 5` activo no hay resultados → estado sin canchas.
3. Tocar de nuevo el chip activo lo deselecciona y vuelve la lista completa.
4. `Elegir otra fecha` ( desde el estado sin canchas ) y `Ver todo` limpian
   los filtros y muestran las 3 canchas.
5. El estado sin canchas muestra `No hay canchas disponibles`, la descripción
   y `Elegir otra fecha` con la geometría de §4.
6. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Qué produce el estado vacío | Los filtros ( buscador/categoría ) — no la fecha, porque los datos simulados no varían por día; el texto del mockup se usa igual |
| `Elegir otra fecha` | Limpia los filtros ( mismo efecto que `Ver todo` ) — no cambia el día, porque el estado no lo produce la fecha |
| Filtro de nombre | `contains` case-insensitive sobre `cancha.nombre` |
| Categoría | Mapeo chip → `tag`: `Fútbol 5` → `5v5`, `Fútbol 7` → `7v7`; chip activo se deselecciona al tocarlo |
| Fecha | El selector de fecha **no filtra** ( sigue como hasta ahora ) |

## 9. Riesgos y notas para la siguiente iteración

- Con backend, el filtrado se manda a la API ( disponibilidad real por fecha
  y zona ) y el estado vacío aparece por fecha real.
- Con esto el prototipo queda completo; lo siguiente es la **fase backend**.
