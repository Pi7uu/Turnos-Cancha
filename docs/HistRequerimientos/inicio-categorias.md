# Requerimientos — Categorías del Inicio

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"06 · Inicio · Sin canchas"**, bloque **"Categorias Titulo"** ( título + 2 chips en vectores )
- `docs/prototipos/01 · Inicio.png` ( referencia estática )

---

## 1. Objetivo

Implementar el bloque **Categorías de la pantalla Inicio**: el título
`Categorías` y los 2 chips `Fútbol 5` / `Fútbol 7`. Es la **parte 6 de la
pantalla 01 · Inicio** — con este bloque el layout del Inicio queda completo
( solo falta el estado "sin canchas" y el filtrado, que son RDs aparte ).

Por esta etapa los chips son **solo visuales**: no filtran ni navegan.

## 2. Contexto

- La pantalla Inicio ya tiene header, buscador, selector de fecha y la lista
  de canchas ( RDs `inicio-header.md`, `inicio-buscador.md`,
  `inicio-fecha.md`, `inicio-canchas.md` ) sobre la columna scrolleable con
  hueco 16. Este es el quinto y último bloque del layout.
- Los tokens existen ( `primarySoft` se reutiliza en el fondo del ícono ).
  Sin dependencias nuevas.

## 3. Alcance

### Dentro del alcance

- Bloque **Categorías** ( §4 ): título + 2 chips con ícono y label.
- Chips **inertes** ( sin selección ni filtrado — RF-02 ).

### Fuera de alcance

- Filtrado de canchas por categoría ( RD propio "filtrado del Inicio" ).
- Estados de chip seleccionado ( el mockup no los dibuja ).
- Categorías nuevas ( solo `Fútbol 5` y `Fútbol 7` como en el prototipo ).

## 4. Espec visual ( bloque "Categorias Titulo" del mockup )

Quinto bloque de la columna del Inicio ( hueco 16 bajo la lista de canchas ).
Bloque vertical con hueco **10** entre el título y la fila de chips:

| Elemento | Especificación |
|---|---|
| Título | `Categorías` — 17px, bold (700), `$text` |
| Fila de chips | ancho completo, hueco **12**; los 2 chips reparten el ancho por igual ( `fill_container` ) |
| Chip | vertical centrado, hueco 8, padding 18 vertical / 12 horizontal, radio 14, fondo `$surface`, borde `$border` 1px |
| Chip — ícono | caja 44×44, fondo `$primarySoft`, radio 22, centrada: glyph lucide 20×20 `$primary` |
| Chip — label | 14px, semibold (600), `$text` |

Chips ( en orden ):

| Chip | Ícono (lucide) | Label |
|---|---|---|
| 1 | `users` | `Fútbol 5` |
| 2 | `layout-grid` | `Fútbol 7` |

## 5. Requerimientos funcionales

### RF-01 — Bloque visual

- Muestra el título y los 2 chips del §4 con sus íconos y labels.

### RF-02 — Chips inertes

- Tocar un chip **no filtra, no navega ni cambia nada** ( el filtrado por
  categoría llega con su RD ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `Categorías`, `Fútbol 5`, `Fútbol 7` (`es-AR`).
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$surface`, `$border`, `$text`, `$primarySoft`, `$primary` —
  existentes. Sin tokens nuevos.
- **Íconos:** `LucideIcons.users`, `LucideIcons.layoutGrid` ( instalado ).
- **Plataforma:** móvil, viewport 375×844; se adapta sin romperse.
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. Bajo la lista de canchas aparece `Categorías` y, con hueco 12, los 2
   chips repartidos por igual: caja de ícono verde claro con glyph verde y
   label debajo.
2. Los íconos son `users` ( Fútbol 5 ) y `layout-grid` ( Fútbol 7 ), de
   20×20 en la caja de 44×44.
3. Tocar cualquier chip no produce ningún cambio visible ni navegación.
4. El bloque respeta el hueco 16 respecto de la lista de canchas y no
   desborda en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Interactividad | Chips **inertes**: el filtrado por categoría llega con el RD "filtrado del Inicio" |
| Estado seleccionado | No existe ( el mockup no lo dibuja ) |
| Categorías | Solo las 2 del prototipo |
| Tipografía | Fuente por defecto si Inter no está configurada ( cláusula de las etapas previas ) |

## 9. Riesgos y notas para la siguiente iteración

- Con el **filtrado**, los chips pasan a seleccionar categoría ( con estado
  activo nuevo, definido en ese RD ) y la lista se vuelve derivada.
- Con la API REST, las categorías podrían venir del backend; hoy son las 2
  fijas del mockup.
