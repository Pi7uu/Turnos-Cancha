import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/colores.dart';
import 'core/router.dart';

ThemeData buildTemaApp() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColores.primario,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColores.primario,
    onPrimary: Colors.white,
    secondary: AppColores.primarioOscuro,
    onSecondary: Colors.white,
    surface: AppColores.superficie,
    onSurface: AppColores.texto,
    error: AppColores.peligro,
    onError: Colors.white,
  );

  const textStyleBase = TextStyle(
    color: AppColores.texto,
    fontFamily: 'Roboto',
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColores.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColores.superficie,
      foregroundColor: AppColores.texto,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColores.texto,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColores.superficie,
      elevation: 0,
      height: 68,
      indicatorColor: AppColores.primarioClaro,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final activo = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: activo ? AppColores.primario : AppColores.textoSuave,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final activo = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
          color: activo ? AppColores.primario : AppColores.textoSuave,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColores.primario,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColores.primario,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: AppColores.primario),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColores.primario,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColores.neutroClaro,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: const TextStyle(color: AppColores.textoSuave),
      labelStyle: const TextStyle(color: AppColores.textoSuave),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColores.primario, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColores.peligro),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColores.peligro, width: 1.5),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColores.superficie,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColores.texto,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'Roboto',
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dividerTheme: const DividerThemeData(color: AppColores.borde, space: 1),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800, color: AppColores.texto),
      titleLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColores.texto),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColores.texto),
      bodyMedium: textStyleBase,
      bodySmall: TextStyle(fontSize: 13, color: AppColores.textoSuave),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColores.textoSuave,
      ),
    ),
  );
}

class TurnosCanchaApp extends ConsumerWidget {
  const TurnosCanchaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'TurnosCancha',
      debugShowCheckedModeBanner: false,
      theme: buildTemaApp(),
      routerConfig: router,
    );
  }
}
