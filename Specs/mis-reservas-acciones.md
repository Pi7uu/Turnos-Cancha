# Spec — Mis reservas · acciones y store

> SDD as-built del RD `docs/HistRequerimientos/mis-reservas-acciones.md`
> ( 2026-11-25 ). Pantalla 03, parte 2 — con esto la pantalla queda **completa**.
> Parte 1: `Specs/mis-reservas-lista.md`.

## 1. Qué quedó implementado

| RF | Implementación | Dónde |
|---|---|---|
| RF-01 | Acciones reales: `Cancelar reserva` → cancelada ( se mueve a Canceladas ); `Confirmar` ( solo PENDIENTE ) → confirmada; `Ver QR` → diálogo `Tu QR` | `lib/features/mis_reservas/mis_reservas_screen.dart` ( `_cancelar`/`_confirmar`/`_mostrarQr` ) |
| RF-02 | Store en memoria compartido con el flujo: al confirmar con éxito se registra la reserva → aparece en **Próximas** | `lib/features/mis_reservas/reservas_locales.dart` + `lib/features/detalle/detalle_screen.dart` ( `_confirmarReserva` ) |
| RF-03 | Estado vacío de pestaña ( frame 09 ): `No tenés reservas` + `Explorar canchas` → tab Inicio | `_EstadoVacio` en `mis_reservas_screen.dart` |
| RF-04 | Variante "Sin QR" ( frame 08 ): confirmada con `tieneQr: false` muestra solo `Cancelar reserva` | botones de `_CardReserva` según `estado`/`tieneQr` |

## 2. Decisiones ( del RD §8 )

- **Store** `reservasLocales` ( `List<Reserva>` mutable, patrón `usuarios_locales` ): sembrada con `reservasSimuladas`; `registrarReserva` ( inserta al inicio ), `cancelarReserva`/`confirmarReserva` ( reemplazan por `copyWith` ), `resetReservas` ( `@visibleForTesting` ).
- **Registro del flujo:** `_confirmarReserva` registra **solo en el camino de éxito** ( la rama de error no agrega nada ). Datos: `fecha = <label del Inicio> 2026`, `horario = <hora> - <hora+1>` ( `20:00` → `21:00` ), `sector = cancha.sector`, estado confirmada, `tieneQr: true`.
- **`Reserva.tieneQr`** ( bool ): la semilla Elite Mar 15 es `false` ( muestra la variante 08 ); las creadas en la sesión `true` ( estado base del PNG 03 ).
- **`Cancha.sector`** ( campo nuevo ): `Cancha A (5v5)` / `Cancha principal (7v7)` / `Cancha B (5v5)` — iguala el dato de las semillas con el de las reservas del flujo.
- **Diálogo `Tu QR`**: extensión ( el mockup no define pantalla de QR ) — `$surface` radio 16 padding 24, `Tu QR` 18px w700, cuadro 160×160 borde `$border` radio 12 con `qr-code` 96×96 `$text-2`, `Mostrá este código en la entrada.` 13px `$text-2`, botón `Cerrar` ( `$primary` radio 12 ).
- **Estado vacío** ( frame 09 ): círculo 88×88 `$primarySoft` radio 44 con `calendar-days` 40×40 `$primary`; `No tenés reservas` 19px w700; descripción 14px `$text-2` `height: 1.5` ancho máx 270; `Explorar canchas` ( `$primary`, radio 12, padding 14/30, 15px w600 blanco ) → `onVolver` ( tab Inicio ).

## 3. Comportamiento de las cards ( resumen )

| Estado | Botones |
|---|---|
| PENDIENTE ( Próximas ) | `Cancelar reserva` + `Confirmar` |
| CONFIRMADA con QR | `Cancelar reserva` + `Ver QR` |
| CONFIRMADA sin QR ( 08 ) | `Cancelar reserva` solo ( ancho completo ) |
| COMPLETADA / CANCELADA | sin acciones |

## 4. Verificación

- `flutter analyze`: sin issues. `flutter test`: **169/169** ( 155 previos + 14 nuevos: 5 store + 6 acciones/vacío/flujo + ajustes ).
- Visual CDP/Edge 375×844 @2x ( `%LOCALAPPDATA%\Temp\opencode\shots\mis-reservas-acciones\` ): Próximas con acciones y variante sin QR ( `ma-01` ), Skyline CONFIRMADA tras `Confirmar` ( `ma-02` ), diálogo `Tu QR` ( `ma-03` ), estado vacío ( `ma-05` ), reserva del flujo en Próximas con `20:00 - 21:00`/`Cancha A (5v5)`/`Ver QR` ( `ma-06` ).

## 5. Lecciones

- **Interpolación de métodos:** `'$_seleccionado - $_horaFin()'` compila pero interpola el **tear-off** ( `Closure: ...` + `()` literal ), no el resultado. Usar `'${_horaFin()}'`. Este bug pasó los tests unitarios de la pantalla y lo detectó el test end-to-end del flujo.
- **Data nueva rompe asserts viejos:** la decisión del RD ( Elite `tieneQr: false` ) cambió los botones visibles de Próximas y rompió 2 asserts de la parte 1 ( `Ver QR` presente / estilo del botón verde ). Ruling: el RD es la autoridad — se ajustaron los asserts ( `Ver QR` → `findsNothing` en Próximas; el estilo verde se verifica con `Confirmar` ).
- **Contaminación entre tests con store global:** los tests que mutan el store necesitan `setUp(resetReservas)` **en cada archivo** ( `mis_reservas_test.dart` la parte 1 no lo tenía y el test "inertes" — ahora `no_navegan` — contaminaba a los siguientes ).

## 6. Pendiente ( mapa )

- Perfil ( 11 ), Favoritos ( 12 ), filtrado + estado "sin canchas" del Inicio ( 06 ), fase backend ( `services.py`, API, fixtures, login contra `/api/auth/login/` ).
