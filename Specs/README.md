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
| `inicio-canchas.md` | ✅ Implementado | Lista de canchas del Inicio: 3 cards con datos simulados y assets ( sin filtrado ni navegación ) |
| `inicio-categorias.md` | ✅ Implementado | Bloque Categorías del Inicio: 2 chips inertes ( Fútbol 5 / Fútbol 7 ) |
| `detalle-hero.md` | ✅ Implementado | Detalle de cancha parte 1: hero + info + navegación desde las cards del Inicio |
| `detalle-comodidades.md` | ✅ Implementado | Detalle de cancha parte 2: comodidades con estados + aviso y "Sobre esta cancha" |
| `detalle-horarios.md` | ✅ Implementado | Detalle de cancha parte 3: horarios con selección + barra de reserva fija (Confirmar inerte) |
| `reserva-exitosa.md` | ✅ Implementado | Reserva exitosa: pantalla de confirmación con N° de orden + navegación a Mis reservas/Inicio |
| `reserva-error.md` | ✅ Implementado | Error de reserva: pantalla de carrera por el horario + regla de éxito/error del Confirmar |
| `mis-reservas-lista.md` | ✅ Implementado | Mis reservas parte 1: header + pestañas + cards con estados (acciones inertes) |
| `mis-reservas-acciones.md` | ✅ Implementado | Mis reservas parte 2: acciones reales + store compartido con el flujo, estados vacíos y variante "Sin QR" |
| `perfil.md` | ✅ Implementado | Pantalla 11 · Perfil: cuenta con stats, menú de opciones y cerrar sesión |
| `favoritos.md` | ✅ Implementado | Pantalla 12 · Favoritos: cards con datos, quitar favorito, estado vacío y Reservar → Detalle |
| `inicio-filtrado.md` | ✅ Implementado | Inicio · filtrado ( buscador + categorías ) y estado "sin canchas" ( 06 ) — **prototipo completo** |

## Mapa de pendientes ( para próximos RDs )

**Prototipo completo** ( las 12 pantallas/estados del mockup ). Queda la
**fase backend**: API `/api/`, servicios ( `services.py` ), persistencia,
fixtures/seed, comando `vencer_reservas`, login real contra
`/api/auth/login/`.

## Convenciones de un spec

Cada spec tiene: **Propósito** · **Cómo funciona** ( comportamiento real,
textos y medidas exactas ) · **Archivos** · **Decisiones** · **Límites**
( qué NO hace — importante para no asumir funcionalidad inexistente ) ·
**Conexiones** ( cómo se relaciona con otras features ).
