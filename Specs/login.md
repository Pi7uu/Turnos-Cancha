# Spec — Login ( pantallas 04 / 04b )

> As-built de `docs/HistRequerimientos/login.md` ( RD 2026-10-15, con los
> cambios de los RDs `registro.md` y `navegacion.md` ).

## Propósito

Autenticación local de la app: el usuario ingresa email y contraseña y, si
son válidos, entra a la app ( shell de navegación ). Validación **local**,
sin backend ( etapa actual ).

## Cómo funciona

- **Pantalla 04** ( `LoginScreen` ): marca `TurnosCancha` ( logo 44×44
  `$primary` radio 13 + texto 22 bold ), título `Iniciá sesión`, subtítulo
  `Reservá tu cancha en segundos`, campos **Email** y **Contraseña** ( íconos
  `mail`/`lock`, ojo de visibilidad en la contraseña ), link
  `¿Olvidaste tu contraseña?`, botón `Ingresar`, footer
  `¿No tenés cuenta? Crear cuenta`.
- **Validación** ( `credencialesValidas(email, password)` ): busca en la
  lista local de usuarios ( `usuarios_locales.dart` ) uno cuyo email
  normalizado ( trim + minúsculas ) coincida y cuya contraseña sea **exacta**
  ( case-sensitive ). Incluye el usuario semilla `igpi7uu@gmail.com` /
  `igpi7uu`.
- **Éxito** → `Navigator.pushReplacement` al **MainShell** ( tab Inicio ). No
  hay vuelta a la 04 con "atrás".
- **Error → estado 04b** ( misma pantalla ): ambos inputs con borde
  `$danger` 1.5px y mensaje inline `El mail o la contraseña son incorrectos`
  ( `$danger`, 13 semibold ). Escribir en cualquier campo **limpia el error**;
  un nuevo intento incorrecto lo vuelve a mostrar.
- El ojo alterna visibilidad ( por defecto oculta ). El teclado usa
  email/visiblePassword y la acción "done" dispara la misma validación que
  `Ingresar`.
- **Footer "Crear cuenta"** navega a la pantalla 05 ( registro ). El link
  `¿Olvidaste tu contraseña?` **no hace nada**.

## Archivos

- `lib/features/auth/login_screen.dart` — pantalla 04/04b.
- `lib/features/auth/credenciales.dart` — validación contra la lista local.
- `lib/features/auth/usuarios_locales.dart` — lista de usuarios en memoria
  ( comparte con registro; ver `registro.md` ).
- `test/login_screen_test.dart`, `test/credenciales_test.dart`.

## Decisiones

- Validación local hardcodeada → hoy lista local en memoria ( evolución del
  RD original: `credencialesValidas` delega en `usuarios_locales` ).
- Errores **inline por campo**, sin toasts ni mensajes globales.
- Tras el registro exitoso el login vuelve **vacío** ( sin prefill ) y
  muestra el snackbar `Cuenta creada`.
- La pantalla `usuario validado` fue **eliminada** ( reemplazada por el
  shell — ver `navegacion.md` ).

## Límites ( NO hace )

- No llama al backend ( sin HTTP ). No persiste la sesión: al reiniciar la
  app se vuelve al login.
- No hay recuperación de contraseña ni recordar sesión.
- Cualquier usuario registrado en la sesión actual puede entrar; los
  registrados en sesiones previas no ( la lista se reinicia ).

## Conexiones

- Éxito → **shell de navegación** ( `navegacion.md` ).
- Footer → **registro** ( `registro.md` ).
- Los usuarios válidos salen de `usuarios_locales.dart` ( lo administra
  registro ).
