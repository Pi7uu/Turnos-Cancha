# Requerimientos — Registro de usuario ( pantalla 05 )

**Fecha:** 2026-10-29 (revisión 2026-11-05: spec visual §4 completado con mockup)
**Estado:** Listo para planificar/implementar
**Fuentes de diseño:**
- `docs/prototipos/mockups.pen` — frame **"05 · Crear cuenta"** (disponible desde la revisión 2026-11-05; spec visual completo en §4)

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
  El layout de la pantalla 05 queda definido por el mockup ( spec visual en §4 ).

## 3. Alcance

### Dentro del alcance

- Pantalla **05 · Crear cuenta**: formulario de registro funcional.
- Validación local de los datos del formulario contra las reglas del §5 ( RF-03 ).
- Registro local simulado: agregar el usuario a la lista en memoria ( §2 ).
- Checkbox de términos y condiciones y botón **Volver** ( RF-07 / RF-08 ).
- Conexión de navegación en ambos sentidos:
  - Footer del **login** ( "Crear cuenta" ) **deja de estar muerto**: navega a
    la 05. *Esto modifica el alcance del RD `login.md`, donde estaba fuera de
    alcance ( ver §8 ).*
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

## 4. Espec visual ( mockup "05 · Crear cuenta" )

Pantalla de 375×844 sobre fondo `$bg`, con Status Bar del sistema arriba. El
contenido va en columna con padding **28 arriba / 24 los lados / 32 abajo**,
hueco entre bloques de 22 y distribución `space_between` ( el footer queda
apoyado abajo ). Elementos de arriba hacia abajo:

| Elemento | Especificación |
|---|---|
| Botón Volver | Círculo 40×40, fondo `$surface`, radio 20, borde `$border` 1px; ícono `chevron-left` (lucide) 20px `$text` |
| Titular | `Crear cuenta` — 28px, bold, `$text`; debajo `Creá tu cuenta y empezá a reservar` — 15px, `$text-2` |
| Formulario | Columna con hueco 16 entre campos |
| Componente "Campo" | Label 13px semibold `$text` (hueco 7 al input) + input: fondo `$surface`, radio 12, borde `$border` 1px, padding vertical 13 / horizontal 16, ícono lucide 18px `$text-2` a la izquierda, placeholder 15px `$text-2` |
| → Nombre y apellido | Ícono `user`, placeholder `Tu nombre completo` |
| → Email | Ícono `mail`, placeholder `tu@email.com` |
| → Contraseña | Ícono `lock`, placeholder `Mínimo 8 caracteres`, ícono de ojo (lucide `eye`) a la derecha; debajo del input, texto de ayuda `Usá 8 caracteres como mínimo` — 12px, `$text-2` |
| → Repetir contraseña | Ícono `lock`, placeholder `Repetí tu contraseña`, ícono de ojo a la derecha |
| Términos | Fila (hueco 10, alineada al centro): checkbox 20×20 radio 6 + texto `Acepto los términos y condiciones y la política de privacidad` — 12px, `$text-2`, lineHeight 1.4, que puede ocupar 2 líneas |
| Botón principal | `Crear cuenta` — ancho completo, fondo `$primary`, radio 12, padding 15, texto blanco 16px semibold |
| Footer | `¿Ya tenés cuenta?` (14px, `$text-2`) + `Iniciá sesión` (14px, semibold, `$primary`), centrados con hueco 6 |

Estados adicionales ( los define este RD como extensión del mockup ):

- **Campo con error:** borde `$danger` 1.5px + mensaje de error debajo del
  campo, en rojo ( `#EF4444`, 13px, semibold ) — igual criterio que 04b.
- **Checkbox marcado:** fondo `$primary`, radio 6, check blanco (lucide `check`) 13px.
  **Desmarcado:** fondo `$surface`, borde `$border`, sin check.
- **Diferencias con el 04:** la 05 **no lleva la marca/logo** arriba ( reemplaza
  por el botón Volver ), agrega la segunda contraseña y el checkbox de términos.

## 5. Requerimientos funcionales

### RF-01 — Pantalla de registro ( mockup 05 )

- El flujo siempre **arranca en la pantalla 04**: la 05 solo se alcanza
  navegando desde el footer "Crear cuenta" del login; la app nunca abre
  directamente en la 05.

Al llegar desde el login ( "Crear cuenta" ) se muestra el formulario de
registro con **4 campos**:

1. **Nombre y apellido** ( texto, requerido )
2. **Email** ( teclado de email, requerido )
3. **Contraseña** ( oculta con ojo de visibilidad, con texto de ayuda de 8
   caracteres, como define §4 )
4. **Repetir contraseña** ( oculta con ojo de visibilidad )

Con un botón principal **"Crear cuenta"** que dispara la validación ( RF-03 ),
el footer **"¿Ya tenés cuenta? Iniciá sesión"** que vuelve a la pantalla 04, y
el botón **Volver** ( RF-08 ). El checkbox de términos se cubre en RF-07.

*( El detalle visual de cada componente está en §4. )*

### RF-02 — Comportamiento de los campos

- Los campos de contraseña tienen ojo de visibilidad ( alterna ocultar/mostrar,
  por defecto oculto ) igual que en el login. Los **ojos de las dos contraseñas
  son independientes** ( alternar uno no afecta al otro ).
- Teclado adecuado por campo: texto para nombre, email para el email,
  contraseñas para las contraseñas.
- Acción "siguiente" del teclado en Nombre y apellido, Email y Contraseña;
  en **Repetir contraseña** la acción "listo/done" dispara la misma validación
  que el botón **Crear cuenta**.
- **Sin autofoco al llegar** a la pantalla: el teclado solo aparece al tocar un
  campo ( misma conducta que el 04; decisión propia ).
- La pantalla completa es **scrollable**: cuando el teclado cubre el campo con
  foco, el contenido se desplaza hasta dejarlo visible ( los 4 campos +
  checkbox + botón no caben a la vista junto al teclado abierto ).
- Tocar fuera de los campos descarta el teclado, sin alterar valores ni
  disparar validación.
- Las contraseñas se ocultan como puntos/asteriscos estándar de Flutter.

### RF-03 — Validación local ( inline por campo )

Al intentar crear la cuenta, se validan los campos con **errores por campo**
( borde `$danger` + texto rojo debajo del campo correspondiente ):

| Campo | Regla | Mensaje de error |
|---|---|---|
| Nombre y apellido | requerido, no vacío | `Ingresá tu nombre` |
| Email | formato de email válido | `Ingresá un email válido` |
| Email | no registrado aún ( lista local, §2, comparación sin mayúsculas y con trim ) | `Ya hay una cuenta con ese email` |
| Contraseña | mínimo 8 caracteres | `Mínimo 8 caracteres` |
| Repetir | coincide exactamente con Contraseña | `Las contraseñas no coinciden` |
| Términos | checkbox marcado ( RF-07 ) | `Aceptá los términos y condiciones` |

- Si hay varios errores, se muestran **todos a la vez** ( cada campo ofensivo
  con su borde `$danger` y su mensaje; el checkbox desmarcado con su mensaje,
  ver RF-07 ). No hay toasts ni mensajes globales.
- Escribir en un campo **limpia su propio error** ( igual que RF-03 del login );
  el error del checkbox se limpia **solamente marcándolo** ( RF-07 ).
- Reglas de comparación exactas:
  - **Nombre y apellido:** trim; vacío o solo espacios → error.
  - **Email:** trim y minúsculas; formato válido = `^[^@\s]+@[^@\s]+\.[^@\s]+$`
    ( basta que tenga texto antes de `@`, dominio con punto y sin espacios ).
  - **Email duplicado:** comparación contra los emails guardados **en
    minúsculas y con trim**; se incluye al usuario inicial `igpi7uu@gmail.com`.
  - **Contraseñas:** sin trim ni normalización; se comparan **exactas**
    ( distinguen mayúsculas/minúsculas ).
- Regla de conflicto resuelta así: el error de "email duplicado" tiene
  precedencia sobre el de formato si el texto tuviera ambos problemas
  ( no puede darse: formato inválido nunca coincide con un email registrado ).

### RF-04 — Registro simulado

- Con todos los campos válidos, la app registra el usuario en la **lista local
  en memoria** ( nombre, email, contraseña ) y considera la cuenta creada.
- Lo que se guarda: **nombre con trim** ( tal como se escribió, sin otro
  procesamiento ), **email con trim y en minúsculas** ( es la clave única de la
  lista ) y **contraseña tal cual** ( sin modificar ).
- La validación y el registro son **instantáneos** ( local ): no hay indicador
  de carga, estados intermedios ni posibilidad de doble registro ( el botón
  navega al éxito en el mismo gesto ).

### RF-05 — Éxito y regreso al login

- Registro exitoso: vuelve a la pantalla de login mostrando un **aviso de
  éxito** ( snackbar/banner, texto `Cuenta creada` ).
- El login vuelve **vacío, como al arrancar la app**: no se autocompleta el
  email con el recién registrado ( decisión propia; el snackbar es el único
  rastro del registro ).
- No hay auto-login: el usuario nuevo queda a un paso de iniciar sesión.

### RF-06 — Login integrado con los usuarios locales ( cambio al RD login )

- El chequeo de credenciales del login deja de validar solo contra el usuario
  hardcodeado: ahora valida contra la **lista local** ( el usuario
  `igpi7uu@gmail.com` / `igpi7uu` sigue funcionando; los registrados también ).
- Comportamiento de error 04b, estado de error y limpieza al escribir sin cambios.

### RF-07 — Checkbox de términos ( agregado del mockup )

- Checkbox obligatorio para crear la cuenta. **Desmarcado por defecto**; el
  mockup muestra el estado marcado para documentar su aspecto ( §4 ).
- Tocar el checkbox ( o el texto ) alterna marcado/desmarcado.
- Al intentar crear la cuenta desmarcado, se suma el error inline de RF-03
  ( `Aceptá los términos y condiciones` ) junto con los demás errores; escribir
  no lo limpia: lo limpia marcar el checkbox.
- El texto de términos y política es **texto simple sin links**: el prototipo
  no define pantallas destino para ellos ( decisión registrada en §8 ).

### RF-08 — Botón Volver ( agregado del mockup )

- El círculo con `chevron-left` arriba del titular vuelve a la pantalla 04
  **sin crear la cuenta y sin conservar ningún dato** — mismo efecto que el
  footer "¿Ya tenés cuenta? Iniciá sesión".

## 6. Criterios de aceptación

1. La app arranca en la pantalla 04; el footer "Crear cuenta" navega a la 05,
   que muestra el layout del §4 ( Volver, titular, 4 campos, checkbox, botón,
   footer ), sin la marca/logo del 04.
2. El botón Volver y el footer "¿Ya tenés cuenta? Iniciá sesión" vuelven a la
   04 sin conservar ningún dato del formulario.
3. Registrar `Marta Gómez` / `marta@test.com` / `qwerty1234` y, tras el aviso
   `Cuenta creada`, iniciar sesión en la 04 con esas credenciales ( email
   aceptable también en mayúsculas y con espacios: `Marta@Test.com ` ).
4. Intentar registrar `igpi7uu@gmail.com` ( caso y espacios distinto:
   `IGPI7UU@gmail.com` ) muestra el error `Ya hay una cuenta con ese email`.
5. Cada campo inválido muestra su borde `$danger` y el mensaje exacto del
   cuadro RF-03, todos juntos: nombre vacío → `Ingresá tu nombre`; email mal
   formado → `Ingresá un email válido`; contraseña de 7 caracteres →
   `Mínimo 8 caracteres`; contraseñas distintas → `Las contraseñas no
   coinciden`; checkbox desmarcado → `Aceptá los términos y condiciones`.
6. Escribir en un campo limpia su error; marcar el checkbox limpia el suyo;
   ninguna otra interacción limpia errores.
7. Con el formulario válido y el checkbox marcado, tocar `Crear cuenta`
   registra el usuario en la lista local y vuelve a la 04 con el aviso
   `Cuenta creada`, con el login vacío ( sin email precargado ).
8. El ojo de cada contraseña alterna ocultar/mostrar de forma independiente.
9. La acción "enviar" avanza por los campos en orden y "done" en Repetir
   contraseña valida igual que el botón; si el teclado tapa el campo con foco,
   la pantalla hace scroll hasta mostrarlo.
10. Reiniciar la app devuelve la lista de usuarios al estado inicial: los
    usuarios creados en la sesión anterior ya no pueden iniciar sesión
    ( `igpi7uu@gmail.com` / `igpi7uu` sí sigue ).
11. Todos los textos de la UI están en español (`es-AR`) y coinciden con §4.
12. Ninguna llamada HTTP sale de la app durante registro ni login.

## 7. Requerimientos no funcionales

- **Idioma:** toda la UI en español (`es-AR`), textos exactos según §5.
- **Tipografía:** Inter ( o la fuente por defecto de Flutter si Inter no está
  configurada aún — misma decisión que `login.md` §5 ).
- **Plataforma:** móvil, viewport de referencia 375×844; el layout debe
  adaptarse a otros tamaños sin romperse.
- **Asociación visual:** el estilo de la pantalla se especifica en §4 a partir
  del mockup, con los mismos tokens del design system del login ( `$primary`,
  `$bg`, `$surface`, `$text`, `$text-2`, `$border`, `$danger` ) — tabla en
  `login.md` §5.
- **Seguridad (aceptada para esta etapa, igual que login):** las contraseñas
  viven en texto plano en memoria dentro de la app. No apto para usuarios
  reales; debe reemplazarse por `/api/auth/registro/` cuando exista el backend.
- **Sin red:** ninguna llamada HTTP sale de la app en todo el flujo.

## 8. Decisiones ya tomadas ( resumen )

| Tema | Decisión |
|---|---|
| Alcance de pantallas | Solo 05; el resto ( 06–12 ) queda fuera |
| Dónde se persiste el registro | Local en Flutter, lista **en memoria**, sin backend en esta etapa |
| Usuario inicial de la lista | `igpi7uu@gmail.com` / `igpi7uu` ( el de la etapa login ) |
| Campos del formulario | Nombre y apellido + Email + Contraseña + Repetir contraseña ( sin teléfono; labels según mockup §4 ) |
| Regla de contraseña | Mínimo **8 caracteres** ( según el mockup, reemplaza la regla del RD de 6 ) + coincidencia con repetir |
| Checkbox de términos | Obligatorio, **desmarcado por defecto**; el mockup muestra el estado marcado ( RF-07 ) |
| Autofoco | No al entrar: el teclado abre al tocar un campo, igual que el 04 ( RF-02 ) |
| Ojos de las contraseñas | Independientes entre sí ( RF-02 ) |
| Normalización al guardar | Nombre con trim; email en minúsculas + trim ( clave única ); contraseña tal cual ( RF-04 ) |
| Login tras registro | Vuelve vacío, **sin prefill** del email; solo el snackbar `Cuenta creada` ( RF-05 ) |
| Links de términos y política | Texto simple **sin links**: el prototipo no define pantallas de T&C ( decisión propia, RF-07 ) |
| Botón Volver | Vuelve al login descartando los datos del formulario ( RF-08 ) |
| Post-registro | Vuelve al login con aviso `Cuenta creada`; el nuevo usuario **ya puede iniciar sesión** |
| Login | Deja de ser solo-hardcodeado: valida contra la lista local ( RF-06 ) |
| Navegación login ↔ 05 ↔ login | El footer "Crear cuenta" del 04 ahora navega a la 05 |
| Errores de validación | **Inline por campo** ( borde $danger + texto rojo ), no un mensaje global |
| Spec visual de la pantalla | **Definido** con el mockup ( §4, revisión 2026-11-05 ) |
| Persistencia | Ninguna: al reiniciar la app la lista vuelve al estado inicial |
| Email duplicado | Igual que backend: único por cuenta ( verificación local en RF-03 ) |

## 9. Riesgos y notas para la siguiente iteración

- La lista local de usuarios es **provisional**: al implementar la API REST el
  registro debe migrar a `/api/auth/registro/` ( el backend ya tiene
  `UsuarioManager.create_user` con email + contraseña y el rol `CLIENTE`
  por defecto; nombre y teléfono son campos del modelo ).
- La ausencia de persistencia ( §3 ) es transitoria; cuando haya sesiones reales
  considerar token/sesión del backend, no almacenamiento local de contraseñas.
- El footer "Crear cuenta" del login cambió de comportamiento respecto de su RD
  ( `login.md` decía "sin funcionalidad" ): actualizar ese documento cuando se
  cierre este requerimiento.
- El checkbox de términos y el mínimo de 8 caracteres provienen del mockup
  ( 2026-11-05 ) y reemplazan decisiones del RD original; los tests existentes
  de la etapa login no se ven afectados, pero el registro local agrega reglas
  nuevas que deben tener tests propios.
- Los estados de error del checkbox y del botón Volver no están dibujados en el
  mockup ( solo su aspecto en reposo/exitoso ): quedan definidos en §4 y
  RF-07/RF-08 como extensión de este RD.
