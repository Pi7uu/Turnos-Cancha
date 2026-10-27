# Requerimientos — Login ( pantallas 04 y 04b )

**Fecha:** 2026-10-15
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frames **"04 · Login"** y **"04b · Login · Error de autenticación"**
- `docs/prototipos/pantallas/04-login.png` (referencia estática de la pantalla 04)
- `docs/prototipos/mockups-turnoscancha.pdf` (completo)

---

## 1. Objetivo

Implementar la pantalla de login de la app móvil **Flutter** (`src/FrontEnd/`) con sus dos estados: formulario normal (**04**) y formulario con error de autenticación (**04b**). Por esta etapa la validación de credenciales es **local en la app (hardcodeada)**, sin llamar al backend Django.

## 2. Contexto

- La app Flutter todavía no existe: `src/FrontEnd/` está vacío. Crear el proyecto (`flutter create`) es parte del trabajo inicial de esta feature.
- La toolchain de Flutter **no está instalada** en la máquina de desarrollo (no hay `flutter`, Dart ni Android SDK). La instalación completa entra en el alcance de esta feature (ver §3).
- El backend Django ya tiene un modelo `Usuario` (login por email, roles `CLIENTE`/`ADMIN`) y autenticación por sesión sin CSRF preparada, pero **no** se usa en esta etapa: la API REST aún no existe y se decidió validar en la app.
- Único usuario válido de esta etapa:
  - **Email:** `igpi7uu@gmail.com`
  - **Contraseña:** `igpi7uu`

## 3. Alcance

### Dentro del alcance

- Pantalla **04 · Login** (estado normal del formulario).
- Pantalla **04b · Error de autenticación** (mismo formulario con estado de error).
- Validación local de credenciales contra el usuario único hardcodeado.
- Pantalla de éxito posterior al login (pantalla en blanco con el texto `usuario validado`).
- Toggle de visibilidad de la contraseña (ícono de ojo).
- Proyecto Flutter base en `src/FrontEnd/` (si todavía no existe).
- **Setup del entorno:** instalar Flutter, Android SDK y crear un emulador para poder verificar la pantalla visualmente corriendo la app.

### Fuera de alcance

- Pantalla **05 · Crear cuenta** y cualquier registro de usuarios (el link "Crear cuenta" **no** navega a ninguna parte por ahora).
- Recuperación de contraseña (el link "¿Olvidaste tu contraseña?" **no** tiene funcionalidad por ahora; solo se muestra, como en el wireframe).
- Endpoints de autenticación en Django / llamadas HTTP.
- Persistencia de sesión (al reiniciar la app se vuelve a la pantalla de login).
- Cualquier otra pantalla del prototipo (06 a 12).

## 4. Requerimientos funcionales

### RF-01 — Pantalla de login (wireframe 04)

Al iniciar la app se muestra la pantalla de login, compuesta por (de arriba hacia abajo):

| Elemento | Especificación |
|---|---|
| Marca | Logo cuadrado 44×44, fondo `$primary`, radio 13, ícono de pelota (Material Symbols `sports_soccer`) en blanco; al lado el texto `TurnosCancha` (22px, bold, `$primary`) |
| Título | `Iniciá sesión` — 28px, bold, `$text` |
| Subtítulo | `Reservá tu cancha en segundos` — 15px, `$text-2` |
| Campo Email | Label `Email` (13px, semibold); input con fondo `$surface`, borde `$border` 1px, radio 12, ícono `mail` (lucide) y placeholder `tu@email.com` |
| Campo Contraseña | Label `Contraseña`; mismo estilo de input, ícono `lock`, placeholder `Tu contraseña`, ícono de ojo (lucide `eye`) a la derecha |
| Link | `¿Olvidaste tu contraseña?` — 13px, `$primary`, alineado a la derecha. **Sin funcionalidad** (no hace nada al tocarlo) |
| Botón | `Ingresar` — ancho completo, fondo `$primary`, radio 12, texto blanco 16px semibold |
| Footer | `¿No tenés cuenta?` (14px, `$text-2`) + `Crear cuenta` (14px, semibold, `$primary`). **Sin funcionalidad** |

### RF-02 — Comportamiento del campo de contraseña

- El ícono de ojo alterna entre mostrar y ocultar la contraseña (por defecto oculta).
- Usar teclado adecuado para cada campo (email para el primero, contraseñas para el segundo) y acción "enviar" del teclado que dispare la misma validación que el botón `Ingresar`.

### RF-03 — Validación de credenciales

- Al tocar `Ingresar` (o enviar desde el teclado), la app compara los valores ingresados:
  - Email válido: `igpi7uu@gmail.com`
  - Contraseña válida: `igpi7uu`
- Comparación del email **sin distinguir mayúsculas/minúsculas** y sin espacios al inicio/final (trim); la contraseña se compara exacta.
- **Credenciales correctas** → navegar a una pantalla en blanco con el texto `usuario validado` (ver RF-05).
- **Credenciales incorrectas (incluidos campos vacíos)** → pasar la pantalla al **estado de error 04b** (ver RF-04).
- Mientras se muestra el estado de error, cualquier cambio en los campos limpia el estado (los inputs vuelven a su aspecto normal); un nuevo intento con credenciales incorrectas vuelve a mostrar el error.

### RF-04 — Pantalla de error (wireframe 04b)

El estado de error se muestra **en la misma pantalla de login** (no es una pantalla separada):

- Ambos inputs (Email y Contraseña) cambian su borde a `$danger` con grosor 1.5px.
- Debajo del campo de contraseña aparece el mensaje inline en rojo (`#EF4444`, 13px, semibold):

  > El mail o la contraseña son incorrectos

- El resto de la pantalla (marca, título, links, botón, footer) se mantiene igual que en el estado normal.
- Nota de diseño: el wireframe 04b muestra el link como "Quiere recuperar contraseña?" mientras que el 04 dice "¿Olvidaste tu contraseña?". **Decisión:** unificar ambas pantallas con el texto del 04: `¿Olvidaste tu contraseña?`.

### RF-05 — Pantalla de éxito

- Después de un login válido se muestra una pantalla de fondo blanco con el texto `usuario validado`, centrado.
- Es una pantalla temporal de validación: no tiene otros elementos ni navegación.

## 5. Requerimientos no funcionales

- **Idioma:** toda la UI en español (`es-AR`), textos exactos tal como figuran en este documento y en los wireframes.
- **Plataforma:** móvil, viewport de referencia 375×844 (el layout debe adaptarse a otros tamaños de pantalla sin romperse).
- **Tipografía:** Inter (o la fuente por defecto de Flutter si Inter no está configurada aún — decisión del equipo de implementación).
- **Colores (tokens del design system del mockup):**

| Token | Valor | Uso |
|---|---|---|
| `primary` | `#16A34A` | Botón, marca, links, acentos |
| `bg` | `#F5F7FA` | Fondo de pantalla |
| `surface` | `#FFFFFF` | Fondo de inputs |
| `text` | `#0F172A` | Texto principal |
| `text-2` | `#64748B` | Texto secundario, placeholders |
| `border` | `#E2E8F0` | Bordes de inputs |
| `danger` | `#EF4444` | Borde de error y mensaje de error |

- **Seguridad (aceptada explícitamente para esta etapa):** las credenciales quedan hardcodeadas en el código de la app. No es apto para usuarios reales; debe reemplazarse por autenticación contra el backend antes de un lanzamiento real.

## 6. Criterios de aceptación

1. La app arranca mostrando la pantalla de login con el aspecto del wireframe 04.
2. Con `igpi7uu@gmail.com` e `igpi7uu` se navega a la pantalla en blanco `usuario validado`.
3. Con cualquier otra combinación (o campos vacíos) se muestra el estado 04b: bordes rojos en ambos campos y el mensaje `El mail o la contraseña son incorrectos`.
4. El ícono de ojo alterna la visibilidad de la contraseña.
5. Escribir en cualquier campo limpia el estado de error.
6. Todos los textos de la UI están en español y coinciden con los wireframes.
7. Ninguna llamada HTTP sale de la app durante el login.

## 7. Decisiones ya tomadas (resumen)

| Tema | Decisión |
|---|---|
| Alcance de pantallas | Solo 04 y 04b; 05 (crear cuenta) queda fuera |
| Dónde se valida | Local en Flutter, hardcodeado; sin backend en esta etapa |
| Usuario válido | `igpi7uu@gmail.com` / `igpi7uu` |
| Etiqueta del campo | Se mantiene "Email" (el usuario ingresa `igpi7uu@gmail.com`) |
| Pantalla post-login | En blanco con texto `usuario validado` |
| Links "Crear cuenta" y "¿Olvidaste tu contraseña?" | Visibles pero sin funcionalidad |
| Texto del link en 04b | Unificado con el 04: `¿Olvidaste tu contraseña?` |
| Entorno Flutter | Instalar toolchain completa en esta etapa: Flutter + Android SDK + emulador (para verificación visual) |
| Nombre del proyecto | `flutter create --org com.turnoscancha --project-name turnos_cancha` dentro de `src/FrontEnd/` (llamada propia, ajustable si el equipo prefiere otro nombre) |
| Verificación | `flutter analyze` + tests de widgets + verificación visual en el emulador contra los criterios de aceptación |

## 8. Riesgos y notas para la siguiente iteración

- La validación hardcodeada debe migrarse a un endpoint `/api/auth/login/` del backend Django (el modelo `Usuario` ya soporta login por email) cuando se implemente la API REST.
- Cuando exista autenticación real, considerar persistencia de sesión para no pedir login en cada arranque.
