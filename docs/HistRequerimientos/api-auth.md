# Requerimientos — API REST · autenticación y login real ( fase backend, parte 1 )

**Fecha:** 2026-11-25
**Estado:** Listo para implementar ( ciclo autónomo: sin aprobación intermedia )
**Fuentes de diseño:**
- `docs/requerimientos/funcional-backend.md` ( corte 2026-10-08 ) — §1 Usuarios y acceso
- `src/BackEnd/apps/turnos/models.py` — `Usuario` ( login por email, `USERNAME_FIELD="email"` ), `UsuarioManager`, `auth.py` ( sesión sin CSRF )

---

## 1. Objetivo

Primer pedazo de la fase backend: la **API REST de autenticación** ( login,
registro, logout, perfil ) y que la **app Flutter haga login real contra
ella** ( reemplaza las credenciales hardcodeadas y los usuarios en memoria ).

## 2. Contexto

- El backend tiene modelos + migración + `auth.py` ( autenticación por
  sesión sin CSRF ) + `/admin/`, pero **ningún endpoint `/api/`**.
- Flutter valida el login contra `credenciales.dart` y registra en
  `usuarios_locales.dart` ( en memoria, por specs de esas etapas ).
- `requirements.txt` ya incluye `djangorestframework` y
  `django-cors-headers` ( CORS habilitado para orígenes móviles/emuladores
  con credenciales ).

## 3. Alcance

### Dentro del alcance

- **API de autenticación** ( RF-01, DRF + sesión ): `POST /api/auth/registro/`,
  `POST /api/auth/login/`, `POST /api/auth/logout/`, `GET /api/auth/perfil/`.
- **Flutter consume la API** ( RF-02 ): login ( pantalla 04 ) y registro
  ( pantalla 05 ) llaman a la API; los errores se muestran en español.
- **Tests**: `src/BackEnd/apps/turnos/tests.py` ( API ) y tests de widgets de
  Flutter con cliente HTTP simulado.

### Fuera de alcance

- Recuperación de contraseña, verificación de email, refresh de sesión.
- El resto de la API ( canchas, reservas, configuración ) — próximos RDs.
- Migración de datos locales a la BD ( los stores en memoria quedan sin uso
  en el flujo de auth, se eliminan sus archivos ).

## 4. Especificación de la API

Sesión Django ( cookie `sessionid` ), JSON, mensajes de error en español.

| Endpoint | Body | Éxito | Error |
|---|---|---|---|
| `POST /api/auth/registro/` | `{email, password, nombre?}` | `201` `{id, email, nombre}` + sesión iniciada | `400` `{error}` ( email existente, datos inválidos ) |
| `POST /api/auth/login/` | `{email, password}` | `200` `{id, email, nombre}` + sesión | `401` `{"error": "Email o contraseña incorrectos."}` |
| `POST /api/auth/logout/` | — | `204` | `401` si no hay sesión |
| `GET /api/auth/perfil/` | — | `200` `{id, email, nombre}` | `401` si no hay sesión |

- `nombre`: si no viene, se usa la parte local del email ( antes de la `@` ).
- CSRF deshabilitado para la API ( ya configurado en `auth.py` ).
- Sin contraseñas en ninguna respuesta.

## 5. Requerimientos funcionales

### RF-01 — API de autenticación

- Endpoints de §4 implementados con DRF ( `SessionAuthentication` ) sobre
  `Usuario`/`UsuarioManager` ( login por email ).
- El registro crea el usuario con `create_user` ( hash de contraseña ) y deja
  la sesión iniciada. `tests.py` cubre los 4 endpoints ( éxito y error ).

### RF-02 — Login real en Flutter

- La pantalla 04 llama a `/api/auth/login/` ( reemplaza `credenciales.dart` );
  éxito → entra al shell ( como hoy ); `401` → mensaje `Email o contraseña
  incorrectos.` bajo el campo de contraseña.
- La pantalla 05 llama a `/api/auth/registro/` ( reemplaza
  `usuarios_locales.dart` ); éxito → vuelve al login con el aviso
  `Cuenta creada` ( como hoy ); `400` por email existente → error inline
  `Ya existe una cuenta con ese email.`
- Estados de carga: los botones muestran progreso ( spinner ) durante el
  request; errores de red → `No se pudo conectar. Intentá de nuevo.`

## 6. Requerimientos no funcionales

- **Backend:** DRF + `SessionAuthentication`; JSON; mensajes en español;
  tests con `APITestCase` ( BD en memoria ).
- **Flutter:** cliente HTTP con el paquete `http` (**primera dependencia
  nueva** de la app — documentado); `ApiClient` con `baseUrl` configurable
  ( default `http://10.0.2.2:8000` para emulador Android / `127.0.0.1`
  según plataforma ). Sin persistencia de sesión todavía ( la cookie vive
  en el cliente por sesión de la app ).
- **Idioma:** todos los mensajes de error en español (`es-AR`).

## 7. Criterios de aceptación

1. `POST /api/auth/login/` con credenciales válidas responde `200` con el
   usuario y setea la cookie de sesión; con inválidas responde `401` con
   `Email o contraseña incorrectos.`
2. `POST /api/auth/registro/` crea el usuario ( la contraseña queda con
   hash ), inicia la sesión y responde `201`; con un email repetido
   responde `400` con `Ya existe una cuenta con ese email.`
3. `GET /api/auth/perfil/` con sesión responde el usuario; sin sesión
   responde `401`. `POST /api/auth/logout/` cierra la sesión (`204`).
4. En Flutter, el login con credenciales válidas entra al shell y con
   inválidas muestra el error en español; el registro duplicado muestra el
   error inline.
5. `flutter analyze` sin issues; suite de Flutter y de Django en verde.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| API framework | DRF ( ya en `requirements.txt` ) con `SessionAuthentication` + CSRF deshabilitado ( `auth.py` ) |
| Cliente HTTP Flutter | Paquete `http` ( primera dependencia nueva de la app; no hay alternativa sin dependencias ) |
| Stores locales | `credenciales.dart` y `usuarios_locales.dart` se **eliminan** ( sus specs eran de esas etapas ); sus tests se reemplazan por los del cliente API |
| Sesión Flutter | Cookie del cliente `http` ( `Client` con cookie jar manual ) — persistencia entre arranques queda para después |
| `nombre` del usuario | Parte local del email si no viene en el body |
| Errores | JSON `{"error": "..."}` en español; el login jamás revela si el email existe |

## 9. Riesgos y notas para la siguiente iteración

- Próximos RDs de la fase: API de canchas + fixtures/seed; API de reservas +
  `services.py` ( anti doble reserva, `ocupando` ) + `vencer_reservas`;
  integración de las pantallas con la API ( Inicio, Detalle, Mis reservas,
  Favoritos, Perfil ); persistencia de sesión.
- CORS ya está habilitado para emuladores; para web habilitar el origen del
  dev server si se prueba desde Chrome.
