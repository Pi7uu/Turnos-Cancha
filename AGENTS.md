# AGENTS.md

> Project purpose: see `overview.md`.

## Architecture

Django backend + Flutter mobile app: Django expone solo `/api/` y `/admin/`. La app Flutter consume la API REST. Las reservas (turnos) son el dominio central.

- **Backend:** `src/backend/config/` (proyecto Django), `src/backend/apps/turnos/` (main app), `src/backend/db/` (SQLite), `src/backend/tools/` (scripts) — correr Django desde `src/backend/`
- **Mobile:** `src/mobile/` (Flutter, Dart)
- **Database:** SQLite (`src/backend/db/db.sqlite3`), seed via `apps/turnos/fixtures/initial_data.json`
- **Locale:** Spanish (`es-AR`), all UI text and API messages in Spanish

## Dev Commands

### Backend (Django — correr desde `src/backend/`)

```bash
# Run dev server (port 8000)
python manage.py runserver

# Migrations
python manage.py makemigrations
python manage.py migrate

# Load seed data
python manage.py loaddata apps/turnos/fixtures/initial_data.json

# Django shell
python manage.py shell
```

### Mobile (Flutter)

```bash
# Install deps
cd src/mobile && flutter pub get

# Run (device/emulator connected)
cd src/mobile && flutter run

# Analyze / test
cd src/mobile && flutter analyze
cd src/mobile && flutter test
```

## Key Quirks

- **CSRF is disabled** for the API (session auth without CSRF for mobile clients).
- **Tests:** `src/backend/apps/turnos/tests.py` (`python manage.py test apps.turnos.tests` desde `src/backend/`).
- **No CI/CD** or pre-commit hooks configured.
- CORS allows mobile dev origins/emulators with credentials.
- `requirements.txt` has no lockfile — install directly.
