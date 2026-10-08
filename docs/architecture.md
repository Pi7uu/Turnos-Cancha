# Arquitectura — TurnosCancha

App móvil para alquiler de canchas de fútbol por turnos. Ver propósito en
`../overview.md` y plan del proyecto en `../general.md`.

> **Estado (2026-10-06):** reinicio en curso — el código previo se eliminó
> (commit `6c8ef4a`). Backend recreado: proyecto `config/`, app `turnos` con
> modelos + migración inicial (SQLite) y `auth.py` (sesión sin CSRF).
> Pendientes: `services.py`, API, seed, tests y la app Flutter.
> Especificación completa en `specs/requerimientos-backend.md`.

## 1. Visión general

```
┌──────────────┐      /api/*       ┌──────────────────┐
│ Flutter App  │ ────────────────▶ │  Django + DRF    │
│ (Android/    │ ◀──────────────── │  API             │
│  iOS)        │      JSON         └────────┬─────────┘
└──────────────┘                            │ SQL
                                            ▼
                                   ┌──────────────────┐
                                   │  SQLite          │
                                   └──────────────────┘
```

- **Mobile:** Flutter. Toda la UI vive acá.
- **Backend:** Django + DRF. Expone solo `/api/` y `/admin/`.
- **DB:** SQLite, puramente local por ahora (archivo `src/BackEnd/db/db.sqlite3`);
  PostgreSQL cuando se escale (hosting público / varios usuarios concurrentes).
- **Idioma:** español (`es-AR`) en UI y mensajes de la API.

## 2. Estructura de carpetas (objetivo)

```
src/
  BackEnd/
    manage.py  requirements.txt
    config/               proyecto Django: settings, urls, wsgi/asgi
    apps/turnos/          única app: modelos, API, servicios, admin
      models.py           Usuario, Cancha, Reserva, ReservaCancha, Configuracion
      api.py / api_urls.py  endpoints REST bajo /api/
      services.py         lógica de negocio (única fuente de verdad)
      auth.py             autenticación por email (sesión)
      serializers.py      serializers DRF
      admin.py            admin de canchas, turnos, reservas
      fixtures/           initial_data.json (seed)
      tests.py            tests
      management/commands/  vencer_reservas
    db/                   db.sqlite3
    tools/                scripts de mantenimiento
    static/               estáticos propios
  FrontEnd/
    pubspec.yaml          dependencias Dart
    lib/
      main.dart           entrypoint
      core/               api client, router, modelos, widgets base
      features/           auth/, reservas/, admin/ (pantallas + estado)
docs/
  architecture.md         este archivo
  prototipos/             maquetas (referencia)
  specs/                  especificaciones de features
```

## 3. Backend (`src/BackEnd/`)

Se corre desde `src/BackEnd/` (`python manage.py runserver`, puerto 8000).

### 3.1. `config/` — puerta de entrada

- `settings.py`: `BASE_DIR = src/BackEnd`.
- `urls.py`: solo `admin/` (la ruta `api/` se suma con la API).
- Configuración sensible por entorno (ver `../.env.example`):
  `DJANGO_SECRET_KEY`, `DJANGO_DEBUG`, `DJANGO_ALLOWED_HOSTS`.

### 3.2. `apps/turnos/` — la aplicación

- **Modelos (✅ implementados, migración `0001_initial`):** `Usuario` (sin
  `username`, login por email, rol `CLIENTE`/`ADMIN`), `Cancha` (`F5-A`/`F5-B`),
  `Reserva` (tipo `F5`/`F7`, estados `PENDIENTE`/`CONFIRMADA`/`VENCIDA`/`CANCELADA`),
  `ReservaCancha` (ocupación, con índice único parcial anti-doble-reserva) y
  `Configuracion` (singleton). Detalle en `specs/requerimientos-backend.md` §1.
- **Servicios** (`services.py`, ⏳): única fuente de verdad para la lógica de
  reserva (disponibilidad, superposición, estados, vencimientos).
- **API** (`api.py`, rutas en `api_urls.py`, prefijo `/api/`, ⏳): auth,
  disponibilidad, reservas y endpoints `admin/*`. Detalle en
  `specs/requerimientos-backend.md` §3.

### 3.3. Reglas de negocio clave

- **Superposición F5/F7:** la cancha F7 ocupa las dos mitades; cada reserva
  bloquea canchas **físicas** dentro de una transacción con
  `select_for_update()`, reforzado por el índice único parcial de
  `ReservaCancha`. Dos F5 opuestos pueden convivir; entonces F7 queda
  ocupado.
- **Ciclo de vida:** crear → `PENDIENTE` (ya bloquea), excepto si el plazo de
  vencimiento ya pasó (reserva con <24 h) que nace `CONFIRMADA`;
  `VENCIDA` si no confirma 24 h antes; `CANCELADA` libre hasta 24 h
  antes (después solo admin).
- **Vencimientos:** comando `manage.py vencer_reservas` + ejecución
  perezosa al consultar disponibilidad / crear / confirmar.

## 4. FrontEnd (`src/FrontEnd/`)

⏳ Carpeta creada, app Flutter pendiente de generar (`flutter create`).
Organización prevista por features (`core/`, `features/auth`,
`features/reservas`, `features/admin`), estado con un solo mecanismo por
feature y cliente HTTP con manejo de sesión por cookie.

## 5. Flujos principales

1. **Cliente:** login → disponibilidad por día → elegir slot y tipo (F5-A /
   F5-B / F7) → reserva `PENDIENTE` → confirmar / cancelar.
2. **Admin:** agenda del día (filtro por cancha) → reserva manual
   (`cliente_email`, crea usuario si no existe) → cancelar cualquier
   reserva → clientes e historial → configuración.

## 6. Ambientes

### Desarrollo (dos terminales)

```bash
cd src/BackEnd && python manage.py runserver   # :8000 API
cd src/FrontEnd && flutter run                   # app en dispositivo/emulador (pendiente)
```

## 7. Calidad

- Backend: `python manage.py test apps.turnos.tests` (desde `src/BackEnd/`) — ⏳ `tests.py` pendiente.
- Mobile: `flutter analyze` y `flutter test` — ⏳ app pendiente.

## 8. Deuda conocida

- Sin CI/CD ni pre-commit hooks.
- `db.sqlite3` solo para desarrollo.
- Vencimientos automáticos sin tarea periódica en hosting (solo comando +
  ejecución perezosa).
