import 'package:flutter/material.dart';

import 'core/api/api_client.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/login_screen.dart';

void main() => runApp(const TurnosCanchaApp());

/// Raíz de la app TurnosCancha.
class TurnosCanchaApp extends StatelessWidget {
  const TurnosCanchaApp({super.key, this.apiClient});

  /// Cliente de la API ( inyectable para tests — RD api-auth RF-02 ).
  final ApiClient? apiClient;

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
      // El login real consume /api/auth/login/ ( RD api-auth ); la sesión
      // ( cookie ) vive en el ApiClient de la app.
      home: LoginScreen(onIngresar: (_, _) {}, apiClient: apiClient),
    );
  }
}
