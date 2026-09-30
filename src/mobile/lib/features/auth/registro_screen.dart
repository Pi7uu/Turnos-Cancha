import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/colores.dart';
import 'auth_providers.dart';

class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({super.key});

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _registrarme() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await ref.read(authProvider.notifier).registro(
            email: _email.text.trim(),
            password: _password.text,
            nombre: _nombre.text.trim(),
          );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.mensajeDeError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Widget _campoLabel(String texto) => Text(texto,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColores.textoSuave));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Creá tu cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColores.texto,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Completá tus datos para empezar a reservar',
                  style: TextStyle(fontSize: 15, color: AppColores.textoSuave),
                ),
                const SizedBox(height: 24),
                _campoLabel('Nombre y apellido'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nombre,
                  decoration: const InputDecoration(hintText: 'Juan Pérez'),
                ),
                const SizedBox(height: 16),
                _campoLabel('Email'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'nombre@ejemplo.com'),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Ingresá un email válido',
                ),
                const SizedBox(height: 16),
                _campoLabel('Contraseña'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                    helperText: 'Mínimo 8 caracteres',
                  ),
                  validator: (v) =>
                      v != null && v.length >= 8 ? null : 'Mínimo 8 caracteres',
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _cargando ? null : _registrarme,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrarme'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('¿Ya tenés cuenta? Iniciá sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
