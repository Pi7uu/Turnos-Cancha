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
                  const SizedBox(height: 16),
                  _Comodidades(cancha: cancha),
                  const SizedBox(height: 16),
                  _Sobre(cancha: cancha),
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

/// Bloque "Comodidades" del mockup ( RD detalle-comodidades §4 ): 5 ítems
/// fijos con estado disponible/no disponible + aviso si hay faltantes.
class _Comodidades extends StatelessWidget {
  const _Comodidades({required this.cancha});

  final Cancha cancha;

  /// Ítems fijos del mockup: ( label, slug, ícono ).
  static const List<(String, String, IconData)> _items = [
    ('Duchas', 'duchas', LucideIcons.showerHead),
    ('Estac.', 'estac', LucideIcons.squareParking),
    ('Aire a/c', 'aire-ac', LucideIcons.snowflake),
    ('Agua', 'agua', LucideIcons.droplet),
    ('WiFi', 'wifi', LucideIcons.wifi),
  ];

  @override
  Widget build(BuildContext context) {
    final faltantes = cancha.comodidadesNoDisponibles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Comodidades',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final (label, slug, icono) in _items)
                Flexible(
                  child: _ItemComodidad(
                    label: label,
                    slug: slug,
                    icono: icono,
                    disponible: !faltantes.contains(label),
                  ),
                ),
            ],
          ),
        ),
        if (faltantes.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Aviso(faltantes: faltantes),
        ],
      ],
    );
  }
}

/// Ítem de comodidad: círculo 48×48 con glyph + label ( mockup: vertical,
/// hueco 6 ). Los no disponibles van atenuados ( RD §4 ).
class _ItemComodidad extends StatelessWidget {
  const _ItemComodidad({
    required this.label,
    required this.slug,
    required this.icono,
    required this.disponible,
  });

  final String label;
  final String slug;
  final IconData icono;
  final bool disponible;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(
      icono,
      size: 21,
      color: disponible ? AppColors.text : AppColors.text2,
    );
    final texto = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.text2,
      ),
    );
    return Container(
      key: ValueKey('comodidad-$slug'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: disponible
                  ? AppColors.surface
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: disponible
                  ? glyph
                  : Opacity(opacity: 0.45, child: glyph),
            ),
          ),
          const SizedBox(height: 6),
          disponible ? texto : Opacity(opacity: 0.5, child: texto),
        ],
      ),
    );
  }
}

/// Aviso ámbar con las comodidades no disponibles ( texto generado: nombres
/// completos unidos con ` y ` — RD §4 ).
class _Aviso extends StatelessWidget {
  const _Aviso({required this.faltantes});

  final List<String> faltantes;

  @override
  Widget build(BuildContext context) {
    const nombresCompletos = {'Estac.': 'Estacionamiento'};
    final nombres =
        faltantes.map((f) => nombresCompletos[f] ?? f).join(' y ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(LucideIcons.info, size: 14, color: Color(0xFFF59E0B)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '$nombres no disponibles hoy',
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFF59E0B),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bloque "Sobre esta cancha" del mockup ( §4 ): título + párrafo.
class _Sobre extends StatelessWidget {
  const _Sobre({required this.cancha});

  final Cancha cancha;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sobre esta cancha',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cancha.descripcion,
          style: const TextStyle(
            fontSize: 14,
            height: 1.55,
            color: AppColors.text2,
          ),
        ),
      ],
    );
  }
}
