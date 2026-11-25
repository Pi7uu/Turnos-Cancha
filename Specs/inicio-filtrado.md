# Spec — Inicio · filtrado y estado "sin canchas"

> SDD as-built del RD `docs/HistRequerimientos/inicio-filtrado.md`
> ( 2026-11-25 ). Pantalla 01, cierre — **con esto el prototipo queda
> completo** ( las 12 pantallas/estados del mockup ).

## 1. Qué quedó implementado

| RF | Implementación | Dónde |
|---|---|---|
| RF-01 | El buscador filtra por nombre en vivo ( `contains` case-insensitive ) | `_InicioScreenState._query` + `_Buscador.onChanged` |
| RF-02 | Chips `Fútbol 5`/`Fútbol 7` filtran por tag; el chip activo se deselecciona al tocarlo | `_categoria` + `_tagDeCategoria` + `_Categorias.onTap` |
| RF-03 | Estado "sin canchas" ( frame 06 ) con `Elegir otra fecha` → limpia filtros | `_SinCanchas` en `inicio_screen.dart` |
| RF-04 | `Ver todo` limpia los filtros | `onVerTodo` → `_limpiarFiltros()` |

## 2. Decisiones ( del RD §8 )

- **El estado vacío lo producen los filtros** ( no la fecha ): los datos
  simulados no varían por día; el texto del mockup ( "para esta fecha" ) se
  usa igual. `Elegir otra fecha` limpia los filtros ( no cambia el día ).
- **Slug → tag**: los chips guardan su slug ( `futbol5`/`futbol7` ) y
  `_tagDeCategoria` lo mapea al `tag` de la cancha ( `5v5`/`7v7` ).
- **Chip activo**: pill `$primarySoft` con borde `$primary` ( estilo del Tab
  Bar — extensión documentada; el mockup no define el estado activo del
  chip ). Claves existentes `categoria-<slug>` conservadas.
- **`_limpiarFiltros()`**: vacía `_query`, `_categoria` y el controller del
  buscador. Lo usan `Elegir otra fecha` y `Ver todo`.
- La fecha **no filtra**; el header, buscador y bloque de fecha no cambian.

## 3. Verificación

- `flutter analyze`: sin issues. `flutter test`: **190/190** ( 184 previos + 6
  nuevos: 3 filtrado + 3 estado 06 ).
- Visual CDP/Edge 375×844 @2x ( `%LOCALAPPDATA%\Temp\opencode\shots\inicio-filtrado\` ):
  buscador `elite` filtrando a una card ( `fi-01` ), estado 06 completo con
  `Elegir otra fecha` ( `fi-02` ), filtros limpios con las 3 cards y
  buscador vacío ( `fi-03` ), chip `Fútbol 7` activo ( pill verde ) con solo
  Skyline ( `fi-04` ).

## 4. Lecciones

- **Los tests de "estado conservado" usaban el campo inerte**: 3 tests
  ( `inicio_canchas_test` y `detalle_horarios_test` ×2 ) escribían `futbol`
  en el buscador para verificar que el estado se conserva al volver del
  Detalle; con el filtrado activo ese texto vacía la lista y los taps
  fallan. Ruling: el RD activa el filtrado — se cambió el texto a `elite`
  ( la intención de los tests se preserva ). Ledger:
  `.superpowers/sdd/2026-11-25-inicio-filtrado/progress.md`.
- **El bug de mapeo slug/tag se escondió en un test**: `filtros_se_combinan`
  pasó "de casualidad" ( el mismatch daba 0 resultados igual ); lo delató
  `categorías_filtran_y_se_deseleccionan`. Los asserts de "0 resultados"
  deben combinarse con asserts de "el resultado correcto sí aparece".
- **Los chips quedan bajo el scroll** con las 3 cards: los tests que los
  tocan necesitan `ensureVisible` antes del tap.

## 5. Límites ( qué NO hace )

- No filtra por fecha ni por zona; no hay autocompletado ni ordenamiento.
- El botón `Elegir otra fecha` no cambia el día seleccionado ( solo limpia
  filtros — decisión §2 ).

## 6. Conexiones

- Inicio: las cards filtradas abren el Detalle igual que antes; `Ver todo` y
  `Elegir otra fecha` usan el mismo `_limpiarFiltros()`.
- Con backend: el filtrado se manda a la API y el estado vacío aparece por
  disponibilidad real de la fecha elegida.

## 7. Estado del prototipo

**Completo**: login ( 04/04b ), registro ( 05 ), Inicio ( 01 + 06 ), Detalle
( 02 + 07 ), flujo de reserva ( éxito + 10 ), Mis reservas ( 03 + 08 + 09 ),
Perfil ( 11 ), Favoritos ( 12 ), navegación y Tab Bar. Pendiente: **fase
backend** ( `services.py`, API `/api/`, fixtures, `vencer_reservas`, login
real contra `/api/auth/login/` ).
