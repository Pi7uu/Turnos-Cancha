# AGENTS.md

> Project purpose: see `overview.md`.

## Architecture

Django backend + Flutter mobile app: Django expone solo `/api/` y `/admin/`. La app Flutter consume la API REST. Las reservas (turnos) son el dominio central.

- **Backend:** `src/BackEnd/config/` (proyecto Django), `src/BackEnd/apps/turnos/` (main app) — correr Django desde `src/BackEnd/`
- **Mobile:** `src/FrontEnd/` (Flutter, Dart) — proyecto `turnos_cancha` creado funciona; login y registro locales (specs `docs/HistRequerimientos/login.md` y `docs/HistRequerimientos/registro.md`) + navegación principal (spec `docs/HistRequerimientos/navegacion.md`) + Inicio completo, Detalle completo y flujo de reserva completo (specs `docs/HistRequerimientos/inicio-*.md`, `detalle-*.md`, `reserva-*.md`). Specs as-built en `Specs/`
- **Database:** SQLite local (`src/BackEnd/db/db.sqlite3`); seed fixture pendiente (`apps/turnos/fixtures/initial_data.json`)
- **Locale:** Spanish (`es-AR`), all UI text and API messages in Spanish

## Estado actual (2026-11-12)

- ✅ Backend recreado: `config/`, modelos (`models.py`) + migración `0001_initial`, `auth.py` (sesión sin CSRF). Documentado en `docs/requerimientos/funcional-backend.md` (corte 2026-10-08)
- ✅ Login Flutter implementado (RD 2026-10-15): pantallas 04/04b, credenciales hardcodeadas (`igpi7uu@gmail.com`/`igpi7uu` en `lib/features/auth/credenciales.dart`), el login exitoso entra al shell con tab bar (ver fila 2026-11-12), tests de widgets. Sin HTTP ni persistencia de sesión (por spec de esa etapa)
- ✅ Verificación 2026-10-29: Flutter 3.47.9 stable instalado en `%USERPROFILE%\flutter` (⚠️ ruta desactualizada — ver fila 2026-11-05: `C:\src\flutter`; ⚠️ no está en PATH; invocar `%USERPROFILE%\flutter\bin\flutter.bat`). `flutter analyze` sin issues y `flutter test`: 19/19 tests pasan. Verificación visual por CDP/Chrome a 375×844 @2x (sin Android SDK): wireframes 04, 04b y pantalla `usuario validado` renderizan conforme al spec; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\`
- ✅ Registro Flutter implementado (RD 2026-11-05): pantalla 05 "Crear cuenta" con validación inline, checkbox de términos y alta en la lista de usuarios en memoria (`lib/features/auth/usuarios_locales.dart`); el footer "Crear cuenta" del 04 navega a la 05 y el alta vuelve con el aviso `Cuenta creada`. Sin HTTP ni persistencia (registro en memoria, por spec de esa etapa); tests de widgets
- ✅ Verificación 2026-11-05: Flutter 3.47.9 stable en `C:\src\flutter` (⚠️ no está en PATH; invocar `C:\src\flutter\bin\flutter.bat`). `flutter analyze` sin issues y `flutter test`: 54/54 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: login 04, registro 05 (formulario, errores, checkbox marcado, campo con foco) y snackbar `Cuenta creada` renderizan conforme al RD; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\t7\`
- ✅ Navegación Flutter implementada (RD 2026-11-12): Tab Bar del mockup (4 tabs: Inicio / Mis reservas / Favoritos / Perfil, activo con pill `primarySoft`) + `MainShell` con `IndexedStack` (4 placeholders precargados); el login exitoso entra al shell y se eliminó la pantalla "usuario validado" (`lib/features/navegacion/`). Sin dependencias nuevas
- ✅ Verificación 2026-11-12: Flutter en `C:\src\flutter`. `flutter analyze` sin issues y `flutter test`: 68/68 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: login → shell con tab Inicio activo, cambio entre los 4 tabs, y flujo de registro con snackbar `Cuenta creada` conforme al RD; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\navegacion\`
- ✅ Header del Inicio implementado (RD 2026-11-17): marca `TurnosCancha` + campana con badge + perfil sobre la pantalla Inicio (`lib/features/inicio/inicio_screen.dart`); campana y perfil sin funcionalidad (por spec). El tab Inicio deja de ser placeholder
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 73/73 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: header conforme al RD §4 (logo 34×34, badge rojo con borde blanco), taps de campana/perfil sin efecto, otros tabs vacíos; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-header\`
- ✅ Buscador del Inicio implementado (RD 2026-11-17): campo `Buscá canchas cerca tuyo...` bajo el header, editable, con lupa y geometría del mockup; sin filtrado aún (llega con la lista de canchas); la acción "search" del teclado y los taps de campana/perfil siguen inertes. Specs as-built en `Specs/`
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 79/79 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: campo con placeholder exacto, texto ingresado reemplaza el hint y se conserva tras tap fuera; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-buscador\`
- ✅ Selector de fecha del Inicio implementado (RD 2026-11-17): bloque `Elegí la fecha` + `Octubre ▾` + 5 chips fijos (LUN 14…VIE 18) con selección local (MAR 15 por defecto, se conserva al cambiar de tab); mes inerte por spec
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 86/86 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: bloque conforme al RD §4, MAR 15 activo, selección cambia al tocar MIÉ y se conserva al volver de otro tab; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-fecha\`
- ✅ Tarjetas de canchas del Inicio implementadas (RD 2026-11-17): bloque `Canchas disponibles` + `Ver todo` y 3 cards (foto, nombre, tag 5v5/7v7, distancia, rating, precio, `Reservar`) con datos simulados (`lib/features/inicio/cancha.dart`) y fotos del mockup como assets; card y botón inertes por spec; pantalla con scroll
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 95/95 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: 3 cards con fotos reales conforme al mockup, scroll completo, taps inertes sin cambios; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-canchas\`
- ✅ Categorías del Inicio implementadas (RD 2026-11-17): bloque `Categorías` con 2 chips (`Fútbol 5`/`Fútbol 7`, glyphs users/layout-grid en caja verde) repartidos por igual; chips inertes por spec. **El layout de la pantalla 01 queda completo**
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 100/100 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: bloque conforme al RD §4, chips con glyphs y labels correctos, taps sin cambios; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\inicio-categorias\`
- ✅ Detalle de cancha · parte 1 implementado (RD 2026-11-17): hero (foto + botones volver/compartir/favorito), badge PREMIUM + rating + precio, nombre y dirección (`lib/features/detalle/detalle_screen.dart`); las cards y `Reservar` del Inicio abren el Detalle (cambio de alcance del RD inicio-canchas) y Volver conserva el estado del Inicio; modelo `Cancha` +direccion/puntuacion/premium/hero
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 109/109 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: Detalle de Elite y Municipal (sin badge) conforme al mockup, botones del hero en posición, Volver conserva buscador y día; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\detalle-hero\`
- ✅ Detalle de cancha · parte 2 implementado (RD 2026-11-17): bloque `Comodidades` con 5 ítems (estados disponible/no disponible según la cancha) + aviso ámbar generado (`Estacionamiento y WiFi no disponibles hoy` en Skyline) y bloque `Sobre esta cancha`; modelo `Cancha` +comodidadesNoDisponibles/descripcion
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 116/116 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: Elite con las 5 comodidades y párrafo, Skyline con Estac./WiFi atenuadas y aviso, conforme al frame 07 del mockup; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\detalle-comodidades\`
- ✅ Detalle de cancha · parte 3 implementado (RD 2026-11-17): bloque `Elegí el horario` con 6 slots (disponible/seleccionado/ocupado, selección real default 19:00) y barra fija `PRECIO TOTAL` + `Confirmar reserva` (inerte por spec); fecha del bloque derivada del día elegido en el Inicio; **la pantalla 02 queda completa**. Modelo `Cancha` +horasOcupadas
- ✅ Verificación 2026-11-17: `flutter analyze` sin issues y `flutter test`: 124/124 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: horarios con 19:00/21:00 según mockup, selección cambia al tocar 20:00, fecha `Mié, 16 oct` refleja el día elegido, barra con `Confirmar reserva` completo; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\detalle-horarios\`
- ✅ Reserva exitosa implementada (RD 2026-11-18): pantalla `¡Reserva exitosa!` (ilustración, N° de orden generado `#GB-######`, `PAGADO`, precio, aviso) con navegación real — `Ver mis reservas` abre el shell en ese tab (MainShell +tabInicial) y `Volver al inicio` conserva el estado; `Confirmar reserva` del Detalle la abre con cancha/fecha/hora. **Flujo central vivo de punta a punta**
- ✅ Verificación 2026-11-18: `flutter analyze` sin issues y `flutter test`: 133/133 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: pantalla conforme al mockup `Contenido` con datos de la reserva (Elite, 16 de octubre, 20:00, #GB-882910, $45.00) y `Ver mis reservas` abriendo el tab; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\reserva-exitosa\`
- ✅ Error de reserva implementado (RD 2026-11-25): pantalla `No se pudo completar la reserva` (frame 10 del mockup: círculo X, card MOTIVO/SIN COBRO/ALTERNATIVAS derivado, nota) + regla de éxito/error del `Confirmar reserva` (`horasEnConflicto`: Elite 18:00) + `Elegir otro horario` vuelve al Detalle con la selección viva. **Flujo de reserva completo (éxito + error)**
- ✅ Verificación 2026-11-25: `flutter analyze` sin issues y `flutter test`: 142/142 tests pasan. Verificación visual por CDP (Edge headless) a 375×844 @2x: error idéntico al frame 10 (Elite 18:00, `2 canchas libres`), `Elegir otro horario` conserva la selección, cambiar a 20:00 abre el éxito; capturas en `%LOCALAPPDATA%\Temp\opencode\shots\reserva-error\`
- ⏳ Pendiente: `services.py`, API `/api/`, fixtures/seed, comando `vencer_reservas`, `tests.py` (backend), persistencia de sesión y login contra `/api/auth/login/` en Flutter, estado "sin canchas" (06) y filtrado del Inicio, y las pantallas Mis reservas, Favoritos, Perfil

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
- **Verificación visual (CDP/Edge):** el engine web debug puede congelar el árbol de semántica de CDP (assert `_computeOnScreenKeyboardInsets`) al enfocar campos con viewport emulado — verificar con coordenadas + capturas; y Edge nuevo puede renderizar dígitos espaciados por fallback de fuente (solo en web; en dispositivo es correcto). Relacionado con Inter pendiente de configurar.
- CORS allows mobile dev origins/emulators with credentials.
- `requirements.txt` has no lockfile — install directly.
