import 'package:flutter/material.dart';

/// Pantalla de éxito post-login (RF-05): fondo blanco con `usuario validado`
/// centrado. Es una pantalla temporal de validación, sin otros elementos ni
/// navegación.
class UsuarioValidadoScreen extends StatelessWidget {
  const UsuarioValidadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'usuario validado',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}
