import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/colores.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _cargando = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await ref.read(authProvider.notifier).login(_email.text.trim(), _password.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColores.primario,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3316A34A),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.sports_soccer,
                          size: 44, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'TurnosCancha',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColores.texto,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Reservá tu cancha en segundos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: AppColores.textoSuave),
                  ),
                  const SizedBox(height: 32),
                  const Text('Email',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColores.textoSuave)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      hintText: 'nombre@ejemplo.com',
                    ),
                    validator: (v) =>
                        v != null && v.contains('@') ? null : 'Ingresá un email válido',
                  ),
                  const SizedBox(height: 16),
                  const Text('Contraseña',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColores.textoSuave)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: '••••••••'),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Ingresá tu contraseña',
                    onFieldSubmitted: (_) => _ingresar(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _cargando ? null : _ingresar,
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/registro'),
                    child: const Text('¿No tenés cuenta? Registrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
