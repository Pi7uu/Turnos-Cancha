# Spec — Registro de usuario ( pantalla 05 )

> As-built de `docs/HistRequerimientos/registro.md` ( RD 2026-10-29, revisión
> 2026-11-05 ).

## Propósito

Alta de usuarios nuevos desde la pantalla **05 · Crear cuenta**, con
validación inline y registro **local en memoria** ( sin backend ). El login
acepta a los usuarios registrados.

## Cómo funciona

- **Acceso**: solo desde el footer "Crear cuenta" del login ( la app siempre
  arranca en la 04 ). La 05 vuelve al login por el footer `Iniciá sesión` o
  por el botón **Volver** ( chevron circular arriba ), ambos **sin crear la
  cuenta y sin conservar datos**.
- **Formulario** ( 4 campos, sin label — placeholder como hint ): Nombre y
  apellido (`Tu nombre completo`), Email (`tu@email.com`), Contraseña
  (`Mínimo 8 caracteres`, con ojo y texto de ayuda `Usá 8 caracteres como
  mínimo`), Repetir contraseña (`Repetí tu contraseña`, ojo **independiente**).
  Checkbox de términos ( **desmarcado por defecto** ) + botón `Crear cuenta`
  + footer `¿Ya tenés cuenta? Iniciá sesión`.
- **Validación inline** ( `validarRegistro(...)`, errores por campo, todos a
  la vez, borde `$danger` 1.5px + texto rojo 13 semibold ):

| Campo | Regla | Mensaje |
|---|---|---|
| Nombre | trim no vacío | `Ingresá tu nombre` |
| Email | formato `^[^@\s]+@[^@\s]+\.[^@\s]+$` | `Ingresá un email válido` |
| Email | no registrado ( trim+minúsculas, incluye la semilla ) | `Ya hay una cuenta con ese email` |
| Contraseña | mínimo 8 caracteres ( sin trim, exacta ) | `Mínimo 8 caracteres` |
| Repetir | idéntica a Contraseña | `Las contraseñas no coinciden` |
| Términos | checkbox marcado | `Aceptá los términos y condiciones` |

- Escribir en un campo limpia **solo** su error; el del checkbox se limpia
  solo marcándolo.
- **Alta**: con todo válido se agrega a `usuarios_locales` ( nombre con trim,
  email trim+minúsculas como clave única, contraseña tal cual ) y
  `Navigator.pop(context, true)`.
- **Éxito**: el login muestra el snackbar `Cuenta creada` y queda **vacío**
  ( sin prefill ). No hay auto-login.

## Archivos

- `lib/features/auth/registro_screen.dart` — pantalla 05.
- `lib/features/auth/validacion_registro.dart` — validación pura por campo.
- `lib/features/auth/usuarios_locales.dart` — lista en memoria
  ( `UsuarioLocal { nombre, email, password }`, semilla
  `igpi7uu@gmail.com`/`igpi7uu`, `emailRegistrado`, `registrarUsuario`,
  `resetUsuarios` para tests ).
- `test/registro_screen_test.dart`, `test/validacion_registro_test.dart`,
  `test/usuarios_locales_test.dart`.

## Decisiones

- Contraseña: mínimo **8** caracteres ( del mockup ); repetir se compara
  exacta ( sin trim ).
- Ojos de las dos contraseñas **independientes**. Sin autofoco al entrar.
- Pantalla scrollable ( el teclado no tapa el campo con foco ).
- Términos es **texto simple sin links** ( el prototipo no define pantallas
  destino ).
- El email duplicado tiene precedencia sobre formato en el conflicto teórico.

## Límites ( NO hace )

- Nada persiste: al reiniciar la app la lista vuelve a la semilla ( los
  usuarios creados dejan de poder entrar ).
- Sin campo teléfono, sin verificación de email, sin "olvidé mi contraseña".
- Sin HTTP: nada sale de la app.

## Conexiones

- Usa y alimenta `usuarios_locales.dart`, que consume el **login**
  ( `login.md` ) para validar credenciales.
- Navegación 04 ↔ 05 ↔ 04 ( snackbar ) sobre el shell ya existente
  ( `navegacion.md` ).
