# Arquitectura — TurnosCancha

App móvil para alquiler de canchas de fútbol por turnos. Ver propósito en
`../overview.md` y sistema de diseño en `../DESIGN.md`.

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
- **DB:** SQLite (`src/backend/db/db.sqlite3`).
- **Idioma:** español (`es-AR`) en UI y mensajes.

## 2. Estructura de carpetas

```
src/
  backend/
    manage.py  requirements.txt
    config/               proyecto Django: settings, urls, wsgi/asgi
    apps/turnos/          única app: modelos, API, servicios, admin
      models.py
      api.py / api_urls.py  endpoints REST bajo /api/
      services.py         lógica de negocio (única fuente de verdad)
      auth.py             autenticación
      serializers.py      serializers DRF
      admin.py            admin de canchas, turnos, reservas
      fixtures/           initial_data.json (seed)
      tests.py            tests
    db/                   db.sqlite3
    tools/                scripts de mantenimiento
    static/               estáticos propios
  mobile/
    pubspec.yaml          dependencias Dart
    lib/
      main.dart           entrypoint
      (pendiente: pages/, widgets/, services/, state/)
docs/
  architecture.md         este archivo
  prototipos/             maquetas (referencia)
  specs/                  especificaciones de features
```

## 3. Backend (`src/backend/`)

Se corre desde `src/backend/` (`python manage.py runserver`).

### 3.1. `config/` — puerta de entrada

- `settings.py`: `BASE_DIR = src/backend`.
- `urls.py`: `admin/` y `api/`.
- Configuración sensible por entorno (ver `../.env.example`):
  `DJANGO_SECRET_KEY`, `DJANGO_DEBUG`, `DJANGO_ALLOWED_HOSTS`.

### 3.2. `apps/turnos/` — la aplicación

**Modelos** (`models.py`): _(pendiente: Cancha, Turno/Reserva, Usuario, etc.)_

**API** (`api.py`, rutas en `api_urls.py`, prefijo `/api/`): _(pendiente)_

**Servicios** (`services.py`): única fuente de verdad para la lógica de
reserva de turnos (disponibilidad, conflictos, estados).

## 4. Mobile (`src/mobile/`)

Flutter. Pendiente definir: rutas/pantallas, estado, servicios de API.

## 5. Flujos principales

_(pendiente: catálogo de canchas, selección de turno, reserva, historial)_

## 6. Ambientes

### Desarrollo (dos terminales)

```bash
cd src/backend && python manage.py runserver   # :8000 API
cd src/mobile && flutter run                   # app en dispositivo/emulador
```

## 7. Calidad

- Backend: `python manage.py test apps.turnos.tests` (desde `src/backend/`).
- Mobile: `flutter analyze` y `flutter test`.

## 8. Deuda conocida

- Esqueleto inicial: sin CI/CD ni pre-commit hooks.
- `db.sqlite3` solo para desarrollo.
