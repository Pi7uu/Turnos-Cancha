/// Modelo de datos local simulado del registro (RD registro §2, RF-04).
///
/// La lista de usuarios vive **en memoria**: no hay llamadas HTTP ni
/// persistencia, así que al cerrar la app vuelve al estado inicial. Reemplazar
/// por la API REST cuando exista (`/api/`).
library;

import 'package:flutter/foundation.dart';

/// Un usuario registrado localmente.
///
/// Los valores se guardan ya normalizados como define el RD registro RF-04:
/// [nombre] con `trim`, [email] con `trim` y en minúsculas (clave única de la
/// lista) y [password] tal cual se escribió.
class UsuarioLocal {
  const UsuarioLocal({
    required this.nombre,
    required this.email,
    required this.password,
  });

  /// Nombre tal como se escribió, sin espacios extremos.
  final String nombre;

  /// Email en minúsculas y sin espacios extremos: identifica al usuario.
  final String email;

  /// Contraseña sin modificar, sensible a mayúsculas.
  final String password;
}

/// Usuario de la etapa login (`docs/requerimientos/login.md`), semilla de la
/// lista (RD registro §2).
const UsuarioLocal _usuarioSemilla = UsuarioLocal(
  nombre: 'Usuario inicial',
  email: 'igpi7uu@gmail.com',
  password: 'igpi7uu',
);

final List<UsuarioLocal> _usuarios = <UsuarioLocal>[_usuarioSemilla];

String _normalizarEmail(String email) => email.trim().toLowerCase();

/// `true` si ya hay una cuenta con [email] (comparación sin mayúsculas y con
/// `trim`, RD registro RF-03).
bool emailRegistrado(String email) {
  final String emailNormalizado = _normalizarEmail(email);
  return _usuarios.any(
    (UsuarioLocal usuario) => usuario.email == emailNormalizado,
  );
}

/// Devuelve el usuario registrado con [email], o `null` si no existe.
///
/// Igual que [emailRegistrado], el email se busca con `trim` y sin distinguir
/// mayúsculas/minúsculas.
UsuarioLocal? usuarioPorEmail(String email) {
  final String emailNormalizado = _normalizarEmail(email);
  for (final UsuarioLocal usuario in _usuarios) {
    if (usuario.email == emailNormalizado) {
      return usuario;
    }
  }
  return null;
}

/// Agrega el usuario a la lista en memoria (RD registro RF-04).
///
/// Guarda [nombre] con `trim`, [email] normalizado y [password] tal cual.
/// Lanza [ArgumentError] si [email] ya está registrado.
void registrarUsuario(String nombre, String email, String password) {
  final String emailNormalizado = _normalizarEmail(email);
  if (emailRegistrado(emailNormalizado)) {
    throw ArgumentError.value(
      email,
      'email',
      'Ya hay una cuenta con ese email',
    );
  }
  _usuarios.add(
    UsuarioLocal(
      nombre: nombre.trim(),
      email: emailNormalizado,
      password: password,
    ),
  );
}

/// Vuelve la lista al estado inicial (solo el usuario semilla).
@visibleForTesting
void resetUsuarios() {
  _usuarios
    ..clear()
    ..add(_usuarioSemilla);
}
