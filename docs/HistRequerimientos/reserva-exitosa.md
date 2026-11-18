# Requerimientos — Reserva exitosa ( pantalla "Contenido" )

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/Contenido.png` — pantalla **¡Reserva exitosa!** ( única fuente: en el `.pen` existe solo como imagen de referencia `Ref · Contenido.png` — sin vectores )

---

## 1. Objetivo

Implementar la pantalla **¡Reserva exitosa!**: la confirmación que ve el
usuario al tocar `Confirmar reserva` en el Detalle, con el resumen de la
reserva ( N° de orden, estado de pago, precio ) y sus dos botones.

Con esto **el flujo central de la app queda vivo de punta a punta**:
elegir cancha → ver detalle → elegir horario → reservar → confirmación.

## 2. Contexto

- Es una pantalla **apilada** que se abre desde `Confirmar reserva` ( hoy
  inerte — este RD lo cablea ) pasando la cancha, la fecha y el horario
  seleccionado del Detalle.
- El prototipo muestra un **N° de orden** ( `#GB-882910` ) y el estado de
  pago `PAGADO`: son datos **simulados** ( no hay backend ni persistencia
  de reservas todavía ).
- La pantalla de **error de reserva** ( frame 10 del `.pen` ) es el RD
  siguiente: definirá cuándo se muestra cada una.

## 3. Alcance

### Dentro del alcance

- Pantalla **ReservaExitosaScreen** ( §4 ) con datos de la reserva recibida.
- **`Confirmar reserva` del Detalle la abre** ( fin de la inercia del RD
  `detalle-horarios.md` RF-03 ) con cancha + fecha + hora + precio.
- Botones reales: **`Volver al inicio`** ( regresa al shell conservando su
  estado ) y **`Ver mis reservas`** ( regresa al shell con el tab **Mis
  reservas** activo — `MainShell` gana el parámetro `tabInicial` ).
- **N° de orden generado** por reserva ( formato del mockup ).

### Fuera de alcance

- La pantalla de **error de reserva** ( frame 10 — RD siguiente ).
- Persistencia de reservas ( nada se guarda; al reiniciar la app no queda
  registro ) ni "Mis reservas" real ( su pantalla es placeholder todavía ).
- Comprobante, cancelación o reprogramación.

## 4. Espec visual ( pantalla `Contenido.png` — medidas derivadas del PNG )

Pantalla 375×844 sobre fondo `$bg`, columna centrada con padding 24 lados:

| Elemento | Especificación |
|---|---|
| Ilustración | círculo verde `$primary` de ≈130 con `check` blanco ≈56 centrado, y 2 puntitos decorativos ( ámbar `#F59E0B` arriba-derecha, azul `#3B82F6` izquierda ) — decoración simplificada del mockup |
| Título | `¡Reserva exitosa!` — 24px, bold (700), `$text`, centrado |
| Descripción | `Tu cancha <nombre> quedó reservada para el <día> de octubre a las <hora>.` — 15px, `$text-2`, centrado, hueco 16 |
| Card | fondo `$surface`, radio 16, borde `$border` 1px, padding 20, vertical ( hueco 16 ), `spaceBetween` por fila: |
| — Fila 1 | `N° DE ORDEN` ( 11px w600 `letterSpacing` 1 `$text-2` ) + `#GB-882910` ( 15px w600 `$text` ) |
| — Fila 2 | `ESTADO DE PAGO` ( mismo estilo ) + píldora `PAGADO` ( fondo `$primarySoft`, radio 8, padding 4/9, texto 11px w600 `$primary` ) |
| — Fila 3 | `PRECIO TOTAL` ( mismo estilo ) + `$45.00` ( 20px bold (700) `$primary`, alineado a la derecha ) |
| Aviso | `Te enviamos la confirmación a tu email registrado.` — 13px, `$text-2`, centrado, hueco 16 |
| Botón primario | `Ver mis reservas` — ancho completo, `$primary`, radio 12, texto 15px w600 blanco |
| Botón secundario | `Volver al inicio` — ancho completo, `$surface`, borde `$border` 1px, radio 12, texto 15px w600 `$text` |

## 5. Requerimientos funcionales

### RF-01 — Pantalla con datos de la reserva

- Muestra la ilustración, `¡Reserva exitosa!`, la descripción con el
  **nombre de la cancha**, el **día** ( `15 de octubre` ) y la **hora**
  elegida, la card con **N° de orden generado**, `PAGADO` y el **precio**
  ( `cancha.precio + '.00'` ), y el aviso del email.

### RF-02 — Navegación

- **`Ver mis reservas`**: abre el shell con el tab **Mis reservas** activo
  ( `MainShell(tabInicial: TabApp.misReservas)` con
  `pushAndRemoveUntil`; hoy ese tab es placeholder — su RD lo llena ).
- **`Volver al inicio`**: regresa al shell conservando su estado
  ( `popUntil` a la primera ruta: buscador, día y scroll intactos ).
- **`Confirmar reserva`** del Detalle abre esta pantalla ( cierra el RF-03
  del RD `detalle-horarios.md` ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `¡Reserva exitosa!`, `N° DE ORDEN`,
  `ESTADO DE PAGO`, `PAGADO`, `PRECIO TOTAL`,
  `Te enviamos la confirmación a tu email registrado.`, `Ver mis reservas`,
  `Volver al inicio` (`es-AR`); frase `Tu cancha ... quedó reservada para el
  ... de octubre a las ....`
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$bg`, `$surface`, `$border`, `$text`, `$text-2`, `$primary`,
  `$primarySoft` — existentes; ámbar `#F59E0B` y azul `#3B82F6` literales (
  decoración del mockup ). Sin tokens nuevos.
- **Ícono:** `LucideIcons.check` ( instalado ).
- **Plataforma:** móvil, 375×844; sin overflow en 320×568 ( columna
  scrolleable ).
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. En el Detalle de Skyline con horario `20:00` y día `Mié, 16 oct`, tocar
   `Confirmar reserva` abre `¡Reserva exitosa!` con
   `Tu cancha Skyline Sports Hub quedó reservada para el 16 de octubre a las
   20:00.`
2. La card muestra `N° DE ORDEN` con un código `#GB-######` ( 6 dígitos ),
   `ESTADO DE PAGO` `PAGADO` en píldora verde y `PRECIO TOTAL` `$60.00` (
   el precio de Skyline ).
3. `Ver mis reservas` lleva al shell con el tab Mis reservas activo ( pill
   verde en ese tab ) — hoy muestra su placeholder.
4. `Volver al inicio` regresa al shell con el tab Inicio y **el estado del
   Inicio conservado** ( buscador, día y scroll ).
5. El N° de orden **cambia entre reservas** ( generado, no fijo ).
6. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| `Confirmar reserva` | Se **cablea** en este RD ( cierra el RF-03 de `detalle-horarios.md` ): pasa cancha, fecha y hora al abrir la pantalla |
| N° de orden | **Generado** por reserva: `#GB-` + 6 dígitos aleatorios ( formato del mockup ) — distinto en cada reserva |
| Datos simulados | `PAGADO` fijo; sin persistencia ni backend ( la pantalla de error definirá cuándo no hay éxito ) |
| `Ver mis reservas` | `pushAndRemoveUntil(MainShell(tabInicial: TabApp.misReservas))` — `MainShell` gana el parámetro `tabInicial` ( el tab Mis reservas sigue siendo placeholder hasta su RD ) |
| `Volver al inicio` | `popUntil` a la primera ruta: conserva el estado del shell ( como el Volver del hero ) |
| Ilustración | Círculo verde + check + 2 puntos decorativos ( simplificación del PNG; sin imágenes ) |
| Fila del precio | Monto a la derecha en verde ( `$45.00` con `.00`, igual que la barra del Detalle ) |

## 9. Riesgos y notas para la siguiente iteración

- La **pantalla de error de reserva** ( frame 10 del `.pen` ) es el RD
  siguiente: definirá la condición de éxito/error ( hoy siempre hay éxito ).
- Con **Mis reservas** real, `Ver mis reservas` mostrará la reserva creada
  ( que hoy solo vive en esta pantalla ).
- Con la API REST, el N° de orden y el estado de pago vendrán del backend.
