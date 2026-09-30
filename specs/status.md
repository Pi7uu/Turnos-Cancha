# Estado de tareas — TurnosCancha

Actualizado: 2026-09-23. Rama: `master`.

## Completadas

| # | Tarea | Estado | Evidencia |
|---|---|---|---|
| 1 | Esqueleto de arquitectura (docs, backend Django, app Flutter) en blanco | ✅ | estructura del repo |
| 2 | Modelos de dominio (Usuario, Cancha, Reserva, Configuración) | ✅ | `apps/turnos/models.py` + migración `0001_initial` |
| 3 | API de canchas, disponibilidad y reservas (crear/confirmar/cancelar, agenda admin, reserva manual) | ✅ | `apps/turnos/api.py`, tests en `tests.py` (18 tests OK) |
| 4 | Pantallas Flutter (login, registro, disponibilidad, reservar, mis reservas, agenda admin) | ✅ | `src/mobile/lib/features/` (pendiente `flutter analyze`, Flutter no instalado en la máquina) |
| 5 | Auth (registro/login/logout con sesión y roles cliente/admin) | ✅ | `/api/auth/*`, `auth.py` (session sin CSRF) |
| 6 | Seed data y fixtures (canchas F5-A/F5-B, configuración) | ✅ | `fixtures/initial_data.json` |

## Pendientes

| # | Tarea | Estado | Nota |
|---|---|---|---|
| 7 | Vencimiento automático programado (cron/task) | ⏳ | Existe el comando `python manage.py vencer_reservas` y se aplica al consultar disponibilidad; falta tarea periódica en hosting |
| 8 | Avisos por WhatsApp (Etapa 2) | ⏳ | — |
| 9 | Historial y filtros avanzados en panel admin | ⏳ | Básico: agenda por día + historial por cliente |
