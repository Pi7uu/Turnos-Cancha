import 'package:flutter/material.dart';

/// Tokens de color del design system (spec `docs/specs/login.md` §5).
abstract final class AppColors {
  /// Botón, marca, links, acentos — `#16A34A`
  static const primary = Color(0xFF16A34A);

  /// Fondo de pantalla — `#F5F7FA`
  static const bg = Color(0xFFF5F7FA);

  /// Fondo de inputs — `#FFFFFF`
  static const surface = Color(0xFFFFFFFF);

  /// Texto principal — `#0F172A`
  static const text = Color(0xFF0F172A);

  /// Texto secundario, placeholders — `#64748B`
  static const text2 = Color(0xFF64748B);

  /// Bordes de inputs — `#E2E8F0`
  static const border = Color(0xFFE2E8F0);

  /// Borde de error y mensaje de error — `#EF4444`
  static const danger = Color(0xFFEF4444);
}
