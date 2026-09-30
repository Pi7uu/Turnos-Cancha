# TurnosCancha — Alquiler de canchas de fútbol por turnos

App móvil para reservar canchas de fútbol. Ver propósito en `overview.md`
y sistema de diseño en `DESIGN.md`.

## Arquitectura

- **Backend:** Django + DRF (`src/backend/`) — expone solo `/api/` y `/admin/`.
- **Mobile:** Flutter (`src/mobile/`, Android/iOS).
- **DB:** SQLite en desarrollo (`src/backend/db/db.sqlite3`), seed con fixtures.
- **Locale:** español (`es-AR`) en UI y mensajes.

```
src/backend/
  manage.py  requirements.txt
  config/          settings, urls, wsgi/asgi (puerta de entrada web)
  apps/turnos/     la aplicación: modelos, API, servicios, admin
  db/              base de datos SQLite
  tools/           scripts de mantenimiento y operación
  static/          estáticos propios
src/mobile/
  pubspec.yaml
  lib/             entrypoint + pantallas, widgets, servicios, estado
```

## Desarrollo

```bash
# Backend (puerto 8000) — correr desde src/backend
cd src/backend
python manage.py migrate
python manage.py runserver

# Mobile — correr desde src/mobile
cd src/mobile
flutter pub get
flutter run
```

Configuración por entorno (ver `.env.example`):

```bash
copy .env.example .env
```

| Variable | Default | Descripción |
|---|---|---|
| `DJANGO_SECRET_KEY` | clave insegura solo-dev | Requerida real en producción |
| `DJANGO_DEBUG` | `True` | `False` en producción |
| `DJANGO_ALLOWED_HOSTS` | `localhost,127.0.0.1` | Hosts permitidos |

## Datos de prueba (seed)

```bash
cd src/backend && python manage.py loaddata apps/turnos/fixtures/initial_data.json
```

- **Admin:** `admin@turnos.com` / `admin12345` (también entra a `/admin/`)
- Canchas: `F5-A`, `F5-B` (la F7 ocupa las dos mitades)
- Configuración: turnos de 60 min, 09:00–23:00, vencimiento/cancelación 24 h

## API principal

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/auth/registro/` | Crear cuenta de cliente |
| POST | `/api/auth/login/` / `logout/` / GET `me/` | Sesión (cookie) |
| GET | `/api/disponibilidad/?fecha=YYYY-MM-DD` | Horarios libres (F5-A / F5-B / F7) |
| POST | `/api/reservas/` | Crear reserva (queda PENDIENTE) |
| POST | `/api/reservas/{id}/confirmar/` · `cancelar/` | Ciclo de vida |
| GET | `/api/reservas/mias/` | Reservas del cliente |
| GET | `/api/admin/agenda/?fecha=` | Agenda del día (admin) |
| POST | `/api/admin/reservas/` | Reserva manual (admin) |
| GET | `/api/admin/clientes/` · `/api/admin/clientes/{id}/reservas/` | Clientes e historial |

Vencimientos automáticos: `python manage.py vencer_reservas` (y se aplican al consultar disponibilidad).

## Tests y lint

```bash
cd src/backend && python manage.py test apps.turnos.tests
cd src/mobile && flutter analyze && flutter test
```
