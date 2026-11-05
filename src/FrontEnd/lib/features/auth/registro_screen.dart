import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// Pantalla de registro (mockup 05 · Crear cuenta).
///
/// RD §4: botón Volver, titular sin marca, cuatro campos (nombre, email,
/// contraseña y repetir contraseña), checkbox de términos, botón principal
/// y footer de ingreso.
///
/// Esta tarea solo cubre el layout y las interacciones de campos: el ojo de
/// cada contraseña alterna su visibilidad de forma independiente y el
/// checkbox de términos alterna al tocar la fila. La validación y el alta
/// se cablean en la Tarea 5 (`_submit` queda vacío por ahora).
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repetirController = TextEditingController();

  /// Ojos independientes (RD §4): cada contraseña arranca oculta y se
  /// muestra/oculta sin afectar a la otra.
  bool _passwordVisible = false;
  bool _repetirVisible = false;

  /// Checkbox de términos: desmarcado por defecto (RD §4).
  bool _aceptaTerminos = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repetirController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _passwordVisible = !_passwordVisible);
  }

  void _toggleRepetirVisibility() {
    setState(() => _repetirVisible = !_repetirVisible);
  }

  void _alternarTerminos() {
    setState(() => _aceptaTerminos = !_aceptaTerminos);
  }

  /// Validación y alta pendientes (Tarea 5); el botón y el `done` del último
  /// campo ya llaman acá.
  void _submit() {}

  /// Volver / "Iniciá sesión": cierra la pantalla sin datos (el login
  /// conserva lo que tenía y no se registra ninguna cuenta).
  void _volver() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Misma receta anti-overflow del LoginScreen: si el contenido no entra
    // se scrollea, y el minHeight ancla el footer abajo en pantallas altas.
    final bloques = <Widget>[
      _botonVolver(),
      _titular(),
      _formulario(),
      _grupoTerminos(),
      _botonCrear(),
      _footer(),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        // Tap fuera de un campo descarta el teclado sin validar nada
        // (RF-02): los toques sobre campos/botones siguen ganando en la
        // arena de gestos, así que no roban foco ni acciones.
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            // RD §4: 28 arriba / 24 a los lados / 32 abajo.
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hueco mínimo de 22 entre bloques (RD §4); el
                      // space-between reparte el resto en pantallas altas.
                      for (var i = 0; i < bloques.length; i++) ...[
                        if (i > 0) const SizedBox(height: 22),
                        bloques[i],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Volver: círculo 40×40, fondo `surface`, radio 20, borde `border` 1px
  /// e ícono `chevron-left` 20px `text` (RD §4).
  Widget _botonVolver() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _volver,
            child: const Center(
              child: Icon(
                LucideIcons.chevronLeft,
                size: 20,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Titular sin marca (RD §4): 28 bold + subtítulo 15 `text2`.
  Widget _titular() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Crear cuenta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Creá tu cuenta y empezá a reservar',
          style: TextStyle(fontSize: 15, color: AppColors.text2),
        ),
      ],
    );
  }

  /// Los cuatro campos, con hueco 16 entre ellos (RD §4).
  Widget _formulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Campo(
          label: 'Nombre y apellido',
          child: TextField(
            controller: _nombreController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'Tu nombre completo',
              icon: LucideIcons.user,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Campo(
          label: 'Email',
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'tu@email.com',
              icon: LucideIcons.mail,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Campo(
          label: 'Contraseña',
          helper: 'Usá 8 caracteres como mínimo',
          child: TextField(
            controller: _passwordController,
            obscureText: !_passwordVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'Mínimo 8 caracteres',
              icon: LucideIcons.lock,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 20,
                  color: AppColors.text2,
                ),
                tooltip:
                    _passwordVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                onPressed: _togglePasswordVisibility,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Campo(
          label: 'Repetir contraseña',
          child: TextField(
            controller: _repetirController,
            obscureText: !_repetirVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'Repetí tu contraseña',
              icon: LucideIcons.lock,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _repetirVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 20,
                  color: AppColors.text2,
                ),
                tooltip:
                    _repetirVisible ? 'Ocultar contraseña' : 'Mostrar contraseña',
                onPressed: _toggleRepetirVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Términos (RD §4): fila centrada, hueco 10, checkbox 20×20 radio 6 y
  /// texto 12 `text2` con lineHeight 1.4. Tocar el check o el texto alterna.
  Widget _grupoTerminos() {
    return GestureDetector(
      onTap: _alternarTerminos,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _aceptaTerminos ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: _aceptaTerminos
                  ? null
                  : Border.all(color: AppColors.border),
            ),
            child: _aceptaTerminos
                ? const Icon(
                    LucideIcons.check,
                    size: 13,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Acepto los términos y condiciones y la política de privacidad',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.text2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Botón principal (RD §4): ancho completo, radio 12, padding vertical 15.
  Widget _botonCrear() {
    return FilledButton(
      onPressed: _submit,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: const Text(
        'Crear cuenta',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Footer (RD §4): "¿Ya tenés cuenta?" + "Iniciá sesión", centrado.
  Widget _footer() {
    return _Footer(onIniciarSesion: _volver);
  }
}

/// Campo del formulario: label 13 semibold `text` con hueco 7 al input y,
/// opcionalmente, el texto de ayuda 12 `text2` debajo (RD §4).
class _Campo extends StatelessWidget {
  const _Campo({
    required this.label,
    required this.child,
    this.helper,
  });

  final String label;
  final Widget child;

  /// Texto de ayuda fijo (campo Contraseña). Su altura queda reservada para
  /// que el layout no salte cuando la Tarea 5 sume los errores inline.
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 7),
        child,
        if (helper != null) ...[
          const SizedBox(height: 4),
          SizedBox(
            height: 18,
            child: Text(
              helper!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.text2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Decoración de los campos del registro.
///
/// RD §4: fondo `surface`, radio 12, borde `border` 1px, padding vertical 13 /
/// horizontal 16 e ícono lucide 18px `text2`.
/// Con `error: true` los bordes pasan a `danger` 1.5px (se usa desde la
/// Tarea 5); en esta tarea siempre es false.
InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  bool error = false,
}) {
  final radio = BorderRadius.circular(12);
  final bordeNormal = const BorderSide(color: AppColors.border, width: 1);
  final bordeError = const BorderSide(color: AppColors.danger, width: 1.5);
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 15, color: AppColors.text2),
    prefixIcon: Icon(icon, size: 18, color: AppColors.text2),
    prefixIconColor: AppColors.text2,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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

/// Footer del registro: "¿Ya tenés cuenta?" + "Iniciá sesión" (RD §4).
class _Footer extends StatelessWidget {
  const _Footer({required this.onIniciarSesion});

  final VoidCallback onIniciarSesion;

  @override
  Widget build(BuildContext context) {
    // Wrap en vez de Row: en pantallas angostas pasa a la línea siguiente
    // en vez de desbordar (mismo patrón que el footer del login).
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          '¿Ya tenés cuenta?',
          style: TextStyle(fontSize: 14, color: AppColors.text2),
        ),
        GestureDetector(
          onTap: onIniciarSesion,
          child: const Text(
            'Iniciá sesión',
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
