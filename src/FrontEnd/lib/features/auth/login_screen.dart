import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import 'credenciales.dart';
import 'usuario_validado_screen.dart';

/// Pantalla de login (wireframes 04 y 04b).
///
/// RF-01: formulario con marca, título, campos de email y contraseña,
/// link de recuperación, botón Ingresar y footer de registro.
/// RF-02: el ojo alterna la visibilidad de la contraseña.
///
/// La validación de credenciales (RF-03/04/05) se conecta en la Tarea 5;
/// `onIngresar` recibe los valores crudos de los campos.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onIngresar});

  /// Se invoca al tocar Ingresar o al enviar desde el teclado (RF-02).
  final void Function(String email, String password) onIngresar;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;

  /// Estado de error 04b (RF-04): bordes rojos + mensaje inline.
  bool _error = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  /// Valida y navega o muestra el estado 04b (RF-03, RF-04).
  void _submit() {
    final email = _emailController.text;
    final password = _passwordController.text;
    // El callback recibe los valores crudos de cada intento (interfaz Tarea 3);
    // main.dart decide si reacciona (hoy no hace nada — sin backend, CA 7).
    widget.onIngresar(email, password);
    if (credencialesValidas(email, password)) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const UsuarioValidadoScreen(),
        ),
      );
    } else {
      setState(() => _error = true);
    }
  }

  /// Escribir en cualquier campo limpia el estado de error (RF-03).
  void _onChange(String _) {
    if (_error) {
      setState(() => _error = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              // En pantallas chicas el contenido se scrollea en vez de
              // desbordar (spec §5: "adaptarse sin romperse"); el minHeight
              // mantiene el footer anclado abajo en pantallas altas.
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _topGroup(),
                    _formGroup(),
                    _footerGroup(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Marca + título + subtítulo (arriba).
  Widget _topGroup() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 32),
        _Brand(),
        SizedBox(height: 40),
        Text(
          'Iniciá sesión',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Reservá tu cancha en segundos',
          style: TextStyle(fontSize: 15, color: AppColors.text2),
        ),
      ],
    );
  }

  /// Campos + link + botón (medio).
  Widget _formGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text(
          'Email',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: _onChange,
          style: const TextStyle(fontSize: 15, color: AppColors.text),
          decoration: _inputDecoration(
            hint: 'tu@email.com',
            icon: LucideIcons.mail,
            error: _error,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Contraseña',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          onChanged: _onChange,
          onSubmitted: (_) => _submit(),
          style: const TextStyle(fontSize: 15, color: AppColors.text),
          decoration: _inputDecoration(
            hint: 'Tu contraseña',
            icon: LucideIcons.lock,
            error: _error,
          ).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 20,
                color: AppColors.text2,
              ),
              onPressed: _togglePasswordVisibility,
            ),
          ),
        ),
        // Mensaje inline 04b (RF-04): altura reservada para que el layout
        // no salte entre estados.
        SizedBox(
          height: 20,
          child: _error
              ? const Text(
                  'El mail o la contraseña son incorrectos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        // Link sin funcionalidad (spec §3 fuera de alcance)
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Ingresar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// Footer de registro (abajo).
  Widget _footerGroup() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Footer(),
        SizedBox(height: 24),
      ],
    );
  }
}

/// Decoración de los campos de login.
///
/// Con `error: true` los bordes pasan a `danger` 1.5px (RF-04).
InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  required bool error,
}) {
  final radio = BorderRadius.circular(12);
  final bordeNormal = const BorderSide(color: AppColors.border, width: 1);
  final bordeError = const BorderSide(color: AppColors.danger, width: 1.5);
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 15, color: AppColors.text2),
    prefixIcon: Icon(icon, size: 20, color: AppColors.text2),
    prefixIconColor: AppColors.text2,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: radio,
      borderSide: error ? bordeError : bordeNormal,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radio,
      borderSide: error ? bordeError : bordeNormal,
    ),
    border: OutlineInputBorder(
      borderRadius: radio,
      borderSide: error ? bordeError : bordeNormal,
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child:
              const Icon(Icons.sports_soccer, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        // Flexible + ellipsis: en la fuente de test (1 char = fontSize)
        // la palabra no cabe en 320px y el Row desbordaría; en el dispositivo
        // real (Roboto) entra holgada.
        Flexible(
          child: Text(
            'TurnosCancha',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    // Wrap en vez de Row: si no entran en una línea (fuente de test o
    // pantallas angostas) pasan a la siguiente en vez de desbordar.
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          '¿No tenés cuenta?',
          style: TextStyle(fontSize: 14, color: AppColors.text2),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Crear cuenta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
