/// Pantalla Perfil ( RD `docs/HistRequerimientos/perfil.md` §4 ): tarjeta de
/// cuenta con avatar y estadísticas, menú de opciones y `Cerrar sesión`.
///
/// Es el tab Perfil del shell ( clave `perfil-screen` ). Los datos de la
/// cuenta son estáticos del mockup ( §8 ); las acciones llegan en RF-02.
library;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key, this.onIrAMisReservas});

  /// Cambia al tab Mis reservas ( RF-02: fila `Mis reservas` ).
  final VoidCallback? onIrAMisReservas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 18),
                const _TarjetaCuenta(),
                const SizedBox(height: 18),
                _TarjetaMenu(onIrAMisReservas: onIrAMisReservas),
                const SizedBox(height: 18),
                const _BotonCerrarSesion(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta `Cuenta`: avatar con iniciales, nombre, email y 3 estadísticas.
class _TarjetaCuenta extends StatelessWidget {
  const _TarjetaCuenta();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.all(Radius.circular(42)),
            ),
            child: const Center(
              child: Text(
                'MR',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Martín Rodríguez',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'martin.rodriguez@gmail.com',
            style: TextStyle(fontSize: 14, color: AppColors.text2),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _Stat(valor: '12', label: 'Reservas'),
                _Stat(valor: '4', label: 'Favoritas'),
                _Stat(valor: '340', label: 'Puntos'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Columna de estadística ( valor + label, centrada, hueco 2 ).
class _Stat extends StatelessWidget {
  const _Stat({required this.valor, required this.label});

  final String valor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.text2),
        ),
      ],
    );
  }
}

/// Tarjeta `Menu`: 5 filas con ícono + label + chevron, separadores 1px.
class _TarjetaMenu extends StatelessWidget {
  const _TarjetaMenu({this.onIrAMisReservas});

  final VoidCallback? onIrAMisReservas;

  @override
  Widget build(BuildContext context) {
    final filas = <(IconData, String, VoidCallback?)>[
      (LucideIcons.user, 'Mis datos', null),
      (LucideIcons.calendar, 'Mis reservas', onIrAMisReservas),
      (LucideIcons.creditCard, 'Métodos de pago', null),
      (LucideIcons.bell, 'Notificaciones', null),
      (LucideIcons.circleQuestionMark, 'Ayuda', null),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          for (var i = 0; i < filas.length; i++) ...[
            if (i > 0)
              Container(height: 1, color: AppColors.border),
            _FilaMenu(
              key: filas[i].$2 == 'Mis reservas'
                  ? const ValueKey('fila-mis-reservas')
                  : null,
              icono: filas[i].$1,
              label: filas[i].$2,
              onTap: filas[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

/// Fila del menú: caja de ícono 36×36, label 15px w500 y chevron.
class _FilaMenu extends StatelessWidget {
  const _FilaMenu({super.key, required this.icono, required this.label, this.onTap});

  final IconData icono;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  // `$surface-2` del mockup ( #F1F5F9 ) — literal sin token.
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                child: Center(
                  child: Icon(icono, size: 17, color: AppColors.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.text2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón `Cerrar sesión` ( fondo rojo claro, texto/ícono `$danger` ).
///
/// RF-02: vuelve al login con `pushAndRemoveUntil` — la pila se limpia y el
/// botón atrás no regresa al shell.
class _BotonCerrarSesion extends StatelessWidget {
  const _BotonCerrarSesion();

  void _cerrarSesion(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        // El login exitoso hace pushReplacement al MainShell por su cuenta
        // ( login_screen.dart ); `onIngresar` es solo un hook de notificación.
        builder: (_) => LoginScreen(onIngresar: (_, _) {}),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('cerrar-sesion'),
      onTap: () => _cerrarSesion(context),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.logOut, size: 17, color: AppColors.danger),
            SizedBox(width: 8),
            Text(
              'Cerrar sesión',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
