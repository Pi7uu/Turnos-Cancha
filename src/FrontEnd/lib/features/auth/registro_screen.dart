import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import 'usuarios_locales.dart';
import 'validacion_registro.dart';

/// Pantalla de registro (mockup 05 · Crear cuenta).
///
/// RD §4: botón Volver, titular sin marca, cuatro campos (nombre, email,
/// contraseña y repetir contraseña), checkbox de términos, botón principal
/// y footer de ingreso.
///
/// RF-02/RF-03: el ojo de cada contraseña alterna su visibilidad de forma
/// independiente, "siguiente" avanza por los campos y "done" en Repetir
/// valida igual que el botón. RF-01/04/05: con el formulario válido registra
/// al usuario en la lista local y vuelve al login con `pop(true)`.
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

  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _repetirFocus = FocusNode();

  /// Ojos independientes (RD §4): cada contraseña arranca oculta y se
  /// muestra/oculta sin afectar a la otra.
  bool _passwordVisible = false;
  bool _repetirVisible = false;

  /// Checkbox de términos: desmarcado por defecto (RD §4).
  bool _aceptaTerminos = false;

  /// Errores inline por campo (RD registro RF-03); `null` antes del primer
  /// intento de crear la cuenta.
  ErroresRegistro? _errores;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repetirController.dispose();
    _nombreFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _repetirFocus.dispose();
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
    // RF-07: el error del checkbox se limpia solamente marcándolo.
    if (_aceptaTerminos) {
      _limpiarErrorDe(_CampoRegistro.terminos);
    }
  }

  /// Escribir en un campo limpia SOLO su propio error (RF-02/RF-03).
  void _limpiarErrorDe(_CampoRegistro campo) {
    final actual = _errores;
    if (actual == null) return;

    final yaLimpio = switch (campo) {
      _CampoRegistro.nombre => actual.nombre == null,
      _CampoRegistro.email => actual.email == null,
      _CampoRegistro.password => actual.password == null,
      _CampoRegistro.repetir => actual.repetir == null,
      _CampoRegistro.terminos => actual.terminos == null,
    };
    if (yaLimpio) return;

    setState(() {
      _errores = ErroresRegistro(
        nombre: campo == _CampoRegistro.nombre ? null : actual.nombre,
        email: campo == _CampoRegistro.email ? null : actual.email,
        password: campo == _CampoRegistro.password ? null : actual.password,
        repetir: campo == _CampoRegistro.repetir ? null : actual.repetir,
        terminos: campo == _CampoRegistro.terminos ? null : actual.terminos,
      );
    });
  }

  /// Valida y, si todo está bien, registra al usuario y vuelve al login con
  /// `true` para el aviso de éxito (RF-01/04/05). Si hay errores quedan
  /// visibles todos a la vez, sin mensajes globales (RF-03).
  void _submit() {
    final errores = validarRegistro(
      nombre: _nombreController.text,
      email: _emailController.text,
      password: _passwordController.text,
      repetir: _repetirController.text,
      terminos: _aceptaTerminos,
    );
    setState(() => _errores = errores);
    if (errores.hayError) return;

    // RF-04: el alta normaliza el email (trim + minúsculas) y el nombre
    // (trim); la contraseña se guarda tal cual.
    registrarUsuario(
      _nombreController.text,
      _emailController.text,
      _passwordController.text,
    );
    Navigator.pop(context, true);
  }

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
          error: _errores?.nombre,
          child: TextField(
            controller: _nombreController,
            focusNode: _nombreFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _limpiarErrorDe(_CampoRegistro.nombre),
            onSubmitted: (_) => _emailFocus.requestFocus(),
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'Tu nombre completo',
              icon: LucideIcons.user,
              error: _errores?.nombre != null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Campo(
          label: 'Email',
          error: _errores?.email,
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _limpiarErrorDe(_CampoRegistro.email),
            onSubmitted: (_) => _passwordFocus.requestFocus(),
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'tu@email.com',
              icon: LucideIcons.mail,
              error: _errores?.email != null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Campo(
          label: 'Contraseña',
          helper: 'Usá 8 caracteres como mínimo',
          error: _errores?.password,
          child: TextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            obscureText: !_passwordVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _limpiarErrorDe(_CampoRegistro.password),
            onSubmitted: (_) => _repetirFocus.requestFocus(),
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'Mínimo 8 caracteres',
              icon: LucideIcons.lock,
              error: _errores?.password != null,
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
          error: _errores?.repetir,
          child: TextField(
            controller: _repetirController,
            focusNode: _repetirFocus,
            obscureText: !_repetirVisible,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _limpiarErrorDe(_CampoRegistro.repetir),
            onSubmitted: (_) => _submit(),
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: _inputDecoration(
              hint: 'Repetí tu contraseña',
              icon: LucideIcons.lock,
              error: _errores?.repetir != null,
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
  /// Debajo se muestra el error inline del checkbox (RF-07).
  Widget _grupoTerminos() {
    final errorTerminos = _errores?.terminos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: _alternarTerminos,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      _aceptaTerminos ? AppColors.primary : AppColors.surface,
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
        ),
        if (errorTerminos != null) ...[
          const SizedBox(height: 4),
          Text(
            errorTerminos,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.danger,
              height: 1.4,
            ),
          ),
        ],
      ],
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
/// debajo, un slot adaptativo que muestra el error inline (13 semibold
/// `danger`) o, si no hay error, el texto de ayuda 12 `text2` (RD §4).
class _Campo extends StatelessWidget {
  const _Campo({
    required this.label,
    required this.child,
    this.helper,
    this.error,
  });

  final String label;
  final Widget child;

  /// Texto de ayuda fijo (campo Contraseña). Se oculta mientras el campo
  /// tenga error: el slot muestra ayuda O error, nunca los dos.
  final String? helper;

  /// Error inline del campo (RF-03), o `null` si es válido.
  final String? error;

  @override
  Widget build(BuildContext context) {
    final mensaje = error ?? helper;
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
        if (mensaje != null) ...[
          const SizedBox(height: 4),
          // Altura mínima 18: la ayuda (12×1.4 ≈ 17) y un error de una línea
          // (13×1.4 ≈ 18) ocupan lo mismo; un error de dos líneas crece en
          // vez de recortarse (sin overflow en 320×568).
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 18),
            child: error != null
                ? Text(
                    error!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                      height: 1.4,
                    ),
                  )
                : Text(
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
/// Con `error: true` los bordes pasan a `danger` 1.5px (RF-03).
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

/// Campos con error propio e independiente (RD registro RF-03/RF-07).
enum _CampoRegistro { nombre, email, password, repetir, terminos }

