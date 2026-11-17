import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// Pantalla Inicio ( pantallas 01 del prototipo — se construye por partes ):
/// header ( RD `inicio-header.md` ) + buscador ( RD `inicio-buscador.md` )
/// sobre la estructura de contenido del mockup ( padding 8/16/16/16, hueco
/// 16 entre bloques ).
///
/// Los bloques siguientes ( fecha, tarjetas, categorías ) se apilan en esta
/// columna con hueco 16 en sus RDs.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  /// Valor del buscador: estado local de la pantalla ( el filtrado llega
  /// con la lista de canchas — RD inicio-buscador RF-02 ).
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // Tap fuera descarta el teclado sin alterar el valor del campo.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Header(),
                const SizedBox(height: 16),
                _Buscador(controller: _busquedaController),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila superior del Inicio: marca a la izquierda, acciones a la derecha
/// ( mockup: `spaceBetween`, centrada ).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Flexible: la fila puede quedarse sin espacio en pantallas
        // angostas; la marca absorbe el encogimiento (el Text elipsa).
        const Flexible(child: _Marca()),
        const _Acciones(),
      ],
    );
  }
}

/// Logo + nombre de la marca.
class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.sports_soccer, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        // Flexible + ellipsis (patrón de la marca del login): en la fuente
        // de test la palabra no cabe en 320px y la fila desbordaría; en el
        // dispositivo real entra holgada.
        Flexible(
          child: Text(
            'TurnosCancha',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Campana con badge + perfil. Visibles pero sin funcionalidad (RF-02):
/// el prototipo no define pantallas destino.
class _Acciones extends StatelessWidget {
  const _Acciones();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: const _Campana(),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {},
          child: const Icon(LucideIcons.user, size: 23, color: AppColors.text),
        ),
      ],
    );
  }
}

/// Campana 26×26 con el badge sobresaliendo arriba-derecha ( mockup:
/// ícono en (1, 3), badge en (17, 0) ).
class _Campana extends StatelessWidget {
  const _Campana();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        children: [
          Positioned(
            left: 1,
            top: 3,
            child: const Icon(
              LucideIcons.bell,
              size: 22,
              color: AppColors.text,
            ),
          ),
          Positioned(
            left: 17,
            top: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de búsqueda del mockup ( RD inicio-buscador §4 ): lupa a la
/// izquierda, placeholder `Buscá canchas cerca tuyo...`. Editable pero sin
/// filtrar ( RF-02 ); la acción "search" del teclado no hace nada.
class _Buscador extends StatelessWidget {
  const _Buscador({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        hintText: 'Buscá canchas cerca tuyo...',
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.text2,
        ),
        filled: true,
        fillColor: AppColors.surface,
        // Geometría del mockup ( ícono a 14px del borde, hueco 10 al texto ):
        // el decorador de Flutter pega el prefixIcon al borde y coloca el
        // texto a `anchoDelPrefix + 4`, así que el hueco se logra con un
        // prefix de 38 ( 14 + 18 + 6 ). Medido por los tests de posiciones.
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 6),
          child: Icon(LucideIcons.search, size: 18, color: AppColors.text2),
        ),
        prefixIconConstraints:
            const BoxConstraints(maxWidth: 38, minHeight: 18),
        enabledBorder: _bordeCampo(),
        focusedBorder: _bordeCampo(),
        border: _bordeCampo(),
      ),
    );
  }
}

OutlineInputBorder _bordeCampo() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.border, width: 1),
  );
}
