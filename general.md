# Turnos Futbol — Plan del proyecto

App móvil para gestionar turnos de alquiler de una cancha de **fútbol 7** que se puede dividir en **dos canchas de fútbol 5**.

- **Frontend:** app móvil en Flutter
- **Backend:** Django + Django REST Framework (decidido)
- **Pagos:** fuera del alcance inicial, pero el diseño queda preparado para agregarlos

---

## 1. Objetivo

Que los clientes puedan ver la disponibilidad y reservar turnos desde el celular, y que el administrador pueda controlar la agenda sin llevar todo a mano.

---

## 2. Roles de usuario

### Cliente
- Se registra e inicia sesión con **email y contraseña**
- Ve la disponibilidad por día y tipo de cancha (F5 o F7)
- Reserva un turno
- **Confirma** su reserva desde la app con un botón
- Cancela su reserva (hasta 24 h antes del turno)
- Ve su historial y sus reservas próximas

### Administrador
- Ve la agenda completa (por día y por cancha)
- Puede cancelar cualquier reserva
- Puede cargar reservas manuales (por ejemplo, clientes que llaman por teléfono)
- Ve el listado de clientes y su historial

---

## 3. Reglas de negocio

### 3.1 Canchas y superposición

Hay una cancha física de F7 que se divide en dos mitades de F5:

```
┌───────────────┬───────────────┐
│   F5 - A      │   F5 - B      │
└───────────────┴───────────────┘
└─────────────────── F7 ────────┘
```

| Se reserva | Queda bloqueado en ese horario |
|------------|--------------------------------|
| F7         | F7, F5-A y F5-B                |
| F5-A       | F5-A y F7 (F5-B sigue libre)   |
| F5-B       | F5-B y F7 (F5-A sigue libre)   |

Se pueden reservar F5-A y F5-B al mismo tiempo (por clientes distintos), y en ese caso F7 queda bloqueada.

### 3.2 Turnos
- Duración fija de **1 hora**
- Los horarios de inicio se definen en la configuración

### 3.3 Ciclo de vida de una reserva

```
PENDIENTE ──(cliente confirma)──▶ CONFIRMADA
    │                                 │
    ├─(vence el plazo)──▶ VENCIDA     └─(cancela cliente/admin)──▶ CANCELADA
    └─(cancela)─────────▶ CANCELADA
```

- Al reservar, queda en estado **PENDIENTE** y ya bloquea la cancha.
- El cliente debe **confirmar** desde la app.
- Si no confirma hasta **24 h antes del turno**, pasa a **VENCIDA** y el horario se libera.
- El cliente puede **cancelar libremente hasta 24 h antes** del turno. Después de ese límite, solo el admin puede cancelar.
- Si la reserva se hace con **menos de 24 h** de anticipación (el plazo de vencimiento ya pasó), nace **CONFIRMADA** directamente.

## 5. Arquitectura





```
┌──────────────┐   HTTPS / JSON    ┌──────────────┐     ┌──────────────┐
│  App Flutter │ ────────────────▶ │   API REST   │ ──▶ │    SQLite    │
│ (cliente y   │ ◀──────────────── │  (propia)    │     └──────────────┘
│  admin)      │                   │              │ ──▶ Tarea periódica
└──────────────┘                   └──────┬───────┘     (vencimientos)
                                          │
                                          └──▶ WhatsApp Business API
```

### 5.1 Backend (decidido)
- **Stack:** Django + Django REST Framework (la opción Node se descarta)
- **Base de datos:** SQLite local por ahora; PostgreSQL cuando se escale (hosting / varios usuarios)
- Autenticación con **sesión** (cookie), CSRF deshabilitado para la API móvil
- Vencimientos: comando `vencer_reservas` + ejecución perezosa; tarea programada cuando haya hosting
- Para evitar reservas dobles: transacción + restricción en la base de datos (índice único parcial en `ReservaCancha`)

### 5.2 App Flutter (propuesta a confirmar)
- Organización por funcionalidades (`features/auth`, `features/reservas`, `features/admin`)
- Gestión de estado: **Riverpod** (o Bloc, a elegir)
- Navegación: `go_router`, con rutas protegidas según rol
- Cliente HTTP: `dio` con manejo de sesión por cookie

---

## 6. Modelo de datos (borrador)

**Usuario**
- id, nombre, email, teléfono, contraseña (hash), rol (`CLIENTE` | `ADMIN`)

**Cancha** (recurso físico)
- id, nombre (`F5-A`, `F5-B`), activa

**Reserva**
- id, usuario, tipo (`F5` | `F7`), fecha, hora_inicio, hora_fin, estado, creada_en, confirmada_en, cancelada_por
- Relación con las canchas físicas que ocupa: F5 → 1 cancha (A o B), F7 → las 2 canchas

> Ocupar canchas físicas (en vez de comparar tipos) hace que la regla del F7 salga sola: dos reservas no pueden ocupar la misma cancha física en el mismo horario.

**Configuración**
- horarios de atención, duración del turno, plazo de vencimiento (24 h), plazo de cancelación (24 h)


