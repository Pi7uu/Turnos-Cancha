# Requerimientos — Registro de usuario ( pantalla 05 )

**Fecha:** 2026-10-29
**Estado:** Requerimiento funcional definido — **spec visual pendiente** ( §4 )
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"05 · Crear cuenta"**
- ⚠️ El spec visual de esta pantalla queda **pendiente**: los mockups requieren
  imágenes que todavía no están disponibles. Esta versión del documento define
  solo **estructura funcional y comportamiento**; el detalle visual se completa
  en §4 cuando los mockups estén accesibles.

---

## 1. Objetivo

Implementar la pantalla de registro de la app móvil **Flutter** (`src/FrontEnd/`)
( pantalla 05 del prototipo, "Crear cuenta" ), conectada al login ya implementado
( RD 2026-10-15, `login.md` ). Por esta etapa la operación de registro se
**simula localmente en la app**, sin llamar al backend Django.

## 2. Contexto

- El login ya está implementado y verificado ( pantallas 04/04b, `login.md` ):
  proyecto Flutter listo, toolchain instalada, 19/19 tests pasando.
- Igual que en la etapa login: la validación es **local en la app**, sin HTTP.
- **Modelo de datos local simulado:** lista de usuarios **en memoria** que
  empieza con el usuario de la etapa login:
  - **Email:** `igpi7uu@gmail.com` — **Contraseña:** `igpi7uu`
  - Cada registro exitoso agrega un usuario ( nombre, email, contraseña ) a esa
    lista. **Nada persiste**: al cerrar la app la lista vuelve al estado inicial.
- El backend Django ya tiene el modelo `Usuario` ( email, contraseña, nombre,
  teléfono opcional ) pero la API REST sigue sin existir y **no** se usa aquí.
- Los estilos/tokens visuales de referencia ( colores, radios, tipografías )
  son los del design system usado en el login ( tabla de tokens en `login.md` §5 ).
  El layout de la pantalla 05 se define cuando se tengan los mockups ( §4 ).

## 3. Alcance

### Dentro del alcance

- Pantalla **05 · Crear cuenta**: formulario de registro funcional.
- Validación local de los datos del formulario contra las reglas del §5 ( RF-03 ).
- Registro local simulado: agregar el usuario a la lista en memoria ( §2 ).
- Conexión de navegación en ambos sentidos:
  - Footer del **login** ( "Crear cuenta" ) **deja de estar muerto**: navega a
    la 05. *Esto modifica el alcance del RD `login.md`, donde estaba fuera de
    alcance ( ver §7 ).*
  - La 05 vuelve al login ( link "Iniciá sesión" / "Ya tenés cuenta" ), con el
    aviso de éxito del RF-05.
- Ajuste del login para aceptar los usuarios registrados localmente ( RF-06 ).
- Tests: unitarios del registro local + tests de widgets de la pantalla.

### Fuera de alcance

- Campo **teléfono** en el alta ( el modelo del backend lo soporta; se agrega
  cuando exista la API REST ).
- Persistencia de usuarios o de sesión entre arranques de la app.
- Verificación real de email / "activación" de cuenta.
- Endpoint `/api/` en Django / llamadas HTTP de cualquier tipo.
- Cualquier otra pantalla del prototipo ( 06 a 12 ).

## 4. Espec visual — PENDIENTE ( completar con mockups )

> ⚠️ Sección reservada. Los mockups del prototipo necesitan imágenes aún no
> disponibles, y se decidió **no definir diseño** hasta tenerlas ( para no
> inventar estilos que después haya que rehacer ).

Cuando estén los mockups del frame 05, completar aquí:

- [ ] Layout general ( marca, título, subtítulo, orden de campos )
- [ ] Especificación de cada campo ( labels, placeholders, íconos )
- [ ] Botón principal y link de "iniciar sesión"
- [ ] Estados de error ( si el mockup define mensajes/íconos específicos )
- [ ] Cualquier elemento propio de la 05 que no exista en el 04

Mientras tanto: **la pantalla no tiene spec visual definido**; su estilo se
completa íntegramente cuando lleguen los mockups. Solo como referencia **no
vinculante**, el formulario puede apoyarse en la familia visual del login
( tokens de `login.md` §5 ), sin definir nada nuevo.

## 5. Requerimientos funcionales

### RF-01 — Pantalla de registro ( wireframe 05 )

Al llegar desde el login ( "Crear cuenta" ) se muestra el formulario de
registro con **4 campos**:

1. **Nombre** ( texto, requerido )
2. **Email** ( teclado de email, requerido )
3. **Contraseña** ( oculta con ojo de visibilidad, como RF-02 del login )
4. **Repetir contraseña** ( oculta con ojo de visibilidad )

Y un botón principal **"Crear cuenta"** que dispara la validación ( RF-03 ).
El link/pie **"¿Ya tenés cuenta? Iniciá sesión"** vuelve a la pantalla 04.

*( El detalle visual de cada componente queda definido en §4 cuando haya
mockups; esta versión solo fija estructura y comportamiento. )*

### RF-02 — Comportamiento de los campos

- Los campos de contraseña tienen ojo de visibilidad ( alterna ocultar/mostrar,
  por defecto oculto ) igual que en el login.
- Teclado adecuado por campo ( texto para nombre, email para el email,
  contraseñas para las contraseñas ).
- La acción "enviar" del teclado en cada campo navega al siguiente; en el
  último campo dispara la misma validación que el botón.

### RF-03 — Validación local ( inline por campo )

Al intentar crear la cuenta, se validan los campos con **errores por campo**
( borde `$danger` + texto rojo debajo del campo correspondiente ):

| Campo | Regla | Mensaje de error |
|---|---|---|
| Nombre | requerido, no vacío | `Ingresá tu nombre` |
| Email | formato de email válido | `Ingresá un email válido` |
| Email | no registrado aún ( lista local, §2, comparación sin mayúsculas y con trim ) | `Ya hay una cuenta con ese email` |
| Contraseña | mínimo 6 caracteres | `Mínimo 6 caracteres` |
| Repetir | coincide exactamente con Contraseña | `Las contraseñas no coinciden` |

- Si hay varios errores, se muestran **todos a la vez**.
- Escribir en un campo **limpia su propio error** ( igual que RF-03 del login ).
- Regla de conflicto resuelta así: el error de "email duplicado" tiene
  precedencia sobre el de formato si el texto tuviera ambos problemas
  ( no puede darse: formato inválido nunca coincide con un email registrado ).

### RF-04 — Registro simulado

- Con todos los campos válidos, la app registra el usuario en la **lista local
  en memoria** ( nombre, email, contraseña ) y considera la cuenta creada.
- La comparación de emails ignora mayúsculas/minúsculas y espacios extremos
  ( trim ), igual que el login.

### RF-05 — Éxito y regreso al login

- Registro exitoso: vuelve a la pantalla de login mostrando un **aviso de
  éxito** ( snackbar/banner, texto `Cuenta creada` ).
- No hay auto-login: el usuario nuevo queda a un paso de iniciar sesión.

### RF-06 — Login integrado con los usuarios locales ( cambio al RD login )

- El chequeo de credenciales del login deja de validar solo contra el usuario
  hardcodeado: ahora valida contra la **lista local** ( el usuario
  `igpi7uu@gmail.com` / `igpi7uu` sigue funcionando; los registrados también ).
- Comportamiento de error 04b, estado de error y limpieza al escribir sin cambios.

## 6. Requerimientos no funcionales

- **Idioma:** toda la UI en español (`es-AR`), textos exactos según §5.
- **Plataforma:** móvil, viewport de referencia 375×844; el layout debe
  adaptarse a otros tamaños sin romperse.
- **Asociación visual:** mientras no haya mockups, hereda los tokens existentes
  del login ( §4 ); no se define ningún estilo nuevo propio.
- **Seguridad (aceptada para esta etapa, igual que login):** las contraseñas
  viven en texto plano en memoria dentro de la app. No apto para usuarios
  reales; debe reemplazarse por `/api/auth/registro/` cuando exista el backend.
- **Sin red:** ninguna llamada HTTP sale de la app en todo el flujo.

## 7. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Alcance de pantallas | Solo 05; el resto ( 06–12 ) queda fuera |
| Dónde se persiste el registro | Local en Flutter, lista **en memoria**, sin backend en esta etapa |
| Usuario inicial de la lista | `igpi7uu@gmail.com` / `igpi7uu` ( el de la etapa login ) |
| Campos del formulario | Nombre + Email + Contraseña + Repetir contraseña ( sin teléfono ) |
| Regla de contraseña | Mínimo 6 caracteres + coincidencia con repetir |
| Post-registro | Vuelve al login con aviso `Cuenta creada`; el nuevo usuario **ya puede iniciar sesión** |
| Login | Deja de ser solo-hardcodeado: valida contra la lista local ( RF-06 ) |
| Navegación login ↔ 05 ↔ login | El footer "Crear cuenta" del 04 ahora navega a la 05 |
| Errores de validación | **Inline por campo** ( borde $danger + texto rojo ), no un mensaje global |
| Spec visual de la pantalla | **Pendiente** ( §4 ): no se define diseño hasta tener los mockups del prototipo |
| Persistencia | Ninguna: al reiniciar la app la lista vuelve al estado inicial |
| Email duplicado | Igual que backend: único por cuenta ( verificación local en RF-03 ) |

## 8. Riesgos y notas para la siguiente iteración

- La lista local de usuarios es **provisional**: al implementar la API REST el
  registro debe migrar a `/api/auth/registro/` ( el backend ya tiene
  `UsuarioManager.create_user` con email + contraseña y el rol `CLIENTE`
  por defecto; nombre y teléfono son campos del modelo ).
- La ausencia de persistencia ( §3 ) es transitoria; cuando haya sesiones reales
  considerar token/sesión del backend, no almacenamiento local de contraseñas.
- El footer "Crear cuenta" del login cambió de comportamiento respecto de su RD
  ( `login.md` decía "sin funcionalidad" ): actualizar ese documento cuando se
  cierre este requerimiento.
- Completar la sección §4 apenas los mockups estén disponibles, **antes** de
  considerar el spec listo para implementación.
