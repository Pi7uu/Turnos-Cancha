/// Pantalla Favoritos ( RD `docs/HistRequerimientos/favoritos.md` §4 ):
/// lista de canchas favoritas con foto, nombre + corazón, distancia, rating,
/// precio y botón `Reservar` ( abre el Detalle ).
///
/// Es el tab Favoritos del shell ( clave `favoritos-screen` ). Los datos
/// salen del store [favoritosLocales] ( sembrado con [canchasSimuladas] ).
library;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../detalle/detalle_screen.dart';
import '../inicio/cancha.dart';
import 'favoritos_locales.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key, this.onExplorar});

  /// Cambia al tab Inicio ( estado vacío — RF-02 ).
  final VoidCallback? onExplorar;

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  void _quitar(Cancha cancha) {
    setState(() => quitarFavorito(cancha));
  }

  /// RF-03: abre el Detalle de la cancha con la fecha por defecto del
  /// selector del Inicio ( `Mar, 15 oct` — RD §8 ).
  void _reservar(BuildContext context, Cancha cancha) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetalleScreen(cancha: cancha, fecha: 'Mar, 15 oct'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritos = List<Cancha>.of(favoritosLocales);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favoritos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${favoritos.length} cancha${favoritos.length == 1 ? '' : 's'}',
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.text2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: favoritos.isEmpty
                    ? _EstadoVacio(onExplorar: widget.onExplorar)
                    : ListView.separated(
                        itemCount: favoritos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _CardFavorito(
                          cancha: favoritos[i],
                          onQuitar: () => _quitar(favoritos[i]),
                          onReservar: () => _reservar(context, favoritos[i]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de favorito ( frame 12 ): foto 92×92 + info + precio y `Reservar`.
class _CardFavorito extends StatelessWidget {
  const _CardFavorito({
    required this.cancha,
    required this.onQuitar,
    required this.onReservar,
  });

  final Cancha cancha;
  final VoidCallback onQuitar;
  final VoidCallback onReservar;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('card-${cancha.nombre}'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  cancha.foto,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cancha.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        GestureDetector(
                          key: ValueKey('quitar-${cancha.nombre}'),
                          onTap: onQuitar,
                          child: const Icon(
                            LucideIcons.heart,
                            size: 18,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.mapPin,
                          size: 13,
                          color: AppColors.text2,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cancha.distancia,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.text2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.star,
                          size: 13,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            cancha.rating,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.text2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Flexible + FittedBox: con la fuente ancha de los tests el
              // grupo se achica; en dispositivo (Roboto) entra completo.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Text(
                        cancha.precio,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ hora',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.text2),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                key: ValueKey('reservar-${cancha.nombre}'),
                onTap: onReservar,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 11, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Reservar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Estado vacío ( extensión — el mockup no lo define; estilo frame 09 ).
class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({required this.onExplorar});

  final VoidCallback? onExplorar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.all(Radius.circular(44)),
          ),
          child: const Center(
            child: Icon(LucideIcons.heart, size: 40, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Todavía no tenés favoritos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 14),
        const SizedBox(
          width: 270,
          child: Text(
            'Cuando marques una cancha como favorita va a aparecer acá.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.text2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          key: const ValueKey('explorar-favoritos'),
          onTap: () => onExplorar?.call(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Explorar canchas',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
