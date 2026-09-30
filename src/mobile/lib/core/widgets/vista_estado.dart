import 'package:flutter/material.dart';

import '../colores.dart';

/// Estado vacío centrado (lista sin datos).
class VistaVacia extends StatelessWidget {
  const VistaVacia({super.key, required this.texto, this.icono});

  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColores.primarioClaro,
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 40, color: AppColores.primario),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColores.textoSuave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mensaje de error centrado.
class VistaError extends StatelessWidget {
  const VistaError({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColores.peligro),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColores.textoSuave),
            ),
          ],
        ),
      ),
    );
  }
}
