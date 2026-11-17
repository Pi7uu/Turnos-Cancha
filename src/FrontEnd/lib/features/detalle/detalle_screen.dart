import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../inicio/cancha.dart';

/// Pantalla Detalle de cancha ( pantalla 02 — se construye por partes, RD
/// `docs/requerimientos/detalle-hero.md` ): por ahora hero + info + nombre +
/// dirección. Es una pantalla **apilada** ( se empuja desde el Inicio ) con
/// botón Volver que hace `pop`.
///
/// Las partes siguientes ( comodidades, "Sobre esta cancha", horarios y
/// barra de reserva ) llegan en sus RDs.
class DetalleScreen extends StatelessWidget {
  const DetalleScreen({super.key, required this.cancha});

  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Hero(cancha: cancha),
            Padding(
              padding:
                  const EdgeInsets.only(top: 18, left: 16, right: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PrecioRating(cancha: cancha),
                  const SizedBox(height: 16),
                  _NombreDireccion(cancha: cancha),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero del mockup: foto a todo el ancho ( 240 + el safe area superior, la
/// foto va detrás de la status bar ) con los 3 botones circulares.
class _Hero extends StatelessWidget {
  const _Hero({required this.cancha});

  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    final alto = 240 + MediaQuery.of(context).padding.top;
    return SizedBox(
      height: alto,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(cancha.hero, fit: BoxFit.cover),
          ),
          SafeArea(
            top: true,
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 16,
                  child: _BotonHero(
                    clave: 'detalle-volver',
                    icono: LucideIcons.chevronLeft,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  left: 269,
                  top: 16,
                  child: _BotonHero(
                    clave: 'detalle-compartir',
                    icono: LucideIcons.share2,
                  ),
                ),
                Positioned(
                  left: 319,
                  top: 16,
                  child: _BotonHero(
                    clave: 'detalle-favorito',
                    icono: LucideIcons.heart,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón circular flotante del hero. Sin `onTap` = inerte ( RF-03 ).
class _BotonHero extends StatelessWidget {
  const _BotonHero({
    required this.clave,
    required this.icono,
    this.onTap,
  });

  final String clave;
  final IconData icono;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        key: ValueKey(clave),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x260F172A),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Icon(icono, size: 19, color: AppColors.text),
        ),
      ),
    );
  }
}

/// Fila badge/rating/precio del mockup ( §4 ). El badge `PREMIUM` solo
/// aparece en canchas premium.
class _PrecioRating extends StatelessWidget {
  const _PrecioRating({required this.cancha});

  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (cancha.premium)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ),
            if (cancha.premium) const SizedBox(width: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(LucideIcons.star,
                    size: 15, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  '${cancha.puntuacion}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              cancha.precio,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'por hora',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.text2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Nombre y dirección de la cancha.
class _NombreDireccion extends StatelessWidget {
  const _NombreDireccion({required this.cancha});

  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          cancha.nombre,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(LucideIcons.mapPin, size: 16, color: AppColors.text2),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                cancha.direccion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.text2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
