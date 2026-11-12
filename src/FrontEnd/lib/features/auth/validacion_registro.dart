/// Validación pura por campo del formulario de registro (RD registro RF-03).
///
/// No conoce la UI: recibe los valores crudos de los campos y devuelve un
/// [ErroresRegistro] con un mensaje por campo inválido o `null` si el campo es
/// válido. La pantalla (Task 5) es la encargada de mostrarlos.
library;

import 'usuarios_locales.dart';

/// Formato de email del RD registro RF-03, aplicado sobre el valor con `trim`.
final RegExp _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Errores por campo del registro (RD registro RF-03: todos a la vez, sin
/// mensajes globales).
///
/// Cada campo vale `null` cuando es válido.
final class ErroresRegistro {
  const ErroresRegistro({
    this.nombre,
    this.email,
    this.password,
    this.repetir,
    this.terminos,
  });

  /// Error de "Nombre y apellido" (`Ingresá tu nombre`), o `null`.
  final String? nombre;

  /// Error de "Email" (`Ingresá un email válido` /
  /// `Ya hay una cuenta con ese email`), o `null`.
  final String? email;

  /// Error de "Contraseña" (`Mínimo 8 caracteres`), o `null`.
  final String? password;

  /// Error de "Repetir contraseña" (`Las contraseñas no coinciden`), o `null`.
  final String? repetir;

  /// Error del checkbox de términos (`Aceptá los términos y condiciones`), o
  /// `null` si está marcado.
  final String? terminos;

  /// `true` si al menos un campo tiene error.
  bool get hayError =>
      nombre != null ||
      email != null ||
      password != null ||
      repetir != null ||
      terminos != null;
}

/// Valida los cinco campos del registro y devuelve sus errores (RD registro
/// RF-03).
///
/// Orden por campo:
/// - [nombre]: inválido si queda vacío tras `trim`.
/// - [email]: formato sobre el valor con `trim` (las mayúsculas son formato
///   válido); si el formato es correcto, busca duplicados con
///   [emailRegistrado] (que normaliza `trim` + minúsculas).
/// - [password]: mínimo 8 caracteres sobre el valor crudo, sin `trim`.
/// - [repetir]: comparación exacta contra [password], sin `trim`; dos valores
///   vacíos coinciden y no generan error.
/// - [terminos]: inválido si el checkbox está desmarcado.
ErroresRegistro validarRegistro({
  required String nombre,
  required String email,
  required String password,
  required String repetir,
  required bool terminos,
}) {
  final String emailTrimado = email.trim();

  String? errorEmail;
  if (!_formatoEmail.hasMatch(emailTrimado)) {
    errorEmail = 'Ingresá un email válido';
  } else if (emailRegistrado(emailTrimado)) {
    errorEmail = 'Ya hay una cuenta con ese email';
  }

  return ErroresRegistro(
    nombre: nombre.trim().isEmpty ? 'Ingresá tu nombre' : null,
    email: errorEmail,
    password: password.length < 8 ? 'Mínimo 8 caracteres' : null,
    repetir: repetir != password ? 'Las contraseñas no coinciden' : null,
    terminos: terminos ? null : 'Aceptá los términos y condiciones',
  );
}
