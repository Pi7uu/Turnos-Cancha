# Specs/ — Cómo funciona lo implementado

Referencia **as-built** del proyecto ( Spec-Driven Development ): cada `.md`
detalla el funcionamiento real de un requerimiento ya implementado y
verificado. Es la fuente para que los próximos requerimientos sepan qué
existe, cómo se conecta y qué no tocar.

**Relación con la documentación:**

| Carpeta | Qué responde |
|---|---|
| `docs/requerimientos/` | Qué se va a implementar ( RD activo, uno por feature ) |
| `docs/HistRequerimientos/` | Qué se pidió ( RDs cerrados, archivo histórico ) |
| `Specs/` | **Cómo funciona lo implementado** ( este índice + uno por feature ) |

Los specs y los RDs comparten nombre de archivo ( `Specs/login.md` ↔
`docs/HistRequerimientos/login.md` ). Al cerrar un requerimiento se escribe
su spec **antes** de mover el RD a Hist.

## Índice de lo implementado

| Spec | Estado | Qué hace ( 1 línea ) |
|---|---|---|
| `login.md` | ✅ Implementado | Autenticación local en las pantallas 04/04b; éxito entra al shell de navegación |
| `registro.md` | ✅ Implementado | Alta local de usuarios ( pantalla 05 ) con validación inline; el login los acepta |
| `navegacion.md` | ✅ Implementado | Shell con Tab Bar de 4 tabs e IndexedStack; entrada de la app tras el login |
| `inicio-header.md` | ✅ Implementado | Header del Inicio: marca + campana con badge + perfil ( taps muertos ) |
| `inicio-buscador.md` | ✅ Implementado | Campo de búsqueda del Inicio, editable pero sin filtrar ( filtrado llega con la lista ) |
| `inicio-fecha.md` | ✅ Implementado | Selector de fecha del Inicio: 5 días fijos con selección local ( no filtra aún ) |

## Mapa de pendientes ( para próximos RDs )

Pantalla 01 · Inicio: tarjetas de canchas, categorías, estado "sin canchas"
( 06 ). Pantalla 02 · Detalle de cancha + variante 07. Flujo de reserva: éxito ( Contenido ) + error ( 10 ). Pantalla
03 · Mis reservas + estados 08/09. Pantalla 11 · Perfil. Pantalla 12 ·
Favoritos. Backend: API `/api/`, servicios, persistencia.

## Convenciones de un spec

Cada spec tiene: **Propósito** · **Cómo funciona** ( comportamiento real,
textos y medidas exactas ) · **Archivos** · **Decisiones** · **Límites**
( qué NO hace — importante para no asumir funcionalidad inexistente ) ·
**Conexiones** ( cómo se relaciona con otras features ).
