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
      // Placeholder no-op hasta la Tarea 5 (flujo de validación).
      home: LoginScreen(onIngresar: (_, _) {}),
    );
  }
}
