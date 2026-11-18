# Requerimientos — Detalle de cancha · comodidades y descripción ( pantalla 02, parte 2 )

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"07 · Detalle · Comodidades no disponibles"**, bloques **"Comodidades"** ( con la variante de no disponibles + aviso ) y **"Sobre"**
- `docs/prototipos/02 · Detalle de cancha.png` ( estado base: las 5 comodidades disponibles y sin aviso )

---

## 1. Objetivo

Implementar la **parte 2 de la pantalla Detalle de cancha**: el bloque
`Comodidades` ( 5 chips con estados disponible/no disponible + aviso cuando
hay no disponibles ) y el bloque `Sobre esta cancha` ( descripción ).

Con esto, salvo los horarios y la barra de reserva, el Detalle queda
completo.

## 2. Contexto

- El Detalle ya tiene hero + info ( RD `detalle-hero.md` ). Estos bloques van
  **debajo del nombre/dirección**, con el mismo hueco 16 del content.
- El mockup define **dos estados** en el mismo frame 07: disponible ( círculo
  blanco, ícono oscuro ) y no disponible ( círculo gris, ícono y label
  atenuados ), más un **aviso** ámbar con los servicios faltantes. El estado
  base ( PNG 02 ) muestra las 5 disponibles y sin aviso.
- Los datos nuevos de `Cancha` ( §4 ): `comodidadesNoDisponibles` y
  `descripcion`.

## 3. Alcance

### Dentro del alcance

- Bloque **Comodidades** ( §4 ): título + 5 chips ( Duchas, Estac., Aire
  a/c, Agua, WiFi ) con estado por cancha + **aviso** ámbar cuando hay no
  disponibles.
- Bloque **Sobre esta cancha** ( §4 ): título + párrafo.
- Datos simulados en `Cancha` ( §4 ).

### Fuera de alcance

- Selector de horarios y barra `Precio total / Confirmar reserva` ( parte 3 ).
- Interacción en los chips ( son indicadores, no filtros ).
- Nuevas comodidades fuera de las 5 del mockup.

## 4. Espec visual

### Bloque "Comodidades" ( del mockup — hueco 16 bajo dirección )

Bloque vertical con hueco **12**:

| Elemento | Especificación |
|---|---|
| Título | `Comodidades` — 17px, bold (700), `$text` |
| Lista | ancho completo, padding horizontal **6**, `spaceBetween` ( 5 ítems ) |
| Ítem | vertical centrado, hueco 6 |
| Ítem — círculo | 48×48, radio 24, centrado: glyph lucide **21×21** |
| Ítem — label | 11px, medium (500), `$text-2` |

Estados del ítem:

| Estado | Círculo | Glyph | Label |
|---|---|---|---|
| Disponible | `$surface` | `$text` | `$text-2` |
| No disponible | `#F1F5F9` | `$text-2` con opacidad **0.45** | `$text-2` con opacidad **0.5** |

Ítems ( en orden fijo ): **Duchas** (`shower-head`), **Estac.**
(`square-parking`), **Aire a/c** (`snowflake`), **Agua** (`droplet`),
**WiFi** (`wifi`).

**Aviso** ( solo si hay no disponibles ): fila ( hueco 6, centrada ): ícono
`info` (lucide) 14×14 ámbar `#F59E0B` + texto 12px medium (500) ámbar —
`Estacionamiento y WiFi no disponibles hoy` ( nombres completos de los
servicios faltantes, unidos con ` y `, seguidos de ` no disponibles hoy` ).

### Bloque "Sobre esta cancha" ( hueco 16 bajo Comodidades )

Bloque vertical con hueco **8**:

| Elemento | Especificación |
|---|---|
| Título | `Sobre esta cancha` — 17px, bold (700), `$text` |
| Párrafo | 14px, normal, `$text-2`, interlineado **1.55**, envuelve en varias líneas |

### Datos simulados ( campos nuevos de `Cancha` )

| Cancha | `comodidadesNoDisponibles` | `descripcion` |
|---|---|---|
| Elite Arena Central | `[]` ( las 5 disponibles, sin aviso ) | `Césped sintético de grado profesional, iluminación LED de alta intensidad para partidos nocturnos y vestuarios con aire acondicionado. Perfecto para quinta con amigos o torneos competitivos.` ( texto del mockup ) |
| Skyline Sports Hub | `['Estac.', 'WiFi']` ( variante del mockup, con aviso ) | `Cancha techada de última generación, ideal para partidos nocturnos y torneos corporativos. Vestuarios amplios y acceso controlado.` ( inventado ) |
| Cancha Municipal | `[]` | `Cancha al aire libre en el corazón de la ciudad, con césped renovado y fácil acceso en transporte público. Ideal para partidos con amigos.` ( inventado ) |

## 5. Requerimientos funcionales

### RF-01 — Bloque Comodidades

- Muestra los 5 ítems en orden fijo, cada uno en su estado según la cancha
  ( §4 ): Elite y Municipal con las 5 disponibles; Skyline con `Estac.` y
  `WiFi` no disponibles ( círculo gris, atenuados ).
- El **aviso** aparece solo cuando hay no disponibles, con el texto
  generado ( §4 ): `Estacionamiento y WiFi no disponibles hoy` en Skyline;
  ninguno en Elite/Municipal.

### RF-02 — Bloque Sobre esta cancha

- Muestra el título y el párrafo de la cancha recibida, con wrap de varias
  líneas.

### RF-03 — Sin interacción

- Los chips de comodidades no son tappable ( indicadores visuales ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `Comodidades`, `Sobre esta cancha`, labels
  `Duchas`/`Estac.`/`Aire a/c`/`Agua`/`WiFi`, aviso `... no disponibles hoy`
  (`es-AR`).
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$surface`, `$text`, `$text-2` — existentes; `#F1F5F9` (
  círculo no disponible ) y ámbar `#F59E0B` literales ( como el ámbar del
  rating ). Sin tokens nuevos.
- **Íconos:** `shower-head`, `square-parking`, `snowflake`, `droplet`,
  `wifi`, `info` ( lucide ).
- **Plataforma:** móvil, 375×844; sin overflow en 320×568.
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. En el Detalle de **Elite** aparecen `Comodidades` con los 5 ítems
   ( círculos blancos, íconos oscuros, labels grises ) y **sin aviso**, y
   debajo `Sobre esta cancha` con el párrafo del mockup.
2. En el Detalle de **Skyline**, `Estac.` y `WiFi` muestran el estado no
   disponible ( círculo `#F1F5F9`, ícono y label atenuados ) y aparece el
   aviso `Estacionamiento y WiFi no disponibles hoy` con ícono `info` ámbar.
3. En **Municipal** las 5 comodidades están disponibles y no hay aviso.
4. El párrafo envuelve en varias líneas con interlineado 1.55.
5. Los ítems de comodidades no reaccionan al tap.
6. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Estados | Los 5 ítems fijos del mockup; estado por cancha vía `comodidadesNoDisponibles` ( lista de labels exactos ) |
| Variante del mockup | Asignada a **Skyline** ( `Estac.` y `WiFi` no disponibles ): el frame 07 no nombra la cancha; Elite queda con el estado base del PNG |
| Texto del aviso | Generado: nombres completos ( `Estac.` → `Estacionamiento`, el resto como label ) unidos con ` y ` + ` no disponibles hoy` |
| Descripciones | Elite usa el texto del mockup; Skyline y Municipal inventados ( el mockup solo define el de Elite ) |
| Interacción | Los chips son indicadores, no tappable |
| Colores literales | `#F1F5F9` ( círculo no disponible ) y ámbar `#F59E0B` sin token |

## 9. Riesgos y notas para la siguiente iteración

- **Parte 3** ( `Elegí el horario` + barra `Precio total / Confirmar
  reserva` ) cierra la pantalla y desencadena el flujo de reserva.
- Con la API REST, `comodidadesNoDisponibles` vendrá del backend ( hoy es
  data fija ); el aviso se regenera igual.
- La variante "comodidades no disponibles" del mockup queda cubierta por los
  datos de Skyline ( no hace falta una pantalla aparte ).
