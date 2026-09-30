import 'package:flutter/material.dart';

import '../colores.dart';

/// Fila "Título de sección + acción" (ej. "Turnos disponibles" / "Ver todo").
class SeccionTitulo extends StatelessWidget {
  const SeccionTitulo({super.key, required this.titulo, this.accion});

  final String titulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColores.texto,
              ),
            ),
          ),
          if (accion != null) accion!,
        ],
      ),
    );
  }
}
