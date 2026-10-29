# AGENTS.md

> Project purpose: see `overview.md`.

## Architecture

Django backend + Flutter mobile app: Django expone solo `/api/` y `/admin/`. La app Flutter consume la API REST. Las reservas (turnos) son el dominio central.

- **Backend:** `src/BackEnd/config/` (proyecto Django), `src/BackEnd/apps/turnos/` (main app) — correr Django desde `src/BackEnd/`
- **Mobile:** `src/FrontEnd/` (Flutter, Dart) — proyecto `turnos_cancha` creado funciona; login local (spec `docs/HistRequerimientos/login.md`)
- **Database:** SQLite local (`src/BackEnd/db/db.sqlite3`); seed fixture pendiente (`apps/turnos/fixtures/initial_data.json`)
- **Locale:** Spanish (`es-AR`), all UI text and API messages in Spanish

## Estado actual (2026-10-29)

- ✅ Backend recreado: `config/`, modelos (`models.py`) + migración `0001_initial`, `auth.py` (sesión sin CSRF). Documentado en `docs/requerimientos/funcional-backend.md` (corte 2026-10-08)
- ✅ Login Flutter implementado (RD 2026-10-15): pantallas 04/04b, credenciales hardcodeadas (`igpi7uu@gmail.com`/`igpi7uu` en `lib/features/auth/credenciales.dart`), pantalla "usuario validado", tests de widgets. Sin HTTP ni persistencia de sesión (por spec de esa etapa)
- ✅ Verificación 2026-10-29: Flutter 3.47.9 stable instalado en `%USERPROFILE%\flutter` (⚠️ no está en PATH; invocar `%USERPROFILE%\flutter\bin\flutter.bat`). `flutter analyze` sin issues y `flutter test`: 19/19 tests pasan. Verificación visual por CDP/Chrome a 375×844 @2x (sin Android SDK): wireframes 04, 04b y pantalla `usuario validado` renderizan conforme al spec; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\`
- ⏳ Pendiente: `services.py`, API `/api/`, fixtures/seed, comando `vencer_reservas`, `tests.py` (backend), persistencia de sesión y login contra `/api/auth/login/` en Flutter

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

### Mobile (Flutter, correr desde `src/FrontEnd/`)

```bash
cd src/FrontEnd && flutter pub get
cd src/FrontEnd && flutter run
cd src/FrontEnd && flutter analyze
cd src/FrontEnd && flutter test
```

## Key Quirks

- **Usuario sin `username`:** login por email (`USERNAME_FIELD="email"`, manager `UsuarioManager`).
- **Anti doble reserva:** `ReservaCancha` tiene índice único parcial `(cancha, fecha, hora_inicio) WHERE ocupando`; `ocupando` se sincroniza con el estado en `services.py` (pendiente).
- **CSRF is disabled** for the API (session auth without CSRF for mobile clients).
- **Tests:** backend `src/BackEnd/apps/turnos/tests.py` todavía no existe (reconstruir); frontend tiene tests de widgets (`login_screen_test.dart`, `credenciales_test.dart`).
- **No CI/CD** or pre-commit hooks configured.
- CORS allows mobile dev origins/emulators with credentials.
- `requirements.txt` has no lockfile — install directly.
