import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'features/auth/login_screen.dart';

void main() => runApp(const TurnosCanchaApp());

/// Raíz de la app TurnosCancha.
class TurnosCanchaApp extends StatelessWidget {
  const TurnosCanchaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurnosCancha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.bg,
      ),
      // Cada intento de login notifica al padre con los valores crudos.
      // No hay backend ni HTTP en esta etapa (CA 7) ni persistencia de
      // sesión (spec §3): la validación vive en LoginScreen.
      home: LoginScreen(onIngresar: (_, _) {}),
    );
  }
}
