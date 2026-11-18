# Requerimientos — Detalle de cancha · hero e info ( pantalla 02, parte 1 )

**Fecha:** 2026-11-17
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"07 · Detalle · Comodidades no disponibles"**, bloques **"Hero"** y los primeros de **"Content"** ( Precio Rating, Nombre, Direccion )
- `docs/prototipos/02 · Detalle de cancha.png` ( referencia estática )

---

## 1. Objetivo

Implementar la **parte 1 de la pantalla Detalle de cancha** ( 02 ): el hero
con foto y botones ( volver, compartir, favorito ), la fila de badge/rating/
precio, el nombre y la dirección — y la **navegación desde el Inicio**: tocar
una card o su botón `Reservar` abre esta pantalla con la cancha elegida.

Es la primera parte del flujo central del proyecto ( reservar ).

## 2. Contexto

- Es una **pantalla apilada** ( se empuja desde el Inicio, sin tab bar ) con
  botón **Volver** que hace `pop` — como las pantallas 02/10 del prototipo.
- Los datos vienen de la `Cancha` seleccionada ( modelo del RD
  `inicio-canchas.md` ), que se **amplía** con los campos que el Detalle
  necesita ( §8 ): `direccion`, `puntuacion`, `premium`, `hero`.
- Las cards del Inicio y su botón `Reservar` eran inertes ( RD
  `inicio-canchas.md` RF-02 ): este RD **cambia ese alcance** y los cablea al
  Detalle ( §8 ).

## 3. Alcance

### Dentro del alcance

- Pantalla **Detalle** ( `DetalleScreen` ) con hero + info + nombre +
  dirección ( §4 ).
- **Navegación**: card del Inicio y su `Reservar` → Detalle con esa cancha;
  botón **Volver** → `pop`.
- Campos nuevos en `Cancha` ( `direccion`, `puntuacion`, `premium`, `hero` )
  con datos simulados ( §4 ).

### Fuera de alcance

- Comodidades y "Sobre esta cancha" ( parte 2 del Detalle ).
- Selector de horarios y barra "Precio total / Confirmar reserva" ( parte 3 ).
- Botones **Favorito** y **Compartir** del hero: **inertes** ( el prototipo
  no define pantallas destino; Favoritos se cablea con su RD ).
- Estado de la cancha "con comodidades no disponibles" ( variante 07 — RD
  aparte de la parte 2 ).

## 4. Espec visual ( bloques "Hero" + primeros de "Content" del mockup )

Pantalla 375×844. La status bar del sistema queda sobre el hero.

### Hero

Imagen a todo el ancho, alto **240** ( `fit: cover` ). Botones flotantes
( círculos 40×40, fondo `$surface`, radio 20, sombra `#0F172A26` offset
(0, 2) blur 8, ícono lucide 19×19 `$text` ):

| Botón | Posición ( dentro del hero ) | Ícono |
|---|---|---|
| Volver | (16, 16) | `chevron-left` |
| Compartir | (269, 16) | `share-2` |
| Favorito | (319, 16) | `heart` |

### Content ( padding 18 arriba / 16 lados / 24 abajo, hueco 16 entre bloques )

| Elemento | Especificación |
|---|---|
| Fila precio/rating | ancho completo, `spaceBetween`, centrada |
| — Izquierda ( hueco 10 ) | badge **`PREMIUM`**: fondo `$primary`, radio 6, padding 5/9, texto 10px bold (700) blanco, `letterSpacing` 0.8 + rating ( hueco 4 ): estrella `star` (lucide) 15×15 ámbar `#F59E0B` + valor `4.8` — 14px semibold (600) `$text` |
| — Precio ( columna, alineada a la derecha ) | monto `$45` — 22px bold (700) `$primary` + `por hora` — 11px normal `$text-2` |
| Nombre | `Elite Arena Central` — 24px, bold (700), `$text` |
| Dirección | fila ( hueco 6 ): `map-pin` (lucide) 16×16 `$text-2` + `Av. de los Deportes 123, Centro` — 14px normal `$text-2` |

### Datos simulados ( campos nuevos de `Cancha` )

| Cancha | `direccion` | `puntuacion` | `premium` | `hero` |
|---|---|---|---|---|
| Elite Arena Central | `Av. de los Deportes 123, Centro` | 4.8 | true | foto hero del mockup ( asset nuevo ) |
| Skyline Sports Hub | `Av. del Parque 789, Oeste` | 4.6 | true | su foto actual |
| Cancha Municipal | `Calle San Martín 45, Centro` | 4.9 | false | su foto actual |

## 5. Requerimientos funcionales

### RF-01 — Pantalla Detalle

- Muestra hero + bloque precio/rating + nombre + dirección con los datos de
  la cancha recibida ( §4 ).

### RF-02 — Navegación desde el Inicio

- Tocar una **card** del Inicio o su botón **`Reservar`** empuja
  `DetalleScreen` con esa cancha ( reemplaza la inercia del RD
  `inicio-canchas.md` RF-02 ).
- El botón **Volver** del hero hace `pop` y regresa al Inicio ( que
  conserva su estado: buscador, día, scroll ).
- `Ver todo` **sigue inerte** ( sin pantalla ).

### RF-03 — Controles inertes del hero

- **Favorito** y **Compartir** no hacen nada ( sin pantallas destino ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos `PREMIUM`, `por hora` (`es-AR`); datos de la
  tabla §4.
- **Tipografía:** Inter ( o la fuente por defecto si no está configurada —
  misma cláusula que las etapas previas ).
- **Tokens:** `$surface`, `$text`, `$text-2`, `$primary` — existentes;
  ámbar `#F59E0B` literal ( como el rating de las cards ). Sin tokens nuevos.
- **Íconos:** `LucideIcons.chevronLeft`, `share2`, `heart`, `star`, `mapPin`.
- **Assets:** la foto hero del mockup ( Unsplash, metadatos del `.pen` ) se
  agrega a `assets/img/canchas/`; las otras 2 canchas usan su foto actual.
- **Plataforma:** móvil, 375×844; sin overflow en pantallas chicas.
- **Sin red:** ninguna llamada HTTP; nada se persiste.

## 7. Criterios de aceptación

1. Tocar la card de `Skyline Sports Hub` ( o su `Reservar` ) abre el Detalle
   con su foto de hero, `PREMIUM`, `4.6`, `$60`, `por hora`, nombre y su
   dirección.
2. El hero mide 240 de alto con los 3 botones circulares blancos en sus
   posiciones ( volver a la izquierda; compartir y favorito a la derecha ).
3. La fila de precio/rating respeta el §4 ( badge `PREMIUM`, estrella ámbar,
   monto 22 verde + `por hora` 11 gris; el badge **no aparece** en
   `Cancha Municipal` porque `premium` es false ).
4. **Volver** regresa al Inicio conservando su estado ( buscador, día
   seleccionado, posición de scroll ).
5. Tocar **Favorito** y **Compartir** no produce ningún cambio.
6. `Ver todo` sigue sin funcionalidad.
7. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Navegación | Cards y `Reservar` del Inicio **abren el Detalle** ( modifica el RF-02 del RD `inicio-canchas.md`, que decía "inertes hasta el RD del Detalle" ) |
| Modelo `Cancha` | + 4 campos ( `direccion`, `puntuacion` double, `premium` bool, `hero` path ) — el Detalle necesita datos propios, no parsear el texto de la card |
| Datos inventados | Las direcciones de Skyline y Municipal no están en el mockup ( solo la de Elite ) — se inventan razonables y quedan en el modelo para cambiar después |
| Foto hero | Asset nuevo con la foto del mockup para Elite; las otras canchas usan su foto actual como hero ( el mockup solo define el de Elite ) |
| Badge `PREMIUM` | Solo en canchas con `premium: true` ( Elite y Skyline según la tabla §4; Municipal false, como variante visible ) |
| Favorito / Compartir | Inertes ( sin pantallas destino ) |
| `Ver todo` | Sigue inerte |
| Estado del Inicio | Se conserva al volver ( pantalla precargada en el shell ) |

## 9. Riesgos y notas para la siguiente iteración

- **Parte 2** ( comodidades + "Sobre esta cancha" ) y **parte 3** ( horarios
  + barra `Precio total / Confirmar reserva` ) completan la pantalla; la
  variante "comodidades no disponibles" ( 07 ) se define en la parte 2.
- Con la parte 3, `Confirmar reserva` abre el flujo de reserva ( éxito /
  error — RDs aparte ).
- Cuando Favoritos tenga pantalla, el botón del hero se cablea ahí.
