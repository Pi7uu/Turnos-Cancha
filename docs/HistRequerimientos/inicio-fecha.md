# Requerimientos — Selector de fecha del Inicio

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"06 · Inicio · Sin canchas"**, bloque **"Fecha"** ( título + tira de días )
- `docs/prototipos/01 · Inicio.png` ( referencia estática )

---

## 1. Objetivo

Implementar el **selector de fecha de la pantalla Inicio**: el bloque
`Elegí la fecha` con el mes a la derecha y la tira de 5 días
( LUN 14 … VIE 18 ) donde uno está seleccionado. Es la **parte 4 de la
pantalla 01 · Inicio**.

Los días son los **fijos del mockup** ( semana del 14 al 18 de octubre ):
no hay lógica de calendario todavía — llega con la disponibilidad de
canchas.

## 2. Contexto

- La pantalla Inicio ya tiene header y buscador ( RDs `inicio-header.md` y
  `inicio-buscador.md` ) sobre la columna con hueco 16. Este es el tercer
  bloque.
- Los tokens ya existen ( `primarySoft` se reutiliza en el día activo ). Sin
  dependencias nuevas.
- El día seleccionado hoy es solo **estado visual local** de la pantalla: no
  filtra nada ( no hay lista todavía ).

## 3. Alcance

### Dentro del alcance

- Bloque **Fecha** ( §4 ): título + mes + tira de 5 días fijos.
- **Selección de día**: tocar un día lo marca activo y desmarca el anterior
  ( por defecto **MAR 15**, como el mockup ).
- El día activo se conserva al cambiar de tab y volver ( el shell ya
  precarga las pantallas ).

### Fuera de alcance

- Calendario real, cambio de mes, semanas dinámicas ( los días son los del
  mockup ).
- El selector de mes `Octubre ▾` **no navega ni abre nada** ( el prototipo
  no define un picker ).
- Filtrado de canchas por fecha ( llega con la lista — parte 5 ).

## 4. Espec visual ( bloque "Fecha" del mockup )

Tercer bloque de la columna del Inicio ( hueco 16 bajo el buscador ). Bloque
vertical con hueco **10** entre el título y la tira de días:

| Elemento | Especificación |
|---|---|
| Fila título | ancho completo, `spaceBetween`, centrada |
| Título | `Elegí la fecha` — 16px, bold (700), `$text` |
| Mes | fila ( hueco 4, centrada ): `Octubre` — 14px, semibold (600), `$primary` + ícono `chevron-down` (lucide) 15×15 `$primary` |
| Tira de días | fila, hueco **8** entre chips, padding derecho 1; los 5 chips reparten el ancho por igual ( `fill_container` ) |
| Chip día | vertical centrado, hueco 2, padding 9 vertical / 0 horizontal, radio 12, fondo según estado |
| Chip — día ( texto ) | `LUN`/`MAR`/`MIÉ`/`JUE`/`VIE` — 11px, medium (500) |
| Chip — número | `14`…`18` — 17px, semibold (600) |

Estados del chip:

| Estado | Fondo | Día | Número |
|---|---|---|---|
| Inactivo | `$surface` | `$text-2` | `$text` |
| Activo | `$primary` | `$primarySoft` | `#FFFFFF` |

Días fijos ( en orden ): **LUN 14**, **MAR 15** ( activo por defecto ),
**MIÉ 16**, **JUE 17**, **VIE 18**.

## 5. Requerimientos funcionales

### RF-01 — Bloque visual

- Muestra el bloque completo del §4 con MAR 15 activo al entrar.

### RF-02 — Selección de día

- Tocar un chip lo marca activo y desmarca el anterior ( un solo activo ).
- La selección se conserva al cambiar de tab y volver ( estado de la
  pantalla precargada ).
- Tocar el día ya activo lo deja activo ( no hay estado "sin selección" ).

### RF-03 — Controles sin funcionalidad

- `Octubre ▾` es **visual**: no abre calendario ni cambia nada ( el
  prototipo no define picker de mes ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `Elegí la fecha`, `Octubre`, y los días
  `LUN`/`MAR`/`MIÉ`/`JUE`/`VIE` (`es-AR`).
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$text`, `$text-2`, `$primary`, `$primarySoft`, `$surface` —
  todos existentes. Sin tokens nuevos.
- **Ícono:** `LucideIcons.chevronDown` ( ya instalado ).
- **Plataforma:** móvil, viewport 375×844; se adapta sin romperse.
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. Bajo el buscador, con hueco 16, aparece el bloque del §4: título
   `Elegí la fecha`, `Octubre ▾` en verde a la derecha, y los 5 chips
   LUN 14 … VIE 18 repartidos por igual con hueco 8.
2. Al entrar, **MAR 15** está activo ( fondo `$primary`, día `$primarySoft`,
   número blanco ) y los otros 4 en estado inactivo.
3. Tocar `MIÉ 16` lo activa y `MAR 15` vuelve a inactivo; el resto de la
   pantalla no cambia.
4. Volver al Inicio desde otro tab conserva la selección hecha.
5. Tocar `Octubre ▾` no produce ningún cambio.
6. Sin overflow en 375×844 ni en pantallas chicas ( 320×568 ).

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Días | Fijos del mockup ( LUN 14 … VIE 18 ): sin lógica de calendario en esta etapa |
| Selección | Estado local de la pantalla, por defecto MAR 15; se conserva al cambiar de tab |
| Mes `Octubre ▾` | Control visual inerte ( sin picker — el prototipo no lo define ) |
| Día activo sin selección | No existe: siempre hay un día activo ( tocar el activo lo mantiene ) |
| Tipografía | Fuente por defecto si Inter no está configurada ( cláusula de las etapas previas ) |

## 9. Riesgos y notas para la siguiente iteración

- Con la lista de canchas ( parte 5 ), el día activo pasa a ser el criterio
  de disponibilidad: su estado sube al estado compartido del Inicio y se
  conecta al filtrado junto con el buscador.
- Cuando haya calendario real, el bloque de días se vuelve dinámico ( semana
  deslizable ) — sería un RD propio que reemplaza los datos fijos de este.
