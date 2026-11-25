# Spec — Perfil

> SDD as-built del RD `docs/HistRequerimientos/perfil.md` ( 2026-11-25 ).
> Pantalla 11 — tab Perfil del shell.

## 1. Qué quedó implementado

| RF | Implementación | Dónde |
|---|---|---|
| RF-01 | Pantalla completa: header `Perfil`, tarjeta `Cuenta` ( avatar `MR`, nombre, email, stats 12/4/340 ), menú de 5 filas con ícono+chevron y separadores, botón `Cerrar sesión` | `lib/features/perfil/perfil_screen.dart` |
| RF-02 | Fila `Mis reservas` → tab Mis reservas ( `onIrAMisReservas` ); `Cerrar sesión` → `pushAndRemoveUntil` al `LoginScreen` ( pila limpia ); las otras 4 filas inertes | `_BotonCerrarSesion._cerrarSesion` + `main_shell.dart` |

## 2. Decisiones ( del RD §8 )

- **Datos estáticos del mockup** ( `MR` / `Martín Rodríguez` /
  `martin.rodriguez@gmail.com` / 12 Reservas, 4 Favoritas, 340 Puntos ): el
  login es hardcodeado y no guarda sesión; derivar el usuario real llega con
  la fase backend. Las stats no se derivan del store ( que tiene 4 reservas )
  para no contradecir el diseño.
- **Filas del menú inertes** salvo `Mis reservas` y `Cerrar sesión` ( el
  mockup no define pantallas para Mis datos / Métodos de pago /
  Notificaciones / Ayuda ). Semántica: `Semantics(button: onTap != null)`.
- **`Cerrar sesión`**: `pushAndRemoveUntil` → `LoginScreen(onIngresar: (_, _) {})`.
  El propio `LoginScreen` hace `pushReplacement` al `MainShell` al validar —
  `onIngresar` es solo un hook de notificación ( se pasa vacío, igual que en
  `main.dart` ).
- **Claves**: el tab Perfil deja de ser placeholder — `ValueKey('perfil-screen')`
  reemplaza a `placeholder-perfil` ( los tests de `main_shell_test.dart` se
  actualizaron; cambio de alcance del plan ). La fila lleva
  `ValueKey('fila-mis-reservas')` y el botón `ValueKey('cerrar-sesion')`.

## 3. Verificación

- `flutter analyze`: sin issues. `flutter test`: **175/175** ( 169 previos + 6
  nuevos: 3 layout + 3 acciones ).
- Visual CDP/Edge 375×844 @2x ( `%LOCALAPPDATA%\Temp\opencode\shots\perfil\` ):
  pantalla completa conforme al frame 11 ( `pf-01` ), fila `Mis reservas`
  abriendo el tab ( `pf-02` ), `Cerrar sesión` en el login ( `pf-03` ).

## 4. Lecciones

- **`Container` no es `const`**: `const Container(...)` en una lista de
  children con spreads compila mal — quitar el `const` ( el constructor de
  `Container` no es const ).
- **Parámetros required ocultos al navegar**: abrir una pantalla conocida
  desde otro flujo puede requerir parámetros que el flujo original pasa (
  `LoginScreen.onIngresar` ). Ver el wiring real ( `main.dart` / el propio
  screen ) antes de construir la ruta.

## 5. Límites ( qué NO hace )

- No edita datos de cuenta, no muestra datos reales del usuario logueado.
- Las stats son fijas; no se actualizan al reservar o cancelar.
- Las 4 filas restantes no abren pantallas.

## 6. Conexiones

- Shell: `main_shell.dart` ( tab Perfil ); `Cerrar sesión` → `login_screen.dart`
  ( que re-entra al shell con `tabInicial: inicio` por defecto ).
- Favoritos ( 12 ) sigue placeholder — su fila `Favoritas` de las stats y el
  tab quedan pendientes del próximo RD.

## 7. Pendiente ( mapa )

- Favoritos ( 12 ), filtrado + estado "sin canchas" del Inicio ( 06 ), fase
  backend.
