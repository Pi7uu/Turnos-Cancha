# Registro — pantalla 05 "Crear cuenta" Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter registration screen (mockup 05) with per-field local validation, in-memory user registration, login integration (footer navigation + local user list validation) and the `Cuenta creada` success snackbar.

**Architecture:** Follows the login stage patterns exactly. Pure logic lives in standalone Dart files so it is unit-testable (`usuarios_locales.dart` = in-memory user store; `validacion_registro.dart` = per-field validation); the screen (`registro_screen.dart`) holds controllers/validation-errors and on success calls `Navigator.pop(context, true)`; `login_screen.dart` awaits that push result to show the snackbar, and its `_Footer` gains an `onCrearCuenta` callback. No new dependencies, no routing/state-management libraries (YAGNI).

**Tech Stack:** Flutter stable instalado en `%USERPROFILE%\flutter` (sin agregar a PATH), Dart, `flutter_test`, `lucide_icons_flutter` (ya en el proyecto). Sin nuevas dependencias.

**Spec:** `docs/requerimientos/registro.md` (RD 2026-10-29, revisión 2026-11-05). Tokens y textos vienen de ahí; el layout es su §4 (mockup frame "05 · Crear cuenta").

## Global Constraints

- UI en `es-AR`; textos exactos (RD §4/§5): `Crear cuenta`, `Creá tu cuenta y empezá a reservar`, `Nombre y apellido`, `Tu nombre completo`, `Email`, `tu@email.com`, `Contraseña`, `Mínimo 8 caracteres`, `Usá 8 caracteres como mínimo`, `Repetir contraseña`, `Repetí tu contraseña`, `Acepto los términos y condiciones y la política de privacidad`, `¿Ya tenés cuenta?`, `Iniciá sesión`.
- Mensajes de error exactos (RD RF-03): `Ingresá tu nombre`, `Ingresá un email válido`, `Ya hay una cuenta con ese email`, `Mínimo 8 caracteres`, `Las contraseñas no coinciden`, `Aceptá los términos y condiciones`. Aviso de éxito: `Cuenta creada`.
- Tokens ya definidos en `lib/core/theme/app_colors.dart` — NO agregar tokens: `primary #16A34A`, `bg #F5F7FA`, `surface #FFFFFF`, `text #0F172A`, `text2 #64748B`, `border #E2E8F0`, `danger #EF4444`.
- Medidas (RD §4): botón Volver círculo 40×40 radio 20 borde `border` 1px + chevron-left 20px `text`; título 28 bold `text`; subtítulo 15 `text2`; labels 13 semibold `text` (hueco 7 al input); hueco 16 entre campos; inputs radio 12, borde `border` 1px (error: `danger` 1.5px), padding v13/h16, ícono lucide 18px `text2`, hint 15 `text2`; texto de ayuda 12 `text2`; checkbox 20×20 radio 6 (marcado: fondo `primary` + check blanco 13px; desmarcado: `surface` + borde `border`); texto de términos 12 `text2` lineHeight 1.4; botón principal ancho completo, radio 12, padding vertical 15, texto blanco 16 semibold; footer 14, hueco 6.
- Padding del Content: 28 arriba / 24 lados / 32 abajo, hueco entre bloques 22, distribución `space_between`.
- Validación (RD RF-03/RF-04): nombre trim no vacío; email `^[^@\s]+@[^@\s]+\.[^@\s]+$` con trim+minúsculas; duplicado contra la lista (incluye al usuario inicial) comparado trim+minúsculas; contraseña mínima 8, sin trim, comparación exacta; repetir igual a contraseña exacto; checkbox desmarcado → error; errores por campo, todos a la vez, sin mensajes globales.
- Sin autofoco al llegar; ojos de las dos contraseñas independientes, ocultas por defecto; teclado: texto/email/visiblePassword; acción `next` en Nombre, Email y Contraseña, `done` en Repetir = submit; tap fuera descarta el teclado sin validar; pantalla scrollable sin overflow en 375×844 ni en pantallas chicas.
- Lista de usuarios: SOLO memoria (nada guardado en disco, nada en pubspec); al reiniciar la app vuelve al estado inicial. Usuario inicial `igpi7uu@gmail.com` / `igpi7uu`.
- Compromiso del login (RF-06): `igpi7uu@gmail.com` / `igpi7uu` sigue funcionando Y los registrados también; estado 04b sin cambios.
- La pantalla 05 se navega SOLO desde el footer "Crear cuenta" del login (la app siempre arranca en la 04); el login vuelve vacío tras el registro, sin prefill.
- Comandos Flutter: `%USERPROFILE%\flutter\bin\flutter.bat` desde `src/FrontEnd/` (flutter no está en PATH).

## Review Focus

1. **Consistencia de normalización del email registro↔login** — registrar un email con mayúsculas/espacios y loguearse con otra variación debe funcionar. Pinned: Task 1 test `usuarios_email_registrado_normaliza_y_login_acepta_variaciones`.
2. **Borde mínimo de contraseña y comparación exacta** — 7 caracteres → `Mínimo 8 caracteres`; contraseñas con espacios externos → `Las contraseñas no coinciden`. Pinned: Task 3 tests `validar_registro_password_7_falla_8_pasa` y `validar_registro_repetir_exacto_sin_trim`.
3. **Limpieza de errores por alcance** — escribir limpia SOLO el error de ese campo; el error del checkbox SOLO se limpia marcándolo; tocar fuera/marcar-campo no borra los demás. Pinned: Task 5 test `registro_escribir_limpia_solo_su_error` y `registro_checkbox_error_limpia_solo_marcando`.
4. **Duplicado incluye al usuario inicial** con variación de caso/espacios. Pinned: Task 3 test `validar_registro_email_duplicado_con_usuario_semilla`.
5. **Independencia de los ojos de las contraseñas** — alternar uno no afecta al otro. Pinned: Task 4 test `registro_ojos_independientes`.
6. **Sin overflow con teclado/errores visibles** en 375×844 y 320×568. Pinned: Task 4 test `registro_sin_overflow_375x844_y_chica` (con errores visibles a la vez).

---

### Task 1: `usuarios_locales.dart` — lista en memoria (lógica de datos del registro)

**Files:**
- Create: `src/FrontEnd/lib/features/auth/usuarios_locales.dart`
- Test: `src/FrontEnd/test/usuarios_locales_test.dart`

**Interfaces:**
- Consumes: nada (solo Dart core).
- Produces (Task 2, 3, 5 dependen de esto): `class UsuarioLocal { final String nombre; final String email; final String password; }`; `bool emailRegistrado(String email)`; `void registrarUsuario(String nombre, String email, String password)`; `void resetUsuarios()` (@visibleForTesting).

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/usuarios_locales_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/auth/usuarios_locales.dart';

void main() {
  setUp(() => resetUsuarios());

  group('usuarios_locales (RD registro §2 modelo de datos)', () {
    test('usuarios_arranca_con_usuario_semilla', () {
      expect(emailRegistrado('igpi7uu@gmail.com'), isTrue);
      expect(emailRegistrado('  igpi7uu@GMAIL.com '), isTrue);
      expect(emailRegistrado('marta@test.com'), isFalse);
    });

    test('usuarios_email_registrado_normaliza_y_login_acepta_variaciones', () {
      registrarUsuario('Marta Gómez', ' Marta@Test.com ', 'qwerty1234');
      expect(emailRegistrado('marta@test.com'), isTrue);
      expect(emailRegistrado(' MARTA@test.com '), isTrue);
    });

    test('usuarios_registrar_guarda_norma_y_valores', () {
      registrarUsuario(' José  ', ' jose@test.com ', 'contraseña8');
      expect(emailRegistrado('JOSE@test.com'), isTrue);
    });

    test('usuarios_registrar_ya_existente_lanza_error', () {
      registrarUsuario('Uno', 'a@test.com', 'contraseña8');
      expect(() => registrarUsuario('Dos', ' A@test.com ', 'contraseña8'),
          throwsArgumentError);
    });

    test('usuarios_reset_vuelve_al_estado_semilla', () {
      registrarUsuario('Marta Gómez', 'marta@test.com', 'qwerty1234');
      resetUsuarios();
      expect(emailRegistrado('marta@test.com'), isFalse);
      expect(emailRegistrado('igpi7uu@gmail.com'), isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/usuarios_locales_test.dart` (desde `src/FrontEnd/`)
Expected: FAIL ("usuarios_locales" no existe).

- [ ] **Step 3: Implementar `lib/features/auth/usuarios_locales.dart`**

- Clase `UsuarioLocal` con los 3 campos `final` (`nombre` como se escribe con trim, `email` ya en minúsculas+trim — es la clave, `password` tal cual, RD RF-04).
- Lista privada en memoria inicializada con el usuario semilla: `UsuarioLocal(nombre: 'Usuario inicial', email: 'igpi7uu@gmail.com', password: 'igpi7uu')`.
- `String _normalizarEmail(String email)` → `email.trim().toLowerCase()` (reutilizar en ambos métodos).
- `emailRegistrado` compara normalizado; `registrarUsuario` normaliza el email, si ya está registrado lanza `ArgumentError`, si no agrega a la lista (guardar nombre con `.trim()`).
- `resetUsuarios()` re-vacía y vuelve a sembrar; anotarlo `@visibleForTesting`.

- [ ] **Step 4: Run test to verify it passes**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/usuarios_locales_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/auth/usuarios_locales.dart src/FrontEnd/test/usuarios_locales_test.dart
git commit -m "feat(auth): tienda local de usuarios para el registro (RD registro §2/RF-04)"
```

### Task 2: `credenciales.dart` valida contra la lista local (RF-06)

**Files:**
- Modify: `src/FrontEnd/lib/features/auth/credenciales.dart` (reemplazar el chequeo hardcodeado por delegación a `usuarios_locales.dart`)
- Test: `src/FrontEnd/test/credenciales_test.dart` (los tests actuales de semilla deben seguir pasando) — agregar los de usuarios registrados.

**Interfaces:**
- Consumes: `emailRegistrado` y la lista privada de usuarios de Task 1.
- Produces: misma firma `bool credencialesValidas(String email, String password)` — Task 5/6 no cambia nada: el login ahora acepta también los usuarios registrados, sin alterar la pantalla 04 ni `main.dart`.

- [ ] **Step 1: Agregar los tests que fallan al final de `test/credenciales_test.dart`**

```dart
group('credencialesValidas con usuarios registrados (RF-06)', () {
  setUp(() => resetUsuarios());

  test('credenciales_validas_acepta_usuario_registrado', () {
    registrarUsuario('Marta Gómez', 'marta@test.com', 'qwerty1234');
    expect(credencialesValidas('marta@test.com', 'qwerty1234'), isTrue);
  });

  test('credenciales_validas_acepta_variaciones_del_registrado', () {
    registrarUsuario('Marta Gómez', ' Marta@Test.com ', 'qwerty1234');
    expect(credencialesValidas(' MARTA@test.com ', 'qwerty1234'), isTrue);
  });

  test('credenciales_validas_usuario_registrado_password_distinta_falla', () {
    registrarUsuario('Marta Gómez', 'marta@test.com', 'qwerty1234');
    expect(credencialesValidas('marta@test.com', 'otra1234'), isFalse);
  });

  test('credenciales_validas_semilla_sigue_funcionando', () {
    expect(credencialesValidas('igpi7uu@gmail.com', 'igpi7uu'), isTrue);
  });
});
```

Imports extra: `import 'package:turnos_cancha/features/auth/usuarios_locales.dart';`

- [ ] **Step 2: Run test to verify it fails**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/credenciales_test.dart`
Expected: FAIL (el usuario registrado no es aceptado).

- [ ] **Step 3: Implementar en `credenciales.dart`**

Mantener la firma `bool credencialesValidas(String email, String password)` pero borrar `_emailValido`/`_passwordValida`: busca en la lista de `usuarios_locales` un usuario cuyo **email normalizado** (trim+minúsculas, comparación idéntica a `login.md` RF-03) coincida y cuya **contraseña sea exacta** (sin trim, case-sensitive). Las pantallas no cambian.

- [ ] **Step 4: Run test to verify it passes**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/credenciales_test.dart`
Expected: PASS (los 5 tests previos + los 4 nuevos).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/auth/credenciales.dart src/FrontEnd/test/credenciales_test.dart
git commit -m "feat(auth): login valida contra la lista local de usuarios (RF-06)"
```

### Task 3: `validacion_registro.dart` — validación pura por campo (RF-03)

**Files:**
- Create: `src/FrontEnd/lib/features/auth/validacion_registro.dart`
- Test: `src/FrontEnd/test/validacion_registro_test.dart`

**Interfaces:**
- Consumes: `emailRegistrado` de Task 1.
- Produces (Task 5 usa esto): `final class ErroresRegistro { final String? nombre; final String? email; final String? password; final String? repetir; final String? terminos; bool get hayError; }` y `ErroresRegistro validarRegistro({required String nombre, required String email, required String password, required String repetir, required bool terminos})`.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/validacion_registro_test.dart`**

Casos (usar el comportamiento del RF-03; todos los `setUp` llaman `resetUsuarios()`):

```dart
test('validar_registro_todo_vacio_muestra_5_errores_a_la_vez', () {
  final e = validarRegistro(
      nombre: '   ', email: '', password: '', repetir: '', terminos: false);
  expect(e.nombre, 'Ingresá tu nombre');
  expect(e.email, 'Ingresá un email válido');
  expect(e.password, 'Mínimo 8 caracteres');
  expect(e.repetir, 'Las contraseñas no coinciden');
  expect(e.terminos, 'Aceptá los términos y condiciones');
  expect(e.hayError, isTrue);
});

('validar_registro_password_7_falla_8_pasa', ...) // 7 → 'Mínimo 8 caracteres';
                                                  // 8+ → password null

('validar_registro_email_formato', ...) // 'a@b' → 'Ingresá un email válido';
                                        // 'a b@c.com' → 'Ingresá un email válido';
                                        // 'a@bc.com' → email null (con 8 chars de pass)

('validar_registro_email_duplicado_con_usuario_semilla', ...)
  // email 'IGPI7UU@gmail.com' → 'Ya hay una cuenta con ese email'

('validar_registro_email_duplicado_con_usuario_registrado', ...)
  // registrar 'marta@test.com'; validar ' Marta@Test.com ' → 'Ya hay una cuenta con ese email'

('validar_registro_repetir_exacto_sin_trim', ...)
  // password 'Abcdefg8', repetir ' Abcdefg8' → 'Las contraseñas no coinciden';
  // repetir 'Abcdefg8' → repetir null

('validar_registro_formulario_valido_sin_errores', ...)
  // nombre 'Marta Gómez', email 'marta@test.com', pass+repetir 'qwerty1234', terminos true
  // → los 5 campos null y !e.hayError
```

(los nombres completos van en snake_case con prefijo `validar_registro_`, igual que los tests de la etapa login)

- [ ] **Step 2: Run test to verify it fails**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/validacion_registro_test.dart`
Expected: FAIL ("validacion_registro" no existe).

- [ ] **Step 3: Implementar `lib/features/auth/validacion_registro.dart`**

Orden de checks por campo (RD RF-03): nombre trim-vacío → email formato (regex `^[^@\s]+@[^@\s]+\.[^@\s]+$` sobre el valor **trimado**; NO aplicar minúsculas antes del formato — un email con mayúsculas es formato válido) → si formato ok, `emailRegistrado(email.trim())` → duplicado; password `length < 8` sobre el valor **crudo** (sin trim); repetir `!=` password exacto; `!terminos`. Devuelve `ErroresRegistro` con `null` en cada campo válido.

- [ ] **Step 4: Run test to verify it passes**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/validacion_registro_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/auth/validacion_registro.dart src/FrontEnd/test/validacion_registro_test.dart
git commit -m "feat(auth): validación pura por campo del registro (RF-03)"
```

### Task 4: `registro_screen.dart` — layout del mockup §4 + interacciones de campos

**Files:**
- Create: `src/FrontEnd/lib/features/auth/registro_screen.dart`
- Test: `src/FrontEnd/test/registro_screen_test.dart`

**Interfaces:**
- Consumes: nada de lógica aún (el submit se cablea en Task 5: dejar `void _submit() {}` vacío y su llamado en el botón/done).
- Produces: `RegistroScreen extends StatefulWidget` con constructor `const RegistroScreen({super.key})` — sin parámetros: la propia pantalla hace la validación (como `LoginScreen`, que llama la función pura desde sí misma) y en Task 5 presenta `Navigator.pop(context, true)` al éxito; Task 6 la empuja desde el login.

- [ ] **Step 1: Write the failing test `src/FrontEnd/test/registro_screen_test.dart`**

Casos (español, estilo etapa login `login_screen_test.dart`):

1. `registro_muestra_todos_los_textos_del_mockup` — pump `RegistroScreen` dentro de `MaterialApp`; los `Text` fijos del §4: `Crear cuenta` (aparece 2 veces: titular y botón — `findsNWidgets(2)`), `Creá tu cuenta y empezá a reservar`, `Nombre y apellido`, `Tu nombre completo`, `Email`, `tu@email.com`, `Contraseña`, `Mínimo 8 caracteres`, `Usá 8 caracteres como mínimo`, `Repetir contraseña`, `Repetí tu contraseña`, `Acepto los términos y condiciones y la política de privacidad`, `¿Ya tenés cuenta?`, `Iniciá sesión`. Íconos: `LucideIcons.chevronLeft`, `LucideIcons.user`, `LucideIcons.mail`, `LucideIcons.lock` (`findsNWidgets(2)`), `LucideIcons.eye` (`findsNWidgets(2)`).
2. `registro_los_4_campos_con_los_placeholder_correctos` — los 4 `TextField` con `hintText`/`keyboardType`/`textInputAction` según RD §4 (text/next, email/next, visiblePassword/next, visiblePassword/done) y ambos contraseñas `obscureText` true.
3. `registro_ojos_independientes` — tocar el `LucideIcons.eye` del campo 3: SOLO él pasa a `eyeOff` (campo 4 sigue `obscureText` true); tocar el del campo 4: ambos en `eyeOff`.
4. `registro_checkbox_alterna` — tocar el texto de los términos alterna el checkbox: assert sobre la decoración del contenedor del check (marcado: `BoxDecoration`(color: `AppColors.primary`); desmarcado: color `AppColors.surface` + borde `AppColors.border`). Helper del test: `_estadoCheckbox(tester)` que ubica el contenedor 20×20 y devuelve su decoración.
5. `registro_volver_y_footer_retornan_sin_datos` — helper `_pumpConPuerta(tester, guardaResultado)` que arma un `MaterialApp` cuyo home tiene un botón `Abrir 05` que hace `Navigator.push<bool>(MaterialPageRoute(builder: (_) => RegistroScreen()))` y guarda el valor resultante en una variable capturada por el test. Flujo: tap `Abrir 05` → tap en el chevron → vuelve al home; tap `Abrir 05` de nuevo → tocar campo email, escribir `algo`, tap `Iniciá sesión` (footer) → vuelve y el resultado queda `null` (no registró).
6. `registro_sin_overflow_375x844_y_chica` — `tester.view.physicalSize` 375×844 y 320×568; `pumpWidget` + `expect(tester.takeException(), isNull)`.

(El helper `_pumpConPuerta` se reutiliza en Task 5, paso 5, para capturar el `true` del éxito.)

- [ ] **Step 2: Run test to verify it fails**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/registro_screen_test.dart`
Expected: FAIL ("registro_screen" no existe).

- [ ] **Step 3: Implementar `lib/features/auth/registro_screen.dart`**

Estructura (todos los valores vienen del RD §4; reutilizar el helper `_inputDecoration` copiado del `login_screen.dart` 248-279 tal cual — mismos tamaños/tokens):

- `Scaffold` fondo `AppColors.bg` + `SafeArea` + `Padding` 24 horizontal + `LayoutBuilder`→`SingleChildScrollView`→`ConstrainedBox minHeight` (misma receta de anti-overflow del `LoginScreen` 77-94).
- Columna `space_between`: `_grupoVolver()` arriba (botón circular 40, radio 20, borde `border` 1, `chevron-left` 20 — `Navigator.pop(context)`); `_titular()` + `_formulario()` + `_terminos()` + `_botonCrear()` + `_footer()` abajo.
- Titular: `Crear cuenta` 28 bold + subtítulo 15 `text2`, hueco 8 (como el Login, pero SIN la marca).
- Formulario: 4 `Campo` en columna (gap 16). Cada campo = label 13 semibold (gap 7... mismo patrón del Login `_formGroup`: label + SizedBox(7)... el login usa 8; acá §4 dice 7) + `TextField` con `_inputDecoration(hint, icon)`.
  - Campo 3 (Contraseña): suffixIcon ojo + debajo el texto de ayuda `Usá 8 caracteres como mínimo` 12 `text2` — reservar altura fija del contenedor para que el layout no salte (patrón del mensaje inline del Login 188-202).
  - Campo 4 (Repetir contraseña): suffixIcon ojo independiente — ***segundo*** `bool _repetirVisible` separado de `_passwordVisible`.
- Términos: fila `Row` (gap 10, `crossAxisAlignment: center`): contenedor-del-check 20×20 radio 6 (lleno `primary` + `LucideIcons.check` blanco 13px cuando marcado / `surface` + borde `border` cuando no) + texto expandido 12 `text2` (lineHeight 1.4 — envolver en `Text` con `TextTheme.height`). Tap en el check **y en el texto** alterna (`GestureDetector` sobre la fila).
- Botón: `FilledButton` ancho completo, fondo `primary`, radio 12, padding vertical 15, `Crear cuenta` blanco 16 semibold → `_submit()` (vacío en esta task).
- Footer: `Wrap` centrado gap 6 (patrón del `_Footer` del Login): `¿Ya tenés cuenta?` 14 `text2` + `Iniciá sesión` 14 semibold `primary` con tap → `Navigator.pop(context)`.
- Padding horizontal 24 en todo el content (igual que el Login); allocation superior 28.

- [ ] **Step 4: Run test to verify it passes**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/registro_screen_test.dart`
Expected: PASS (los 6 casos).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/auth/registro_screen.dart src/FrontEnd/test/registro_screen_test.dart
git commit -m "feat(auth): pantalla 05 registrar — layout del mockup (RD §4)"
```

### Task 5: registro con validación inline + submit (RF-01/02/03/04/07/08)

**Files:**
- Modify: `src/FrontEnd/lib/features/auth/registro_screen.dart`
- Test: `src/FrontEnd/test/registro_screen_test.dart` (agregar los de validación)

**Interfaces:**
- Consumes: `validarRegistro` / `ErroresRegistro` (Task 3), `emailRegistrado` + `registrarUsuario` (Task 1).
- Produces: en éxito `registrarUsuario(...)` + `Navigator.pop(context, true)` — el `true` es lo que Task 6 espera.

- [ ] **Step 1: Agregar los tests de validación al `registro_screen_test.dart`** (casos, con helper `_insertarYEnviar` que rellena los 4 campos y tapa el botón / o `receiveAction(TextInputAction.done)` sobre Repetir):

1. `registro_submit_invalido_muestra_errores_por_campo` — submit con todo vacío: borde `danger` 1.5px en el/los `TextField` ofensivos (usar helper `_borde(tester, index)` igual que el de `login_screen_test.dart`, con 4 campos) + los 5 textos de error visibles a la vez (`Ingresá tu nombre`, `Ingresá un email válido`, `Mínimo 8 caracteres`, `Las contraseñas no coinciden`, `Aceptá los términos y condiciones`).
2. `registro_email_duplicado_muestra_error_semilla` — email ` igpi7uu@gmail.com `, el resto válido → error `Ya hay una cuenta con ese email` solo en ese campo (los otros 3 sin borde rojo).
3. `registro_escribir_limpia_solo_su_error` — con los 5 errores visibles: escribir en email → su borde vuelve a `AppColors.border` Y su texto de error desaparece; nombre/repetir/checkbox conservan los suyos.
4. `registro_checkbox_error_limpia_solo_marcando` — orden del test: primero validar con todo válido EXCEPTO el checkbox (4 errores de campos ya limpios, solo queda el de checkbox); escribir en los 4 campos no lo borra; tocar el checkbox sí.
5. `registro_submit_valido_registra_y_vuelve_true` — todo válido + checkbox → la variable capturada del helper `_pumpConPuerta` vale `true` Y `emailRegistrado('nueva@test.com')` es true (importar `usuarios_locales`; `setUp(() => resetUsuarios())`).
6. `registro_teclado_done_en_repetir_dispara_validacion` — mismo submit inválido vía tap en el campo Repetir + `tester.testTextInput.receiveAction(TextInputAction.done)`.

- [ ] **Step 2: Run test to verify it fails**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/registro_screen_test.dart`
Expected: FAIL (los errores no aparecen, registro no navega).

- [ ] **Step 3: Implementar en `registro_screen.dart`**

- Estado: 4 `TextEditingController`, 2 `bool` de visibilidad, `bool _terminos = false`, `ErroresRegistro? _errores`.
- `_submit()`: `final e = validarRegistro(nombre: ..., email: ..., password: ..., repetir: ..., terminos: _terminos); setState(() => _errores = e); if (!e.hayError) { registrarUsuario(...); Navigator.pop(context, true); }`.
- `_inputDecoration(... error: bool, ...)` — extender el helper con `error` (si el campo tiene error en `_errores`, borde `danger` 1.5px; la estructura del login ya la soporta).
- Errores: debajo de cada campo un `SizedBox(height: 20)` con el texto 13 semibold `AppColors.danger` cuando hay error (misma receta del login 186-202).
- `onChanged` por campo: limpia SOLO su propio error — si `_errores` no es null, `setState` creando una instancia nueva de `ErroresRegistro` con ese campo en null y los demás igual; alternar el checkbox limpia SOLO `terminos`.
- Acciones de teclado: `next` en Nombre/Email/Contraseña (con `FocusNode` uno por campo — `FocusScope.of(context).requestFocus(siguiente)`), `done` en Repetir → `_submit()`. "Tap fuera descarta el teclado": `GestureDetector(onTap: () => FocusScope.of(context).unfocus())` sobre el fondo del scroll — cuidado: no debe romper los taps del formulario (deja el foco intacto si el toque cae en un campo).
- El texto de ayuda NO es un error: convive (help fijo 12 + slot de error 20 debajo).

- [ ] **Step 4: Run test to verify it passes**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/registro_screen_test.dart`
Expected: PASS (los 6 de validación + los 6 del Task 4).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/auth/registro_screen.dart src/FrontEnd/test/registro_screen_test.dart
git commit -m "feat(auth): registro con validación inline y alta local (RF-01..08)"
```

### Task 6: Login integrado — el footer navega a la 05 y muestra el aviso de éxito

**Files:**
- Modify: `src/FrontEnd/lib/features/auth/login_screen.dart` (`_Footer` `onTap` + recepción del resultado)
- Test: `src/FrontEnd/test/login_screen_test.dart` (nuevos casos de integración)

**Interfaces:**
- Consumes: `RegistroScreen` (Task 4/5), `credencialesValidas` de lista local (Task 2).
- Produces: flujo completo login → 05 → login con snackbar; la 04 no cambia por dentro (mismo `home: LoginScreen` en `main.dart`).

- [ ] **Step 1: Agregar los tests al final de `test/login_screen_test.dart`** (RD registro §3):

1. `login_crear_cuenta_navega_a_la_pantalla_05` — pump `TurnosCanchaApp()`, tap en el `Crear cuenta` del footer (en la 04 es único: `findsOneWidget`), `pumpAndSettle` → aparecen textos de la 05 (`Nombre y apellido`, `Acepto los términos...`).
2. `login_volver_desde_la_05_footer_inicia_sesion_retorna` — en la 05: escribir algo en el email, tap `Iniciá sesión` (footer) → está de nuevo la 04 y el campo email de la 04 está vacío (sin prefill).
3. `login_registro_exitoso_muestra_cuenta_creada_y_login_vacio` — en la 05: formulario completo válido + checkbox → tras el pop, `find.text('Cuenta creada')` visible sobre la 04 (SnackBar) `pump` (el snackbar anima: usar `pump()` con duración, no `pumpAndSettle` directo tras el pop) y los campos de la 04 vacíos.
4. `login_acepta_usuario_registrado_end_to_end` — registrar `Marta Gómez` / `marta@test.com` / `qwerty1234` desde la 05, luego en la 04 ingresar `marta@test.com` / `qwerty1234` → navega a `UsuarioValidadoScreen` (`find.text('usuario validado')`). Con `setUp(() => resetUsuarios())` + `tearDown` si el grupo muta la lista.
5. `login_footer_04_sin_regression` — los 19 tests previos del grupo login siguen pasando (correr todo el suite).

- [ ] **Step 2: Run test to verify it fails**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/login_screen_test.dart`
Expected: FAIL (nada navega todavía).

- [ ] **Step 3: Implementar en `login_screen.dart`**

- `_Footer`: recibe `final VoidCallback onCrearCuenta` (el constructor puede seguir siendo `const`, pero el call site pasa `_Footer(onCrearCuenta: _irACrearCuenta)` y deja de ser `const`); el tap del texto `Crear cuenta` llama `widget.onCrearCuenta()`.
- Nuevo método `_irACrearCuenta()` en el State: `final creado = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const RegistroScreen())); if (creado == true && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta creada'))); }` — la 04 no muta sus controladores: por añadidura vuelve vacía (no había escrito nada) y sin prefill. `import 'registro_screen.dart';`
- NO tocar nada más: el estado 04b, el link "¿Olvidaste tu contraseña?" y la validación RF-03 siguen como están.

- [ ] **Step 4: Run test to verify it passes**

Run: `%USERPROFILE%\flutter\bin\flutter.bat test test/login_screen_test.dart`
Expected: PASS (los 19 previos + los 4-5 nuevos).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd/lib/features/auth/login_screen.dart src/FrontEnd/test/login_screen_test.dart
git commit -m "feat(auth): footer del login navega a la 05 + aviso Cuenta creada (RF-05)"
```

### Task 7: Verificación final — análisis estático + suite + visual 375×844 contra el RD §4

**Files:** sin cambios de código (solo verificación; si algo falla, corregir en la task correspondiente).

**Interfaces:** ninguna nueva.

- [ ] **Step 1: Análisis y suite completo**

```bash
cd src/FrontEnd
%USERPROFILE%\flutter\bin\flutter.bat analyze   # sin issues
%USERPROFILE%\flutter\bin\flutter.bat test      # todos los suites en PASS
```

- [ ] **Step 2: Verificación visual contra el RD §4** (mismísimo criterio que la etapa login: CDP/Chrome a 375×844 @2x o emulador):

Checklist de captura (listar capturas de cada estado):
- [ ] **Llegada al 05 desde el footer del login**: layout RD §4 completo — volver, titular sin marca, 4 campos con hint/values, help de contraseña, checkbox desmarcado, botón, footer.
- [ ] **Errores a la vez** (submit con todo vacío): 5 textos de error + bordes `danger` bajo cada campo ofensivo.
- [ ] **Checkbox marcado**: fondo `primary` + check blanco.
- [ ] **Teclado abierto sobre el form**: el campo con foco visible (scroll no rompe el layout).
- [ ] **Snackbar `Cuenta creada` sobre la 04** tras el éxito.

- [ ] **Step 3: Actualizar `docs/requerimientos/README.md` y mover el RD (RD "implementado")**

Cuando los criterios §6 del RD estén OK, mover `docs/requerimientos/registro.md` → `docs/HistRequerimientos/registro.md` con `git mv` y actualizar `docs/requerimientos/README.md` (escribir que la pantalla 05 quedó implementada). Fuentes en el header: no cambia (el `.pen` es la fuente visual).

- [ ] **Step 4: Commit final**

```bash
git add -A src/FrontEnd docs/requerimientos docs/HistRequerimientos
git commit -m "chore(auth): verificación final de la pantalla 05 — RD movido a implementado"
```
