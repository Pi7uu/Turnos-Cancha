import 'package:flutter/material.dart';

import '../estados.dart';

/// Badge pill de estado de reserva (CONFIRMADA / PENDIENTE / ...),
/// estilo de las etiquetas del mockup.
class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorEstado(estado),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        etiquetaEstado(estado),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
