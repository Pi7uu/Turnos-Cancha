# Spec — API REST · autenticación y login real

> SDD as-built del RD `docs/HistRequerimientos/api-auth.md` ( 2026-11-25 ).
> **Primer pedazo de la fase backend**: la app ya no valida credenciales
> localmente — el login y el registro son reales.

## 1. Qué quedó implementado

| RF | Implementación | Dónde |
|---|---|---|
| RF-01 | API de auth con sesión Django: `POST /api/auth/registro/`, `POST /api/auth/login/`, `POST /api/auth/logout/`, `GET /api/auth/perfil/` | `apps/turnos/api.py`, `serializers.py`, `urls.py` ( + `config/urls.py` ) |
| RF-02 | Flutter consume la API: pantalla 04 → `login`, pantalla 05 → `registro`; spinner en los botones; errores en español ( inline 04b / bajo el botón ) | `lib/core/api/api_client.dart`, `login_screen.dart`, `registro_screen.dart` |

## 2. Decisiones ( del RD §8 )

- **DRF + `SessionSinCSRF`** ( `auth.py` ) — sesión Django por cookie
  `sessionid`. `perfil`/`logout` hacen chequeo manual de sesión para
  responder `401` ( `IsAuthenticated` devuelve `403` con
  `SessionAuthentication`, que no tiene `authenticate_header` ).
- **Cliente Flutter**: paquete `http` (**primera dependencia nueva** de la
  app). `ApiClient` con `http.Client` inyectable ( tests con `MockClient` ),
  `baseUrl` configurable ( default `http://127.0.0.1:8000` en web /
  `http://10.0.2.2:8000` en dispositivo ) y guarda la cookie `sessionid` del
  `set-cookie` para los siguientes requests. En la web el header `set-cookie`
  no llega a Dart — las cookies las maneja el navegador ( con
  `withCredentials` pendiente para CORS cross-origin; hoy el flujo de auth
  funciona igual porque el login solo navega ).
- **Stores locales eliminados**: `credenciales.dart`, `usuarios_locales.dart`
  y sus tests. `validacion_registro.dart` pierde el chequeo de duplicados (
  lo hace la API con `Ya existe una cuenta con ese email.` ).
- **Mensajes**: la UI conserva el texto del wireframe 04b
  ( `El mail o la contraseña son incorrectos` ) para credenciales inválidas;
  el resto de los errores muestra el mensaje del cliente/servidor (
  `No se pudo conectar. Intentá de nuevo.` para red ).
- **Email normalizado en el backend** ( `strip` + minúsculas ) en login y
  registro — conserva el login case-insensitive del flujo local ( test
  `login_normaliza_email` ).
- **El registro de la API crea la sesión** ( como el login ); `nombre`
  default = parte local del email. Nunca se devuelve la contraseña (
  `UsuarioSerializer` solo `id/email/nombre` ).

## 3. Verificación

- **Backend**: `python manage.py test` — **10/10** ( los 4 endpoints en
  éxito y error + normalización de email + hash de contraseña + cookie de
  sesión ).
- **Flutter**: `flutter analyze` sin issues; `flutter test` — **179/179**
  ( 6 nuevos del `ApiClient` con `MockClient`; los tests de widgets usan
  `test/api_mock.dart`, un mock del backend con sesión y usuarios ).
- **Integración real** ( Django `runserver` + Flutter web + CDP, 375×844 @2x,
  `%LOCALAPPDATA%\Temp\opencode\shots\api-auth\` ): contraseña incorrecta →
  estado 04b desde el `401` real ( `aa-01` ); credenciales válidas creadas
  por la API → **entra al shell** ( `aa-02` ). Smoke HTTP previo con
  `Invoke-RestMethod`: registro `201`, login case-insensitive `200`, perfil
  con cookie `200`, login inválido `401` con mensaje en español.

## 4. Lecciones

- **`IsAuthenticated` ≠ 401 siempre**: con `SessionAuthentication` (
  sin `authenticate_header` ) DRF responde `403` al no estar autenticado.
  Para controlar el código, chequeo manual en la vista.
- **Parámetros default no constantes**: `this.baseUrl = defaultBaseUrl`
  no compila si `defaultBaseUrl` es un getter — resolver en el
  inicializador ( `baseUrl = baseUrl ?? defaultBaseUrl` ).
- **CDP `type` agrega al texto existente**: para repetir un flujo con otros
  datos hay que recargar la app entre escenarios ( o limpiar el campo );
  si no, los textos se apilan y el login falla por un motivo falso.

## 5. Límites ( qué NO hace )

- Sin persistencia de sesión entre arranques ( la cookie vive en el
  `ApiClient` de la sesión; en web depende del navegador ).
- Sin recuperación de contraseña ni verificación de email.
- El resto de las pantallas siguen con datos simulados ( canchas, reservas,
  favoritos, perfil ) — próximos RDs de la fase backend.

## 6. Conexiones

- El login entra al `MainShell` como siempre; `Cerrar sesión` de Perfil
  vuelve a la 04 ( su `logout` contra la API queda para el RD de perfil
  real ).
- Próximos RDs: API de canchas + fixtures/seed; API de reservas +
  `services.py` ( anti doble reserva ) + `vencer_reservas`; integración de
  Inicio / Detalle / Mis reservas / Favoritos / Perfil con la API.

## 7. Pendiente ( fase backend )

- `services.py` + API de reservas + fixtures + `vencer_reservas` +
  integración de pantallas + persistencia de sesión + logout real en Perfil.
