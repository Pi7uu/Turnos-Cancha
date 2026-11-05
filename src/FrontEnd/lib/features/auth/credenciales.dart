/// Validación local de credenciales (RD registro RF-06).
///
/// La comparación se hace local en la app contra la lista de usuarios de
/// `usuarios_locales.dart`: no hay llamadas HTTP y no hay persistencia de
/// sesión. Reemplazar por `/api/auth/login/` cuando exista la API REST
/// (spec §8).
library;

import 'usuarios_locales.dart';

/// `true` si las credenciales coinciden con algún usuario de la lista local
/// (incluida la semilla de la etapa login, RD registro §2).
///
/// - Email: se busca en la lista **sin distinguir mayúsculas/minúsculas** y con
///   `trim` de los espacios extremos (RD registro RF-04).
/// - Contraseña: comparación **exacta** (sin trim, sensible a mayúsculas).
bool credencialesValidas(String email, String password) {
  final UsuarioLocal? usuario = usuarioPorEmail(email.trim());
  return usuario != null && usuario.password == password;
}
