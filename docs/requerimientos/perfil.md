# Requerimientos — Perfil ( pantalla 11 )

**Fecha:** 2026-11-25
**Estado:** Listo para implementar ( ciclo autónomo: sin aprobación intermedia )
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"11 · Perfil"** ( vectores, id `x1slqU` )

---

## 1. Objetivo

Implementar la pantalla **Perfil** del Tab Bar: tarjeta de cuenta con avatar
y estadísticas, menú de opciones y `Cerrar sesión` ( vuelve al login ).

## 2. Contexto

- El tab Perfil es hoy un placeholder ( `lib/features/navegacion/main_shell.dart` ).
- Ya existen: shell con tabs, login ( 04 ), Mis reservas completo, store de
  reservas en memoria.

## 3. Alcance

### Dentro del alcance

- **Pantalla Perfil completa** ( RF-01 ): header `Perfil`, tarjeta `Cuenta`
  ( avatar con iniciales, nombre, email, 3 estadísticas ), menú de 5 filas
  con íconos y chevrons, y botón `Cerrar sesión`.
- **Acciones** ( RF-02 ): la fila `Mis reservas` cambia al tab Mis reservas;
  `Cerrar sesión` vuelve a la pantalla de login ( limpia la navegación ).
  Las otras 4 filas quedan **inertes** ( el mockup no define sus pantallas ).

### Fuera de alcance

- Pantallas de Mis datos, Métodos de pago, Notificaciones y Ayuda.
- Edición de perfil, cambio de avatar, estadísticas reales.

## 4. Espec visual ( frame 11 )

Fondo `$bg` ( #F5F7FA ). Content: vertical, hueco 18, padding 8/16/16/16.

| Elemento | Especificación |
|---|---|
| Header | `Perfil` — 24px w700 `$text` |
| Tarjeta `Cuenta` | `$surface`, radio 16, borde `$border` 1px, vertical, hueco 6, padding 22/20/20/20, centrado |
| Avatar | círculo 84×84 `$primary` radio 42, centrado: `MR` 30px w700 blanco |
| Nombre | `Martín Rodríguez` — 20px w700 `$text` |
| Email | `martin.rodriguez@gmail.com` — 14px normal `$text-2` |
| Estadísticas | fila space_between, padding 16/10/0/10: 3 columnas centradas ( hueco 2 ) con valor 18px w700 `$text` + label 11px `$text-2`: `12`/`Reservas`, `4`/`Favoritas`, `340`/`Puntos` |
| Tarjeta `Menu` | `$surface`, radio 16, borde `$border` 1px, vertical sin hueco |
| Fila del menú | padding 13/16, hueco 12, centrado: caja de ícono 36×36 `$surface-2` ( #F1F5F9 ) radio 18 con glyph lucide 17×17 `$text`; label 15px w500 `$text` ( fill ); `chevron-right` 18×18 `$text-2` |
| Filas | `Mis datos` ( user ), `Mis reservas` ( calendar ), `Métodos de pago` ( credit-card ), `Notificaciones` ( bell ), `Ayuda` ( circle-question-mark ) |
| Separadores | 1px `$border` entre filas |
| `Cerrar sesión` | fill #FEE2E2 radio 12, padding 15, hueco 8, centrado: `log-out` 17×17 #EF4444 + `Cerrar sesión` 15px w600 #EF4444 |

### Datos ( §8 )

- Cuenta estática del mockup: `MR` / `Martín Rodríguez` /
  `martin.rodriguez@gmail.com`; estadísticas `12` Reservas, `4` Favoritas,
  `340` Puntos.

## 5. Requerimientos funcionales

### RF-01 — Pantalla Perfil

- Renderiza todos los bloques de §4 en el tab Perfil del shell.

### RF-02 — Acciones

- Fila **`Mis reservas`** → cambia al tab Mis reservas ( mismo mecanismo que
  `Explorar canchas` de Mis reservas, pero hacia ese tab ).
- **`Cerrar sesión`** → vuelve a la pantalla de login ( `pushAndRemoveUntil`:
  la pila se limpia; atrás no vuelve al shell ).
- Las filas `Mis datos`, `Métodos de pago`, `Notificaciones`, `Ayuda` quedan
  inertes ( sin pantallas en el mockup ).

## 6. Requerimientos no funcionales

- **Idioma:** textos exactos de §4 (`es-AR`).
- **Tokens:** `$bg`, `$surface`, `$surface-2`, `$border`, `$text`, `$text-2`,
  `$primary` — existentes. Sin tokens nuevos.
- **Íconos:** `LucideIcons.user`, `calendar`, `creditCard`, `bell`,
  `circleQuestionMark`, `chevronRight`, `logOut` ( librería lucide instalada ).
- **Plataforma:** móvil 375×844; sin overflow en 320×568.
- **Sin red**; datos estáticos.

## 7. Criterios de aceptación

1. El tab Perfil muestra `Perfil`, la tarjeta `Cuenta` con `MR`,
   `Martín Rodríguez`, `martin.rodriguez@gmail.com` y las 3 estadísticas
   ( `12 Reservas`, `4 Favoritas`, `340 Puntos` ).
2. El menú muestra las 5 filas con sus íconos, labels y chevrons, con
   separadores de 1px.
3. `Cerrar sesión` ( botón rojo con ícono log-out ) vuelve al login y el botón
   atrás no regresa al shell.
4. La fila `Mis reservas` cambia al tab Mis reservas; las otras 4 filas no
   hacen nada al tocarlas.
5. Sin overflow en 375×844 ni en 320×568.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Datos de cuenta | Estáticos del mockup ( Martín Rodríguez ) — el login actual es hardcodeado y no guarda sesión; derivar el usuario real llega con la fase backend |
| Estadísticas | Números fijos del mockup ( 12/4/340 ); no se derivan del store ( que tiene 4 reservas ) para no contradecir el diseño |
| Filas del menú | Inertes salvo `Mis reservas` → tab y `Cerrar sesión` → login |
| `Cerrar sesión` | `pushAndRemoveUntil` al login: limpia la pila ( criterio de aceptación 3 ) |

## 9. Riesgos y notas para la siguiente iteración

- Con backend: la cuenta muestra el usuario logueado, las estadísticas salen
  de la API y las filas abren sus pantallas ( Mis datos, pagos, etc. ).
- Sigue pendiente: Favoritos ( 12 ), filtrado + estado "sin canchas" ( 06 ),
  fase backend.
