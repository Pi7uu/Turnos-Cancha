# Documentación funcional — Backend implementado

**Corte:** 2026-10-08
**Alcance:** reglas de negocio y comportamiento que el código **ya implementa
y valida hoy**: `apps/turnos/models.py`, `apps/turnos/auth.py`,
`config/settings.py` y la migración `apps/turnos/migrations/0001_initial.py`.

Fuera de alcance: lógica de servicios (`services.py`) y API REST — todavía no
existen, por lo que este documento no los describe.

---

## 1. Usuarios y acceso

- **Identificación por email.** El modelo `Usuario` no tiene campo
  `username`: el login se hace con **email + contraseña**
  (`USERNAME_FIELD = "email"`, `REQUIRED_FIELDS = []`). El email es único en
  la tabla.
- **Gestión de usuarios.** `UsuarioManager` crea usuarios únicamente con
  email y contraseña (`create_user` / `create_superuser`); el email se
  normaliza (el dominio se pasa a minúsculas) y la contraseña se guarda
  hasheada con PBKDF2 (`pbkdf2_sha256`) de Django. Crear un usuario sin
  email lanza error.
- **Roles.** Cada usuario tiene rol `CLIENTE` (por defecto) o `ADMIN`.
  Regla de negocio: es administrador si su rol es `ADMIN` **o** si es
  superusuario de Django (propiedad `es_admin`).
- **Teléfono.** Opcional, hasta 30 caracteres.
- **Sesión sin CSRF.** La API autentica por cookie de sesión con CSRF
  deshabilitado (`SessionSinCSRF` en `auth.py`): la app móvil no participa
  del flujo CSRF. Los permisos por defecto de la API son
  `IsAuthenticatedOrReadOnly` (lectura anónima, escritura autenticada).

## 2. Canchas

- Solo existen canchas físicas **`F5-A`** y **`F5-B`** (nombre único, con
  opciones de presentación "Fútbol 5 - A/B").
- Cada cancha puede estar **activa** o inactiva (`activa`, activa por
  defecto); el orden por defecto es por nombre.
- `F7` **no** es una cancha física: existe únicamente como tipo de reserva
  (ver §3). La regla de que F7 ocupa ambas mitades no está implementada en
  este corte.

## 3. Reservas

### 3.1. Datos y estados

- Una reserva pertenece a un **usuario** (se borra en cascada si el usuario
  se elimina) y tiene **tipo** `F5` o `F7`.
- **Estados posibles:** `PENDIENTE` (estado inicial por defecto),
  `CONFIRMADA`, `VENCIDA`, `CANCELADA`. Las transiciones entre estados
  todavía no están implementadas.
- Marca temporal de creación automática (`creada_en`); `confirmada_en` y
  `cancelada_en` se guardan nulos hasta que algo los llene.
  `cancelada_por` registra quién canceló y **no** borra la reserva si ese
  usuario se elimina (`SET_NULL`).
- Orden por defecto de las reservas: por `fecha` y luego `hora_inicio`.

### 3.2. Regla: un horario no se puede ocupar dos veces (anti doble reserva)

Es la regla de negocio más importante implementada en este corte, y está
garantizada **por la base de datos**, no por código de aplicación:

- Cada reserva se vincula a las canchas físicas que ocupa mediante la tabla
  intermedia `ReservaCancha`, que guarda además `fecha` y `hora_inicio`
  **denormalizados** y un flag `ocupando` (nace en `True`).
- Restricción única parcial `slot_ocupado_unico`: la BD rechaza cualquier
  fila donde la misma combinación `(cancha, fecha, hora_inicio)` ya esté
  registrada con `ocupando = True`. Duplicar un horario falla aunque el
  código de aplicación tenga un error.
- Fila con `ocupando = False`: no cuenta como ocupación (el horario queda
  libre) pero la fila permanece como historial.
- El modelo declara `ESTADOS_QUE_OCUPAN = (PENDIENTE, CONFIRMADA)`: solo
  esos estados se consideran ocupación del dominio. La sincronización entre
  `estado` y `ocupando` no está implementada en este corte.

### 3.3. Regla: plazo de cancelación del cliente

- **`plazo_limite`** (propiedad de `Reserva`): el momento límite para
  cancelar/confirmar es **el inicio del turno menos `plazo_cancelacion_h`**
  horas (24 h por defecto, configurable).
- **`cliente_puede_cancelar`**: `True` mientras la hora actual sea anterior
  a ese `plazo_limite`. Después del límite, la cancelación queda restringida
  (quién puede cancelar después del plazo se defina en services/API, aún no
  implementado).

## 4. Configuración del sistema

- **Singleton:** siempre existe una única fila (`pk = 1`), obtenida con
  `Configuracion.get_solo()` — si no existe, se crea con los valores por
  defecto al primer acceso.
- Valores por defecto (todas las reglas de tiempo de este documento salen de
  acá):

| Campo | Default | Significado funcional |
|-------|---------|----------------------|
| `horario_inicio` | 09:00 | Inicio de atención |
| `horario_fin` | 23:00 | Fin de atención |
| `duracion_turno_min` | 60 | Duración fija de cada turno |
| `plazo_vencimiento_h` | 24 | Horas antes del turno para vencer pendientes (lógica pendiente) |
| `plazo_cancelacion_h` | 24 | Horas antes del turno del límite de cancelación del cliente (§3.3) |
| `anticipacion_max_dias` | 30 | Días máximos de anticipación para reservar (regla pendiente) |
