# Requerimientos — Base de datos, scripts y backend

**Actualizado:** 2026-10-01
**Alcance:** estado actual del backend existente (Django + DRF en `src/backend/`). Documento vivo: cada requerimiento nuevo se agrega acá y se marca cuando se implementa.

---

## Cómo mantener este documento

Estados para cada requerimiento nuevo:

| Estado | Significado |
|--------|-------------|
| ✅ Implementado | Está escrito en el código y, si aplica, cubierto por tests |
| ⚠️ Parcial | Existe pero con limitaciones conocidas |
| ⏳ Pendiente | Definido acá, todavía no implementado |

Flujo: **definir el requerimiento en la sección 5 → implementarlo → marcarlo ✅ con fecha y referencia al código**. Si el backend o la base de datos cambian, actualizar también las secciones 1–4.

---

## 1. Base de datos

SQLite (`src/backend/db/db.sqlite3`). Esquema creado por migraciones (ver sección 2.1). Modelos de la app `turnos`: `Usuario`, `Cancha`, `Reserva`, `Configuracion` (más la tabla intermedia `reserva ↔ cancha` que genera el M2M).

### 1.1 Usuario

Extiende `AbstractUser` de Django (`apps/turnos/models.py`).

| Campo | Tipo | Notas |
|-------|------|-------|
| `email` | Email, **único** | Identificador de login |
| `telefono` | String(30) | Opcional |
| `rol` | String(10) | `CLIENTE` (por defecto) o `ADMIN` |
| `username` | String | Se guarda igual al email |
| `password` | Hash | PBKDF2 de Django |

- Propiedad `es_admin`: `True` si `rol == ADMIN` **o** `is_superuser`.
- Login con email + contraseña (ver `auth.py`); `REQUIRED_FIELDS = ["email"]`.

### 1.2 Cancha

Cancha física. La cancha F7 se divide en dos mitades F5.

| Campo | Tipo | Notas |
|-------|------|-------|
| `nombre` | String(10), **único** | `F5-A` o `F5-B` |
| `activa` | Boolean | Por defecto `True` |

- Orden por defecto: `nombre`.

### 1.3 Reserva

| Campo | Tipo | Notas |
|-------|------|-------|
| `usuario` | FK → Usuario (`CASCADE`) | Cliente dueño de la reserva |
| `tipo` | String(2) | `F5` o `F7` |
| `fecha` | Date | Día del turno |
| `hora_inicio` / `hora_fin` | Time | Duración fija (configuración) |
| `estado` | String(12) | `PENDIENTE` (defecto), `CONFIRMADA`, `VENCIDA`, `CANCELADA` |
| `canchas` | **M2M → Cancha** | Canchas físicas que ocupa (F5 → 1, F7 → 2) |
| `creada_en` | DateTime | Auto al crear |
| `confirmada_en` | DateTime, nullable | Se llena al confirmar |
| `cancelada_en` | DateTime, nullable | Se llena al cancelar o vencer |
| `cancelada_por` | FK → Usuario (`SET_NULL`) | Quién canceló |

- `ESTADOS_QUE_OCUPAN = (PENDIENTE, CONFIRMADA)`: solo estos estados bloquean horarios.
- Orden por defecto: `fecha`, `hora_inicio`.
- Propiedades calculadas: `plazo_limite` (inicio del turno menos `plazo_cancelacion_h`, 24 h por defecto) y `cliente_puede_cancelar` (estamos antes de ese límite).

### 1.4 Configuracion

Singleton (siempre `pk=1`, creado con `get_or_create` en `Configuracion.get_solo()`).

| Campo | Default | Significado |
|-------|---------|-------------|
| `horario_inicio` | 09:00 | Inicio de atención |
| `horario_fin` | 23:00 | Fin de atención |
| `duracion_turno_min` | 60 | Duración fija del turno (min) |
| `plazo_vencimiento_h` | 24 | Horas antes del turno para vencer pendientes |
| `plazo_cancelacion_h` | 24 | Horas antes del turno en que el cliente puede cancelar |
| `anticipacion_max_dias` | 30 | Días máximos de anticipación para reservar |

---

## 2. Scripts de BD

Todos los comandos se corren desde `src/backend/`.

### 2.1 Migraciones de esquema

```bash
python manage.py makemigrations   # genera migraciones si cambian los modelos
python manage.py migrate          # crea/actualiza las tablas
```

- Existe `apps/turnos/migrations/0001_initial.py`: crea los modelos de la sección 1.

### 2.2 Seed / datos iniciales

```bash
python manage.py loaddata apps/turnos/fixtures/initial_data.json
```

`apps/turnos/fixtures/initial_data.json` carga:

- **Usuario admin:** `admin@turnos.com` (superusuario, rol `ADMIN`, contraseña hasheada).
- **Canchas:** `F5-A` y `F5-B`, ambas activas.
- **Configuración:** horarios 09:00–23:00, turno de 60 min, plazos de 24 h, anticipación 30 días.

### 2.3 Comando de mantenimiento

```bash
python manage.py vencer_reservas   # marca VENCIDA toda reserva pendiente vencida
```

- Implementado en `apps/turnos/management/commands/vencer_reservas.py`.
- El mismo proceso (`vencer_reservas_pendientes()` de `services.py`) se ejecuta automáticamente al consultar disponibilidad, crear una reserva y confirmar una reserva.

---

## 3. Backend API

Django + DRF, prefijo **`/api/`** (`config/urls.py`). Django admin en `/admin/`.

### 3.1 Autenticación y roles

- **Sesión** (cookie de sesión) con CSRF deshabilitado para la API (clientes móviles).
- Login con **email + contraseña** (`auth.py: autenticar_por_email`).
- Roles: `CLIENTE` y `ADMIN`. Los endpoints `admin/*` usan la clase `SoloAdmin` (requiere sesión + rol ADMIN o superusuario).
- CORS permite orígenes de desarrollo móvil (ver AGENTS.md).

### 3.2 Endpoints

**Auth**

| Método | Ruta | Acceso | Descripción |
|--------|------|--------|-------------|
| POST | `/api/auth/registro/` | Público | Crea cliente (email, password, nombre, teléfono) y lo loguea. 201 |
| POST | `/api/auth/login/` | Público | Login por email. 400 si credenciales malas |
| POST | `/api/auth/logout/` | Sesión | Cierra sesión |
| GET | `/api/auth/me/` | Sesión | Datos del usuario logueado |

**Cliente**

| Método | Ruta | Acceso | Descripción |
|--------|------|--------|-------------|
| GET | `/api/disponibilidad/?fecha=YYYY-MM-DD` | Sesión | Slots del día con `f5_a`, `f5_b`, `f7` libres/ocupados. 400 si fecha inválida |
| POST | `/api/reservas/` | Sesión | Crea reserva **PENDIENTE** (`tipo`, `fecha`, `hora_inicio`, `cancha` si F5). 201 / 409 si horario ocupado |
| GET | `/api/reservas/mias/` | Sesión | Reservas del usuario logueado |
| POST | `/api/reservas/{id}/confirmar/` | Dueño | Pasa a CONFIRMADA. 404 si es ajena, 409 si venció |
| POST | `/api/reservas/{id}/cancelar/` | Dueño o admin | Pasa a CANCELADA. 403 si otro usuario o plazo vencido (solo admin en ese caso) |

**Admin**

| Método | Ruta | Acceso | Descripción |
|--------|------|--------|-------------|
| GET | `/api/admin/agenda/?fecha=YYYY-MM-DD[&cancha=F5-A]` | Admin | Reservas del día (todas, con cliente y estado) |
| POST | `/api/admin/reservas/` | Admin | Reserva manual: define `cliente_email` (crea el usuario si no existe) y `confirmada` (default true) |
| GET | `/api/admin/clientes/` | Admin | Listado de clientes |
| GET | `/api/admin/clientes/{id}/reservas/` | Admin | Historial de reservas de un cliente |
| GET/PUT | `/api/admin/configuracion/` | Admin | Lee/actualiza la configuración singleton |

Errores: `{"detalle": "..."}` con 400 (validación), 403 (permiso), 404 (no encontrado), 409 (conflicto de horario / estado vencido).

### 3.3 Reglas de negocio (`services.py`)

- **Superposición F5/F7 (§3.1 del plan):** cada reserva ocupa canchas físicas — F7 ocupa `F5-A` + `F5-B`; F5 ocupa solo la mitad elegida. La validación corre **dentro de una transacción** con `select_for_update()` sobre las canchas físicas, lo que serializa reservas concurrentes. Si hay choque → 409. Quedan libres las reservas `CANCELADA` y `VENCIDA`.
- **Disponibilidad:** un slot es `f7: true` solo si `f5_a` y `f5_b` están libres; se puede reservar F5-A y F5-B en el mismo horario (clientes distintos), y entonces F7 queda ocupado.
- **Slots:** se generan desde `horario_inicio` hasta `horario_fin` con la duración fija; `hora_inicio` debe coincidir con un slot, si no → 400.
- **Límites de fecha:** el cliente no puede reservar en el pasado ni con más de `anticipacion_max_dias` de anticipación. El admin no tiene esta restricción.
- **Ciclo de vida (§3.3 del plan):**
  - Crear → `PENDIENTE` (ya bloquea el horario).
  - Confirmar → `CONFIRMADA` (idempotente si ya estaba; 409 si venció).
  - Cancelar → `CANCELADA` con `cancelada_en` y `cancelada_por`. El cliente puede hasta `plazo_limite` (24 h antes); después solo el admin. Reservas ya `CANCELADA`/`VENCIDA` → 400.
  - Vencer → `VENCIDA` cuando una `PENDIENTE` está a menos de `plazo_vencimiento_h` del inicio.

### 3.4 Vencimientos

- `vencer_reservas_pendientes()` marca como `VENCIDA` toda pendiente cuyo plazo ya pasó y devuelve la cantidad afectada.
- Se invoca "perezosamente" en cada consulta de disponibilidad, creación y confirmación de reserva, además del comando manual `manage.py vencer_reservas`.

---

## 4. Verificación

```bash
cd src/backend
python manage.py test apps.turnos.tests
```

**18 tests** en `apps/turnos/tests.py`, organizados en:

- `SuperposicionTest` — F7 ocupa ambas mitades, F5 solo su mitad, horarios distintos no chocan, canceladas liberan.
- Ciclo de vida — creación pendiente, confirmación, cancelación dentro/fuera del plazo, admin cancela después del límite, vencimiento por plazo, no confirmar reservas ajenas.
- `disponibilidad_del_dia` — estado de los slots.
- API — registro/login/me, crear y confirmar reserva, disponibilidad requiere login, agenda admin, cliente no accede a admin, reserva manual del admin.

---

## 5. Registro de requerimientos nuevos

Agregar filas acá al definir un requerimiento; marcar ✅ al implementarlo, con fecha y referencia al archivo/cambio.

| Fecha | Requerimiento | Estado | Implementación |
|-------|---------------|--------|----------------|
| 2026-10-01 | Documento de requerimientos (BD, scripts, backend) | ✅ | `docs/specs/requerimientos-backend.md` |

*(Próximas filas van acá. El backlog completo de tareas sigue en `specs/status.md`.)*
