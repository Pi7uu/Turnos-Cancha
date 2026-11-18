# Requerimientos — Detalle de cancha · horarios y barra de reserva ( pantalla 02, parte 3 )

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"07 · Detalle · Comodidades no disponibles"**, bloque **"Horarios"** y **"Footer"**
- `docs/prototipos/02 · Detalle de cancha.png` ( referencia estática )

---

## 1. Objetivo

Implementar la **parte 3 — y última del layout — de la pantalla Detalle de
cancha**: el bloque `Elegí el horario` ( 6 slots con estados y selección )
y la **barra fija inferior** con `PRECIO TOTAL` y el botón
`Confirmar reserva`.

Con esto la pantalla 02 queda **completa en layout y selección**; solo falta
el flujo de reserva ( éxito / error — RDs siguientes, donde `Confirmar
reserva` cobrará vida ).

## 2. Contexto

- El Detalle ya tiene hero + info + comodidades + descripción ( RDs
  `detalle-hero.md`, `detalle-comodidades.md` ). El bloque de horarios va
  **debajo de "Sobre esta cancha"** ( hueco 16 ) y la barra de reserva queda
  **fija abajo** ( como el Footer del mockup y la tab bar del shell ).
- El botón `Confirmar reserva` queda **inerte** en esta parte ( RF-03 ): el
  flujo de reserva lo cablea su RD.
- La **fecha** que muestra el bloque ( `Mar, 15 oct` ) refleja el día
  seleccionado en el Inicio: `DetalleScreen` recibe ese label como parámetro
  ( §8 ).

## 3. Alcance

### Dentro del alcance

- Bloque **Elegí el horario** ( §4 ): título + fecha + 6 slots ( 2 filas de
  3 ) con estados disponible / seleccionado / ocupado.
- **Selección de horario**: tocar un slot disponible lo marca y desmarca el
  anterior; los ocupados no son tappable.
- **Barra de reserva fija** ( §4 ): `PRECIO TOTAL` + monto + botón
  `Confirmar reserva` ( inerte ).
- Campo nuevo `horasOcupadas` en `Cancha` + parámetro `fecha` en
  `DetalleScreen` ( §4/§8 ).

### Fuera de alcance

- El **flujo de reserva**: `Confirmar reserva` no navega ni registra nada
  ( RD "reserva exitosa" / "error de reserva" lo cablean ).
- Disponibilidad real por fecha/hora ( los ocupados son data fija simulada ).
- Cálculo de precios, descuentos o duración.

## 4. Espec visual ( bloques "Horarios" y "Footer" del mockup )

### Bloque "Elegí el horario" ( hueco 16 bajo "Sobre esta cancha" )

Bloque vertical con hueco **12**:

| Elemento | Especificación |
|---|---|
| Fila título | `spaceBetween`, centrada: `Elegí el horario` — 17px bold (700) `$text` + fecha `Mar, 15 oct` — 13px normal `$text-2` |
| Filas de slots | 2 filas de **3 slots** ( hueco 10 entre slots, reparto igual `fill_container` ) |
| Slot | `Container` radio 10, padding 13 vertical / 0 horizontal, centrado: hora — 15px semibold (600) |

Estados del slot:

| Estado | Fondo | Hora |
|---|---|---|
| Disponible | `$surface` | `$text-2` |
| Seleccionado | `$primary` | `#FFFFFF` |
| Ocupado | `#F1F5F9` | `$text-2` con opacidad **0.5** |

Horas ( en orden ): **17:00, 18:00, 19:00** ( fila 1 ) / **20:00, 21:00,
22:00** ( fila 2 ). En el mockup ( Elite, Mar 15 ): `19:00` seleccionado y
`21:00` ocupado.

### Barra de reserva fija ( "Footer" del mockup )

Fija al borde inferior de la pantalla ( `bottomNavigationBar` del
`Scaffold`, como la tab bar del shell ):

| Propiedad | Valor |
|---|---|
| Barra | fondo `$surface`, borde superior `$border` 1px, padding 16 vertical / 20 horizontal, `spaceBetween`, centrada |
| Total ( columna, hueco 2 ) | `PRECIO TOTAL` — 11px semibold (600), `letterSpacing` 1, `$text-2` + monto `$45.00` — 24px bold (700), `$text` |
| Botón `Confirmar reserva` | fondo `$primary`, radio 12, padding 15/22, fila ( hueco 8 ): texto 15px semibold (600) blanco + `arrow-right` (lucide) 16×16 blanco |

Monto = `cancha.precio` + `.00` ( el mockup pasa de `$45` a `$45.00` ).

### Datos simulados

| Cancha | `horasOcupadas` | Seleccionado por defecto |
|---|---|---|
| Elite Arena Central | `['21:00']` ( mockup ) | `19:00` |
| Skyline Sports Hub | `['17:00', '21:00']` ( inventado ) | `19:00` |
| Cancha Municipal | `['20:00']` ( inventado ) | `19:00` |

Fecha del bloque: derivada del **día seleccionado en el Inicio**
( `Lun, 14 oct` … `Vie, 18 oct` ); `DetalleScreen` la recibe por parámetro
`fecha` ( default `Mar, 15 oct` = mockup ).

## 5. Requerimientos funcionales

### RF-01 — Bloque de horarios

- Muestra el título, la fecha recibida y los 6 slots en orden, cada uno en
  su estado según `horasOcupadas` ( §4 ) con `19:00` seleccionado al entrar.

### RF-02 — Selección de horario

- Tocar un slot **disponible** lo marca ( verde ) y desmarca el anterior
  ( un solo seleccionado ). Tocar el seleccionado lo mantiene.
- Los slots **ocupados no son tappable** ( sin efecto ).
- El monto de la barra no cambia con la selección ( el precio es por hora
  fijo en el mockup ).

### RF-03 — Barra de reserva

- La barra muestra `PRECIO TOTAL` y el monto de la cancha ( §4 ).
- `Confirmar reserva` es **inerte** ( el flujo de reserva lo cablea su RD ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `Elegí el horario`, `PRECIO TOTAL`,
  `Confirmar reserva` (`es-AR`); horas `17:00`…`22:00`; fecha `Mar, 15 oct`.
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$surface`, `$text`, `$text-2`, `$primary`, `$border` —
  existentes; `#F1F5F9` ( slot ocupado ) literal ( como en comodidades ).
- **Ícono:** `LucideIcons.arrowRight` ( instalado ).
- **Plataforma:** móvil, 375×844; sin overflow en 320×568. La barra fija no
  tapa el contenido ( el scroll lleva padding inferior equivalente ).
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. Bajo `Sobre esta cancha` aparece `Elegí el horario` + la fecha del día
   seleccionado del Inicio ( ej: elegir MIÉ en el Inicio → `Mié, 16 oct` ).
2. Los 6 slots están en sus filas con `19:00` seleccionado ( verde, hora
   blanca ) y `21:00` ocupado ( gris, hora atenuada ) en Elite.
3. Tocar `20:00` lo selecciona y `19:00` vuelve a disponible; tocar `21:00`
   ( ocupado ) no cambia nada.
4. La barra fija muestra `PRECIO TOTAL` y `$45.00` en Elite ( `$60.00` en
   Skyline, `$40.00` en Municipal ) con el botón `Confirmar reserva` y su
   flecha.
5. Tocar `Confirmar reserva` no produce ningún cambio.
6. El contenido scrolleable termina visible ( la barra no tapa el último
   bloque ) y no hay overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Selección | Estado local del Detalle, default `19:00` ( mockup ); ocupados no tappable |
| Fecha del bloque | **Parámetro `fecha` de `DetalleScreen`** ( default `Mar, 15 oct` ) derivado del día seleccionado del Inicio ( `Lun, 14 oct`… ); la conexión se hace en este RD |
| Horas ocupadas | Campo `horasOcupadas` en `Cancha` ( data fija simulada; Elite la del mockup, las otras inventadas ) |
| Monto | `cancha.precio + '.00'` ( `$45` → `$45.00`, como el mockup ); no cambia con la selección |
| `Confirmar reserva` | **Inerte** hasta el RD del flujo de reserva ( RF-03 ) |
| Barra fija | `bottomNavigationBar` del Scaffold ( mismo patrón que la tab bar del shell ) con el scroll con padding inferior |

## 9. Riesgos y notas para la siguiente iteración

- El **flujo de reserva** ( éxito `¡Reserva exitosa!` + error ) cablea
  `Confirmar reserva` y usa el horario seleccionado: el estado de selección
  deberá subir o pasarse al flujo ( RD "reserva" ).
- Con disponibilidad real, `horasOcupadas` se calcula por fecha desde el
  backend y el default de selección podría ser "ninguno".
- Si el precio por hora varía por horario, el monto pasa a derivarse de la
  selección ( hoy es fijo, como el mockup ).
