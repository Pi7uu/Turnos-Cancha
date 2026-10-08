# AGENTS.md

> Project purpose: see `overview.md`. Plan: `general.md`. Backend vivo: `docs/specs/requerimientos-backend.md`.

## Architecture

Django backend + Flutter mobile app: Django expone solo `/api/` y `/admin/`. La app Flutter consume la API REST. Las reservas (turnos) son el dominio central.

- **Backend:** `src/BackEnd/config/` (proyecto Django), `src/BackEnd/apps/turnos/` (main app), `src/BackEnd/db/` (SQLite) — correr Django desde `src/BackEnd/`
- **Mobile:** `src/FrontEnd/` (Flutter, Dart) — ⏳ carpeta vacía, app pendiente de crear
- **Database:** SQLite local (`src/BackEnd/db/db.sqlite3`); seed fixture pendiente (`apps/turnos/fixtures/initial_data.json`)
- **Locale:** Spanish (`es-AR`), all UI text and API messages in Spanish

## Estado actual (2026-10-06)

- ✅ Backend recreado: `config/`, modelos (`models.py`) + migración `0001_initial`, `auth.py` (sesión sin CSRF)
- ⏳ Pendiente: `services.py`, API `/api/`, fixtures/seed, comando `vencer_reservas`, `tests.py`, app Flutter

## Dev Commands

### Backend (Django — correr desde `src/BackEnd/`)

```bash
# Run dev server (port 8000)
python manage.py runserver

# Migrations
python manage.py makemigrations
python manage.py migrate

# Load seed data (pendiente: fixture aún no existe)
python manage.py loaddata apps/turnos/fixtures/initial_data.json

# Django shell
python manage.py shell
```

### Mobile (Flutter) — pendiente

```bash
# Falta: flutter create (src/FrontEnd está vacía)
cd src/FrontEnd && flutter pub get
cd src/FrontEnd && flutter run
cd src/FrontEnd && flutter analyze
cd src/FrontEnd && flutter test
```

## Key Quirks

- **Usuario sin `username`:** login por email (`USERNAME_FIELD="email"`, manager `UsuarioManager`).
- **Anti doble reserva:** `ReservaCancha` tiene índice único parcial `(cancha, fecha, hora_inicio) WHERE ocupando`; `ocupando` se sincroniza con el estado en `services.py` (pendiente).
- **CSRF is disabled** for the API (session auth without CSRF for mobile clients).
- **Tests:** ⏳ `src/BackEnd/apps/turnos/tests.py` todavía no existe (reconstruir).
- **No CI/CD** or pre-commit hooks configured.
- CORS allows mobile dev origins/emulators with credentials.
- `requirements.txt` has no lockfile — install directly.
