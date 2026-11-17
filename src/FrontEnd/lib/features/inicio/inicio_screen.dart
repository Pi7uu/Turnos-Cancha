import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// Pantalla Inicio ( parte 1 de la pantalla 01 del prototipo, RD
/// `docs/requerimientos/inicio-header.md` ): por ahora solo el header
/// ( marca + campana + perfil ) sobre la estructura de contenido del mockup.
///
/// Los bloques siguientes ( buscador, fecha, tarjetas, categorías ) se
/// apilan en esta columna con hueco 16 en sus RDs.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              _Header(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila superior del Inicio: marca a la izquierda, acciones a la derecha
/// ( mockup: `spaceBetween`, centrada ).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Flexible: la fila puede quedarse sin espacio en pantallas
        // angostas; la marca absorbe el encogimiento (el Text elipsa).
        const Flexible(child: _Marca()),
        const _Acciones(),
      ],
    );
  }
}

/// Logo + nombre de la marca.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.sports_soccer, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        // Flexible + ellipsis (patrón de la marca del login): en la fuente
        // de test la palabra no cabe en 320px y la fila desbordaría; en el
        // dispositivo real entra holgada.
        Flexible(
          child: Text(
            'TurnosCancha',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Campana con badge + perfil. Visibles pero sin funcionalidad (RF-02):
/// el prototipo no define pantallas destino.
class _Acciones extends StatelessWidget {
  const _Acciones();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: const _Campana(),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {},
          child: const Icon(LucideIcons.user, size: 23, color: AppColors.text),
        ),
      ],
    );
  }
}

/// Campana 26×26 con el badge sobresaliendo arriba-derecha ( mockup:
/// ícono en (1, 3), badge en (17, 0) ).
class _Campana extends StatelessWidget {
  const _Campana();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        children: [
          Positioned(
            left: 1,
            top: 3,
            child: const Icon(
              LucideIcons.bell,
              size: 22,
              color: AppColors.text,
            ),
          ),
          Positioned(
            left: 17,
            top: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
