# Login (pantallas 04/04b) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter login screen (normal + error state) with local hardcoded credential validation and a success screen, including installing the Flutter/Android toolchain and verifying visually on an emulator.

**Architecture:** Single Flutter app rooted at `src/FrontEnd/` (package `turnos_cancha`). A `StatefulWidget` login screen holds the two `TextEditingController`s and the error flag; credential checking is a pure function so it is unit-testable; success navigates via plain `Navigator.push` to a blank screen. No state-management or routing libraries (YAGNI).

**Tech Stack:** Flutter stable (Windows), Dart, `flutter_test`, `lucide_icons` (only third-party runtime dep), Android SDK + AVD for verification.

**Spec:** `docs/specs/login.md` (all copy, tokens and behavior come from there; the mockup `docs/prototipos/pantallas/04-login.png` is the layout reference)

## Global Constraints

- UI language `es-AR`; exact strings: `Iniciá sesión`, `Reservá tu cancha en segundos`, `Email`, `tu@email.com`, `Contraseña`, `Tu contraseña`, `¿Olvidaste tu contraseña?`, `Ingresar`, `¿No tenés cuenta?`, `Crear cuenta`, `El mail o la contraseña son incorrectos`, `usuario validado` (all lowercase for the last one).
- Color tokens: primary `#16A34A`, bg `#F5F7FA`, surface `#FFFFFF`, text `#0F172A`, text-2 `#64748B`, border `#E2E8F0`, danger `#EF4444`.
- Sizes: logo 44×44 radius 13; title 28 bold; subtitle 15; labels 13 semibold; inputs radius 12; link 13; button radius 12, text 16 semibold white; footer 14; error message 13 semibold; error borders 1.5px `danger` on BOTH inputs.
- Credentials: email `igpi7uu@gmail.com` compared trimmed + case-insensitive; password `igpi7uu` exact. Empty/incorrect → error state 04b. Correct → push `usuario validado` screen.
- Font: Flutter default (Roboto) — spec explicitly allows this; do NOT add `google_fonts` or any package that fetches over the network (acceptance criterion 7: no HTTP during login).
- Reference viewport 375×844; layout must not overflow on smaller screens.
- Project creation: `flutter create --org com.turnoscancha --project-name turnos_cancha .` inside `src/FrontEnd/`.
- Install locations (adjustable, say so if blocked): Flutter `C:\src\flutter`, Android SDK `C:\src\android-sdk`, JDK 17 via `winget install Microsoft.OpenJDK.17`.
- Links "Crear cuenta" and "¿Olvidaste tu contraseña?" are visible but must do nothing when tapped.

## Review Focus

1. **Email comparison rules** (trim + case-insensitive; password exact, no trim) — pinned by Task 4 tests `credenciales_validas_*` (mixed-case/whitespace email passes; password with trailing space fails).
2. **Empty fields show the same 04b error** (red borders + message), not a different "required field" validation — pinned by Task 5 test `login_campos_vacios_muestra_estado_error`.
3. **Error clears when typing in EITHER field** — pinned by Task 5 tests `login_escribir_en_email_limpia_error` and `login_escribir_en_password_limpia_error`.
4. **Keyboard "done" runs the same validation as the button** — pinned by Task 5 test `login_teclado_dispara_validacion` (via `tester.testTextInput.receiveAction(TextInputAction.done)`).
5. **No overflow on small screens** — pinned by Task 3 test `login_sin_overflow_en_375x844_y_pantalla chica` (sets surface size 375×844 and 320×568, asserts no exceptions).

---

### Task 1: Toolchain — Flutter SDK + JDK + Android SDK + emulator

**Files:** none in the repo (machine-level installs only).

**Interfaces:** Produces `flutter` on PATH, an Android AVD named `turnos_api_35`, and a booted emulator visible to `flutter devices` — everything later tasks run against.

- [ ] **Step 1: Install Flutter stable**

```bash
git clone https://github.com/flutter/flutter.git -b stable C:/src/flutter
# add C:\src\flutter\bin to the user PATH (setx PATH "%PATH%;C:\src\flutter\bin" or GUI), then in a NEW shell:
flutter --version   # first run downloads the Dart SDK — must succeed
```

- [ ] **Step 2: Install JDK 17 and Android SDK command-line tools**

```bash
winget install Microsoft.OpenJDK.17
# download commandlinetools-win-*.zip from developer.android.com, extract to C:/src/android-sdk/cmdline-tools/latest
java -version   # 17.x
```

- [ ] **Step 3: Install SDK packages and create the AVD** (run sdkmanager/avdmanager via `cmd`; use the highest API level `sdkmanager --list` offers, adjust the `35` below accordingly)

```bat
sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0" "emulator" "system-images;android-35;google_apis;x86_64"
avdmanager create avd -n turnos_api_35 -k "system-images;android-35;google_apis;x86_64" -d pixel_7
```

- [ ] **Step 4: Accept licenses and verify**

```bash
flutter doctor --android-licenses   # accept all (a y-loop is fine)
flutter doctor -v                   # Android toolchain + emulator should be found
```

- [ ] **Step 5: Boot the emulator and confirm Flutter sees it**

```bash
flutter emulators --launch turnos_api_35
flutter devices   # must list the emulator (e.g. sdk gphone64 • android)
```

If the machine lacks virtualization and the emulator will not boot, note it and use `flutter run -d chrome` as the visual-verification fallback in Task 6.

### Task 2: Project scaffold + commit the spec

**Files:**
- Create: everything generated by `flutter create` under `src/FrontEnd/` (lib/, test/, android/, pubspec.yaml, …)
- Commit: `docs/specs/login.md` (currently untracked; do NOT commit the modified `docs/prototipos/mockups.pen` — that is user work in progress)

**Interfaces:** Produces the `turnos_cancha` package (imports look like `package:turnos_cancha/…`) with a passing template test.

- [ ] **Step 1: Create the project inside src/FrontEnd**

```bash
cd src/FrontEnd
flutter create --org com.turnoscancha --project-name turnos_cancha .
flutter pub get
flutter test   # template counter test must PASS
```

- [ ] **Step 2: Commit spec + scaffold**

```bash
git add docs/specs/login.md src/FrontEnd
git commit -m "feat: scaffold Flutter project y especificación de login"
```

### Task 3: Login screen UI (RF-01, RF-02 toggle) + design tokens

**Files:**
- Create: `src/FrontEnd/lib/core/theme/app_colors.dart`
- Create: `src/FrontEnd/lib/features/auth/login_screen.dart`
- Modify: `src/FrontEnd/lib/main.dart` (replace template; `debugShowCheckedModeBanner: false`, `home: LoginScreen(onIngresar: (_, __) {})` — placeholder no-op, replaced in Task 5)
- Delete: `src/FrontEnd/test/widget_test.dart` (template counter test)
- Test: `src/FrontEnd/test/login_screen_test.dart`

**Interfaces:**
- Consumes: scaffold from Task 2.
- Produces: `class AppColors` with static consts `primary, bg, surface, text, text2, border, danger` (Color); `class LoginScreen extends StatefulWidget` (const constructor). The button's `onPressed` is intentionally a no-op in this task; Task 5 wires it to `void Function(String email, String password) onIngresar` — define that callback parameter now (required) so Task 5 only fills the callback.

- [ ] **Step 1: Write the failing widget tests** in `test/login_screen_test.dart` (pump `const TurnosCanchaApp()`; assert `find.text` for every string in Global Constraints, `find.byIcon(LucideIcons.sportsSoccer)`, `find.byIcon(LucideIcons.eye)`), plus:
  - `login_ojo_alterna_visibilidad`: default `TextField` (the password one) has `obscureText == true`; after `tester.tap(find.byIcon(LucideIcons.eye))` + `pump`, `obscureText == false`; icon becomes `LucideIcons.eyeOff`; tapping again reverts.
  - `login_sin_overflow_en_375x844_y_pantalla_chica`: `tester.view.physicalSize`/`devicePixelRatio` set to 375×844 then 320×568, pump app, `tester.takeException()` is null; reset view in `tearDown`.
  - `login_links_no_navegan`: tapping `¿Olvidaste tu contraseña?` and `Crear cuenta` leaves the login screen visible (no route pushed).

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd src/FrontEnd && flutter test test/login_screen_test.dart`
Expected: FAIL — `TurnosCanchaApp`/`LoginScreen` undefined, icons unknown.

- [ ] **Step 3: Implement**

`app_colors.dart`: the seven constants from Global Constraints. `login_screen.dart`: `Column` with padding horizontal 24 — brand row (centered: 44×44 `AppColors.primary` box, radius 13, white `LucideIcons.sportsSoccer`, `TurnosCancha` 22 bold primary), title, subtitle, `Spacer()`, Email label + `TextField` (`TextInputType.emailAddress`, `TextInputAction.next`, prefix `LucideIcons.mail`, hint `tu@email.com`, white bg, border `AppColors.border` radius 12), Contraseña label + `TextField` (`obscureText` driven by an `_obscure` bool, `TextInputAction.done`, `onSubmitted: (_) => widget.onIngresar(...)` — leave submitted wiring minimal, Task 5 completes it, prefix `LucideIcons.lock`, hint `Tu contraseña`, suffix icon toggle `LucideIcons.eye`/`eyeOff`), `¿Olvidaste tu contraseña?` right-aligned (13, primary, `GestureDetector` with empty onTap), `Ingresar` `FilledButton`-style full-width (bg primary, radius 12, white 16 semibold, `onPressed: () => widget.onIngresar(...)`), `Spacer()`, centered footer `¿No tenés cuenta? Crear cuenta`. Sizes exactly per Global Constraints.

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd src/FrontEnd && flutter test test/login_screen_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd
git commit -m "feat: pantalla de login (wireframe 04) con tokens y toggle de contraseña"
```

### Task 4: Credential validation — pure function (RF-03 rules)

**Files:**
- Create: `src/FrontEnd/lib/features/auth/credenciales.dart`
- Test: `src/FrontEnd/test/credenciales_test.dart`

**Interfaces:**
- Produces: `bool credencialesValidas(String email, String password)` — trims + lowercases the email before comparing against `igpi7uu@gmail.com`, compares the password exactly against `igpi7uu`.

- [ ] **Step 1: Write the failing unit tests** — table-driven cases:
  - `credenciales_validas_match_exacto` → true for (`igpi7uu@gmail.com`, `igpi7uu`)
  - `credenciales_validas_email_case_insensitive_y_trim` → true for (`  IgPi7Uu@GmAiL.com `, `igpi7uu`)
  - `credenciales_validas_password_no_se_trimpea` → false for (`igpi7uu@gmail.com`, `igpi7uu `) and (`igpi7uu@gmail.com`, ` Igpi7uu`)
  - `credenciales_validas_email_incorrecto`, `credenciales_validas_password_incorrecto`, `credenciales_validas_vacios` → false

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd src/FrontEnd && flutter test test/credenciales_test.dart`
Expected: FAIL — import error / undefined function.

- [ ] **Step 3: Implement `credencialesValidas`** in `lib/features/auth/credenciales.dart` (constants `_emailValido`, `_passwordValida` private to the file).

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd src/FrontEnd && flutter test test/credenciales_test.dart`
Expected: all PASS.

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd
git commit -m "feat: validación local de credenciales (hardcodeada)"
```

### Task 5: Login flow — error state 04b, clear-on-type, navigation (RF-03/04/05)

**Files:**
- Create: `src/FrontEnd/lib/features/auth/usuario_validado_screen.dart`
- Modify: `src/FrontEnd/lib/features/auth/login_screen.dart`
- Modify: `src/FrontEnd/lib/main.dart` (wire the real callback into `LoginScreen`)
- Test: extend `src/FrontEnd/test/login_screen_test.dart`

**Interfaces:**
- Consumes: `credencialesValidas` from Task 4; `LoginScreen.onIngresar` from Task 3.
- Produces: `class UsuarioValidadoScreen extends StatelessWidget` — white `Scaffold`, `Center(child: Text('usuario validado'))`.

- [ ] **Step 1: Write the failing flow tests** (helper `_ingresar(tester, email, password)` = enterText both fields + tap `Ingresar` + `pumpAndSettle`):
  - `login_credenciales_correctas_navega_a_exito`: after `_ingresar` with valid creds, `find.text('usuario validado')` is one widget.
  - `login_credenciales_incorrectas_muestra_estado_error`: wrong creds → `find.text('El mail o la contraseña son incorrectos')` one widget; BOTH `TextField`s have enabled-border color `AppColors.danger` (inspect `decoration.enabledBorder as OutlineInputBorder`) and the button still visible.
  - `login_campos_vacios_muestra_estado_error`: `_ingresar(tester, '', '')` → same error message + red borders.
  - `login_email_case_insensitive_y_trim_navega_a_exito`: `  IgPi7Uu@GmAiL.com ` + `igpi7uu` → success screen.
  - `login_escribir_en_email_limpia_error` / `login_escribir_en_password_limpia_error`: trigger error, `enterText` one field → error message gone, that field's border color back to `AppColors.border`.
  - `login_reintento_incorrecto_vuelve_a_mostrar_error`: trigger error → type → error cleared → submit wrong creds again → error visible again.
  - `login_teclado_dispara_validacion`: focus the password field, `enterText` valid password, email field already valid, `await tester.testTextInput.receiveAction(TextInputAction.done)` + `pumpAndSettle` → success screen.

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd src/FrontEnd && flutter test test/login_screen_test.dart`
Expected: FAIL (no error state, no navigation yet).

- [ ] **Step 3: Implement the flow**

In `LoginScreen`: add `bool _error = false`; `_ingresar()` reads both controllers, sets `_error = !credencialesValidas(...)`, and on success `Navigator.push` to `UsuarioValidadoScreen`; both `TextField`s get `onChanged: (_) { if (_error) setState(() => _error = false); }`; error state renders the danger borders (1.5px) on both inputs + the message below the password field (13 semibold `AppColors.danger`, reserved `SizedBox` height so the layout does not jump between states); `onSubmitted` calls `_ingresar()`. Create `usuario_validado_screen.dart` and pass `onIngresar: _ingresar`-wiring from `main.dart`.

- [ ] **Step 4: Run the full test suite and analyze**

Run: `cd src/FrontEnd && flutter analyze && flutter test`
Expected: no issues, all PASS (Tasks 3–5 tests together).

- [ ] **Step 5: Commit**

```bash
git add src/FrontEnd
git commit -m "feat: flujo de login con estado de error 04b y pantalla de éxito"
```

### Task 6: Final verification on emulator (acceptance criteria 1–7)

**Files:** none expected (fixes only if verification finds gaps).

- [ ] **Step 1: Static gate**

Run: `cd src/FrontEnd && flutter analyze && flutter test`
Expected: clean analyze, all tests pass. (Criterion 7 is also satisfied by construction: no HTTP/network packages in `pubspec.yaml` — verify with `flutter pub deps`.)

- [ ] **Step 2: Run on the emulator and walk the acceptance checklist**

```bash
cd src/FrontEnd && flutter run -d turnos_api_35   # or the listed emulator id
```

Manually verify against `docs/prototipos/pantallas/04-login.png` and spec §6: (1) app starts on login matching wireframe 04; (2) valid creds reach `usuario validado`; (3) wrong/empty creds show red borders + exact error message on the same screen; (4) eye toggles visibility; (5) typing clears the error; (6) all texts in Spanish and exact; (7) no HTTP (confirmed in Step 1). Also rotate/resize or try a smaller device profile to confirm no overflow.

- [ ] **Step 3: Commit any fixes, final commit if none**

```bash
git add -A src/FrontEnd && git commit -m "chore: ajustes finales de verificación del login" || echo "sin cambios"
```
