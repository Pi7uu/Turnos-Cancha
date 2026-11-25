# Spec — Favoritos

> SDD as-built del RD `docs/HistRequerimientos/favoritos.md` ( 2026-11-25 ).
> Pantalla 12 — tab Favoritos del shell ( la última pantalla del prototipo ).

## 1. Qué quedó implementado

| RF | Implementación | Dónde |
|---|---|---|
| RF-01 | Header `Favoritos` + contador `N canchas`, lista de cards ( foto 92×92, nombre + corazón, distancia, rating, precio + `Reservar` ) con los datos del mockup | `lib/features/favoritos/favoritos_screen.dart` |
| RF-02 | Corazón → `quitarFavorito` ( saca la card, baja el contador ); lista vacía → estado vacío + `Explorar canchas` → tab Inicio | `_FavoritosScreenState._quitar` + `_EstadoVacio` |
| RF-03 | `Reservar` → `DetalleScreen(cancha, fecha: 'Mar, 15 oct')` ( misma navegación que las cards del Inicio ) | `_reservar` |

## 2. Decisiones ( del RD §8 )

- **Store** `favoritos_locales.dart` ( patrón `reservas_locales` ):
  `favoritosLocales` sembrada con `canchasSimuladas` ( las 3 canchas del
  mockup ), `quitarFavorito(Cancha)`, `resetFavoritos()`.
- **Datos**: se reutilizan los campos de `Cancha` ( `foto`, `nombre`,
  `distancia`, `rating`, `precio` ). Nota: `Cancha` tiene `rating` ( String
  ya armada, `4.8 (124 reseñas)` ) y `puntuacion` ( double, para el badge del
  Detalle ) — la card usa `rating`.
- **`Reservar` → fecha** `Mar, 15 oct` ( día por defecto del selector del
  Inicio; Favoritos no tiene selector ).
- **Estado vacío** ( extensión — el mockup no lo define ): estilo frame 09 (
  círculo `$primarySoft` con `heart`, `Todavía no tenés favoritos`,
  descripción, `Explorar canchas` ).
- **Clave**: `ValueKey('favoritos-screen')` reemplaza a
  `placeholder-favoritos` ( `main_shell_test.dart` actualizado; ya no quedan
  placeholders en el shell ). Claves de acciones: `quitar-<nombre>`,
  `reservar-<nombre>`, `explorar-favoritos`.
- **Corazón del Detalle sigue inerte** ( fuera de alcance ): el enlace
  favoritos ↔ Detalle llega con la fase backend.

## 3. Verificación

- `flutter analyze`: sin issues. `flutter test`: **184/184** ( 175 previos +
  3 store + 3 pantalla + 3 acciones ).
- Visual CDP/Edge 375×844 @2x ( `%LOCALAPPDATA%\Temp\opencode\shots\favoritos\` ):
  pantalla completa conforme al frame 12 ( `fb-01` ), corazón quitando Elite
  con contador `2 canchas` ( `fb-02` ), `Reservar` abriendo el Detalle de
  Skyline con `Mar, 15 oct` ( `fb-03` ), estado vacío ( `fb-04` ).

## 4. Lecciones

- **Dos campos para el rating**: `Cancha.rating` ( texto armado para cards )
  y `Cancha.puntuacion` ( double para el badge del Detalle ) — usar el que
  corresponde; `Text(puntuacion)` compila mal ( double → String ).
- **Overflow con la fuente de tests**: el font Ahem-like de los tests es más
  ancho que Roboto y desborda Rows que en dispositivo entran ( header
  `Favoritos` + contador, rating con reseñas, precio + botón ). Fix según la
  lección de specs anteriores: `Flexible` + ellipsis en el lado encogible o
  `FittedBox(scaleDown)` en el grupo fijo; en dispositivo todo entra
  completo.

## 5. Límites ( qué NO hace )

- No agrega favoritos ( solo quita ); el corazón del Detalle no sincroniza.
- Sin persistencia entre arranques.

## 6. Conexiones

- Shell: `main_shell.dart` ( ahora **sin placeholders**: las 4 pantallas son
  reales ). `Explorar canchas` → tab Inicio ( `onExplorar` ).
- Con el Detalle: `Reservar` lo abre; el flujo de reserva sigue funcionando
  igual desde ahí.

## 7. Pendiente ( mapa )

- **Filtrado + estado "sin canchas" ( 06 ) del Inicio** — la última
  pantalla/estado del prototipo por implementar. Luego fase backend (
  `services.py`, API `/api/`, fixtures, login real ).
