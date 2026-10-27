/// Validación local de credenciales (etapa hardcodeada, spec `docs/specs/login.md` RF-03).
///
/// La comparación se hace local en la app: no hay llamadas HTTP (CA 7) y no
/// hay persistencia de sesión. Reemplazar por `/api/auth/login/` cuando exista
/// la API REST (spec §8).
library;

const String _emailValido = 'igpi7uu@gmail.com';
const String _passwordValida = 'igpi7uu';

/// `true` si las credenciales coinciden con el usuario único de esta etapa.
///
/// - Email: se compara **sin distinguir mayúsculas/minúsculas** y con `trim`
///   de los espacios extremos.
/// - Contraseña: comparación **exacta** (sin trim, sensible a mayúsculas).
bool credencialesValidas(String email, String password) {
  return email.trim().toLowerCase() == _emailValido &&
      password == _passwordValida;
}
