# Arquitectura — TurnosCancha

Documento **normativo** para el equipo de desarrollo. Define las reglas de
arquitectura del proyecto: frameworks, lenguajes, capas, base de datos,
estructura de carpetas y convenciones. Toda decisión técnica debe respetar
estas reglas; cambiarlas requiere actualizar este documento.

App móvil para alquiler de canchas de fútbol por turnos.

## 1. Frameworks

- **Backend:** Django + Django REST Framework. Expone **únicamente** `/api/`
  (REST/JSON) y `/admin/`. No se publica ninguna otra ruta.
- **Mobile:** Flutter (Android/iOS). Toda la UI vive en la app; el backend no
  renderiza HTML.

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

## 2. Lenguajes e idioma

- **Backend:** Python. **Mobile:** Dart.
- Todo texto de UI y todos los mensajes de la API están en español (`es-AR`).

## 3. Capas

- **Mobile → API → Backend → Base de datos.** Cada capa solo habla con la
  adyacente:
  - Flutter **nunca** accede a la base de datos: solo consume la API REST.
  - La API **no** contiene lógica de negocio: views y serializers solo
    validan y serializan.
  - La lógica de negocio vive **únicamente** en `services.py` (única fuente
    de verdad: disponibilidad, superposición, estados, vencimientos).
  - Los modelos definen estructura e integridad; no implementan reglas de
    negocio.

## 4. Base de datos

- **SQLite** (`src/BackEnd/db/db.sqlite3`) para desarrollo local.
  **PostgreSQL** cuando se escale (hosting público / varios usuarios
  concurrentes). El archivo `db.sqlite3` no se versiona ni se usa en
  producción.
- La integridad anti doble reserva se garantiza **a nivel de base de datos**:
  índice único parcial en `ReservaCancha` + transacciones con
  `select_for_update()`. Toda escritura sobre reservas pasa por
  `services.py` dentro de esa transacción.
- Las migraciones se versionan junto con el código y se aplican con
  `manage.py migrate`.

## 5. Estructura de carpetas (obligatoria)

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

## 6. Convenciones

- **Autenticación:** sesión sin CSRF para la API; login por email
  (`USERNAME_FIELD="email"`, sin `username`).
- **Configuración sensible:** solo por variables de entorno
  (`DJANGO_SECRET_KEY`, `DJANGO_DEBUG`, `DJANGO_ALLOWED_HOSTS`); nunca
  hardcodeada en el repositorio.
- **CORS:** solo orígenes de desarrollo de la app móvil, con credenciales.
- **Dependencias:** backend en `requirements.txt`, mobile en `pubspec.yaml`.
- **Flutter:** un solo mecanismo de estado por feature; cliente HTTP con
  manejo de sesión por cookie.
