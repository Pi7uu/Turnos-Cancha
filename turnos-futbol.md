# Turnos Futbol — Plan del proyecto

App móvil para gestionar turnos de alquiler de una cancha de **fútbol 7** que se puede dividir en **dos canchas de fútbol 5**.

- **Frontend:** app móvil en Flutter
- **Backend:** API propia (a definir: Django REST Framework o Node)
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
- Los horarios de inicio se definen en la configuración (ver preguntas abiertas)

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

### 3.4 Alquiler fijo (a futuro)
Queda fuera de la primera versión. Se deja el modelo de datos abierto para poder agregar más adelante una reserva recurrente (por ejemplo, todos los martes a las 21 h).

---

## 4. Funcionalidades por etapa

### Etapa 1 — MVP
- [ ] Registro, login y roles (cliente / admin)
- [ ] Configuración de canchas y horarios
- [ ] Ver disponibilidad por día
- [ ] Crear reserva (F5-A, F5-B o F7) con validación de superposición
- [ ] Confirmar y cancelar reserva
- [ ] Vencimiento automático de reservas pendientes
- [ ] Panel del admin: agenda del día y cancelaciones
- [ ] Mis reservas (cliente)

### Etapa 2
- [ ] Avisos por WhatsApp (recordatorio para confirmar, turno próximo, cancelación)
- [ ] Reservas manuales cargadas por el admin
- [ ] Historial y filtros en el panel del admin

### Etapa 3 (a futuro)
- [ ] Alquiler de cancha fija (recurrente)
- [ ] Pagos / señas (Mercado Pago u otro)
- [ ] Reportes de ocupación

---

## 5. Arquitectura propuesta

```
┌──────────────┐   HTTPS / JSON    ┌──────────────┐     ┌──────────────┐
│  App Flutter │ ────────────────▶ │   API REST   │ ──▶ │  PostgreSQL  │
│ (cliente y   │ ◀──────────────── │  (propia)    │     └──────────────┘
│  admin)      │                   │              │ ──▶ Tarea periódica
└──────────────┘                   └──────┬───────┘     (vencimientos)
                                          │
                                          └──▶ WhatsApp Business API
```

### 5.1 Backend (propuesta a confirmar)
- **Opción A:** Django + Django REST Framework + PostgreSQL
- **Opción B:** Node (NestJS o Express) + PostgreSQL
- Autenticación con **JWT** (access + refresh token)
- Tarea programada (cron / Celery / equivalente) que cada pocos minutos marca como `VENCIDA` las reservas pendientes que pasaron su plazo
- Para evitar reservas dobles: validar la superposición **dentro de una transacción** y reforzar con una restricción en la base de datos

### 5.2 App Flutter (propuesta a confirmar)
- Organización por funcionalidades (`features/auth`, `features/reservas`, `features/admin`)
- Gestión de estado: **Riverpod** (o Bloc, a elegir)
- Navegación: `go_router`, con rutas protegidas según rol
- Cliente HTTP: `dio` con interceptor para el token
- Guardado seguro del token: `flutter_secure_storage`

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

---

## 7. Endpoints principales (borrador)

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/auth/registro` | Crear cuenta de cliente |
| POST | `/auth/login` | Iniciar sesión |
| GET | `/disponibilidad?fecha=YYYY-MM-DD` | Horarios libres por tipo de cancha |
| POST | `/reservas` | Crear reserva (queda pendiente) |
| POST | `/reservas/{id}/confirmar` | Confirmar reserva |
| POST | `/reservas/{id}/cancelar` | Cancelar reserva |
| GET | `/reservas/mias` | Reservas del cliente |
| GET | `/admin/agenda?fecha=...` | Agenda del día (admin) |
| POST | `/admin/reservas` | Reserva manual (admin) |

---

## 8. Avisos por WhatsApp

- Se usaría la **WhatsApp Business Platform (Cloud API)**
- Los mensajes iniciados por el negocio requieren **plantillas aprobadas** y pueden tener costo
- Mensajes previstos:
  - Recordatorio de confirmar la reserva (antes de que venza)
  - Recordatorio del turno próximo
  - Aviso de reserva vencida o cancelada

---

## 9. Preguntas abiertas

- [ ] ¿Qué pasa si alguien reserva con **menos de 24 h** de anticipación? (si el vencimiento es 24 h antes, quedaría vencida al instante; ¿se confirma automáticamente en ese caso?)
- [ ] ¿Cuáles son los **horarios de atención** y los días que se alquila?
- [ ] ¿Hay **precios** distintos para F5 y F7 y se muestran en la app?
- [ ] ¿Con cuánta **anticipación máxima** se puede reservar (una semana, un mes)?
- [ ] ¿Hay **un solo admin** o varios?
- [ ] ¿Backend definitivo: Django o Node?
- [ ] ¿La app es solo Android o también iOS?
- [ ] ¿Dónde se va a alojar el backend (hosting)?

---

## 10. Próximos pasos

1. Cerrar las preguntas abiertas
2. Definir el stack del backend
3. Diseñar las pantallas principales (login, disponibilidad, reservar, mis reservas, agenda admin)
4. Armar el backend del MVP (usuarios, canchas, reservas, disponibilidad)
5. Armar la app Flutter del MVP
6. Probar la lógica de superposición F5 / F7 con casos de prueba
