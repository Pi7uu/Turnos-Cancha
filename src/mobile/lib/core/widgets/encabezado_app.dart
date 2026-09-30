import 'package:flutter/material.dart';

import '../colores.dart';

/// Encabezado de pantalla sin AppBar: ícono de pelota + título + acciones.
class EncabezadoApp extends StatelessWidget {
  const EncabezadoApp({
    super.key,
    required this.titulo,
    this.acciones = const [],
  });

  final String titulo;
  final List<Widget> acciones;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColores.primario,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_soccer, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColores.texto,
              ),
            ),
          ),
          ...acciones,
        ],
      ),
    );
  }
}

/// Botón de cerr sesión reutilizable para el encabezado.
class BotonSalir extends StatelessWidget {
  const BotonSalir({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: AppColores.textoSuave),
      tooltip: 'Cerrar sesión',
      onPressed: onPressed,
    );
  }
}
