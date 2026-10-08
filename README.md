# TurnosCancha — Alquiler de canchas de fútbol por turnos

App móvil para reservar canchas de fútbol. Ver propósito en `overview.md`
y sistema de diseño en `DESIGN.md`.

## Estado (2026-10-06)

Reinicio en curso: el código anterior se eliminó (commit `6c8ef4a`) y se está
reconstruyendo. Detalle y decisiones: `docs/specs/requerimientos-backend.md`.

| Componente | Estado |
|---|---|
| Backend Django: proyecto `config/`, modelos + migración inicial (SQLite) | ✅ |
| `services.py` (lógica de negocio) | ⏳ |
| API REST `/api/` | ⏳ |
| Seed (fixtures) y comando `vencer_reservas` | ⏳ |
| Tests del backend | ⏳ |
| App Flutter (`src/FrontEnd/`) | ⏳ |

## Arquitectura

- **Backend:** Django + DRF (`src/BackEnd/`) — expone solo `/api/` y `/admin/`.
- **Mobile:** Flutter (`src/FrontEnd/`, Android/iOS).
- **DB:** SQLite local (`src/BackEnd/db/db.sqlite3`) — local primero; PostgreSQL al escalar.
- **Locale:** español (`es-AR`) en UI y mensajes.

```
src/BackEnd/
  manage.py  requirements.txt
  config/          settings, urls, wsgi/asgi (puerta de entrada web)
  apps/turnos/     la aplicación (hoy: modelos + auth)
    models.py      Usuario, Cancha, Reserva, ReservaCancha, Configuracion
    auth.py        sesión sin CSRF
    migrations/    0001_initial
  db/              base de datos SQLite
  static/          estáticos propios
src/FrontEnd/      app Flutter (pendiente)
```

## Desarrollo

```bash
# Backend (puerto 8000) — correr desde src/BackEnd
cd src/BackEnd
python manage.py migrate
python manage.py runserver

# Mobile — pendiente (src/FrontEnd está vacía)
cd src/FrontEnd
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

## Datos de prueba (seed) — pendiente

Cuando exista el fixture `apps/turnos/fixtures/initial_data.json`:

```bash
cd src/BackEnd && python manage.py loaddata apps/turnos/fixtures/initial_data.json
```

Cargará: admin `admin@turnos.com`, canchas `F5-A`/`F5-B` y configuración
(turnos de 60 min, 09:00–23:00, plazos de 24 h).

## API (plan — pendiente de implementar)

| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/auth/registro/` | Crear cuenta de cliente |
| POST | `/api/auth/login/` / `logout/` / GET `me/` | Sesión (cookie) |
| GET | `/api/disponibilidad/?fecha=YYYY-MM-DD` | Horarios libres (F5-A / F5-B / F7) |
| POST | `/api/reservas/` | Crear reserva (PENDIENTE; CONFIRMADA si ya venció el plazo) |
| POST | `/api/reservas/{id}/confirmar/` · `cancelar/` | Ciclo de vida |
| GET | `/api/reservas/mias/` | Reservas del cliente |
| GET | `/api/admin/agenda/?fecha=` | Agenda del día (admin) |
| POST | `/api/admin/reservas/` | Reserva manual (admin) |
| GET | `/api/admin/clientes/` · `/api/admin/clientes/{id}/reservas/` | Clientes e historial |

Errores: `{"detalle": "..."}` con 400 / 403 / 404 / 409.
Vencimientos automáticos: comando `vencer_reservas` (pendiente).

## Tests y lint (pendientes)

```bash
cd src/BackEnd && python manage.py test apps.turnos.tests   # tests.py aún no existe
cd src/FrontEnd && flutter analyze && flutter test           # app Flutter pendiente
```
