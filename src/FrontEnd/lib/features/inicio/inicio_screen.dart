import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../detalle/detalle_screen.dart';
import 'cancha.dart';

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

  /// Día seleccionado ( índice en `_Fecha._dias` ): por defecto MAR 15,
  /// como el mockup ( RD inicio-fecha RF-02 ).
  int _diaActivo = 1;

  /// Label de la fecha elegida ( RD detalle-horarios §8 ), ej: `Mié, 16 oct`.
  String _fechaLabel() {
    const dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];
    const numeros = [14, 15, 16, 17, 18];
    return '${dias[_diaActivo]}, ${numeros[_diaActivo]} oct';
  }

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
            // Scroll: el contenido ( con la lista de canchas ) supera la
            // altura de pantallas chicas ( RD inicio-canchas, CA 6 ).
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Header(),
                  const SizedBox(height: 16),
                  _Buscador(controller: _busquedaController),
                  const SizedBox(height: 16),
                  _Fecha(
                    activo: _diaActivo,
                    onSelect: (i) => setState(() => _diaActivo = i),
                  ),
                  const SizedBox(height: 16),
                  _Canchas(fecha: _fechaLabel()),
                  const SizedBox(height: 16),
                  const _Categorias(),
                ],
              ),
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

/// Bloque "Elegí la fecha" del mockup ( RD inicio-fecha §4 ): título + mes
/// a la derecha y la tira de 5 días con uno activo. Presentacional: la
/// selección la resuelve `onSelect` ( el shell la conserva porque la
/// pantalla vive precargada ).
class _Fecha extends StatelessWidget {
  const _Fecha({required this.activo, required this.onSelect});

  /// Índice del día activo en [_dias].
  final int activo;

  /// Se invoca al tocar cualquier chip, activo o no.
  final ValueChanged<int> onSelect;

  /// Días fijos del mockup ( sin lógica de calendario — RD §8 ).
  static const List<(String, int)> _dias = [
    ('LUN', 14),
    ('MAR', 15),
    ('MIÉ', 16),
    ('JUE', 17),
    ('VIE', 18),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Flexible + ellipsis (patrón de la marca y el título): en la
            // fuente de test la fila no cabe en 375px; en el dispositivo
            // real entra holgada.
            const Flexible(
              child: Text(
                'Elegí la fecha',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            // Selector de mes: visual, sin funcionalidad (RF-03).
            GestureDetector(
              onTap: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Octubre',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    LucideIcons.chevronDown,
                    size: 15,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Row(
            children: [
              for (final (i, (dia, numero)) in _dias.indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(i),
                    child: _ChipDia(
                      dia: dia,
                      numero: numero,
                      activo: i == activo,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Chip de un día: día arriba, número abajo ( mockup: vertical, hueco 2,
/// padding 9/0, radio 12 ).
class _ChipDia extends StatelessWidget {
  const _ChipDia({
    required this.dia,
    required this.numero,
    required this.activo,
  });

  final String dia;
  final int numero;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('dia-$numero'),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: activo ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dia,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: activo ? AppColors.primarySoft : AppColors.text2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$numero',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: activo ? Colors.white : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque "Canchas disponibles" del mockup ( RD inicio-canchas §4 ): fila
/// de título + lista de las 3 cards simuladas. Controles inertes ( RF-02 ):
/// la navegación al Detalle llega con su RD.
class _Canchas extends StatelessWidget {
  const _Canchas({required this.fecha});

  /// Label de la fecha elegida ( pasa al Detalle — RD detalle-horarios §8 ).
  final String fecha;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Flexible(
              child: Text(
                'Canchas disponibles',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            // Link sin funcionalidad ( el prototipo no define la pantalla ).
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: const Text(
                'Ver todo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final (i, cancha) in canchasSimuladas.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          _CardCancha(cancha: cancha, fecha: fecha),
        ],
      ],
    );
  }
}

/// Card de cancha ( mockup: card vectorial de Favoritos + tag del PNG ).
class _CardCancha extends StatelessWidget {
  const _CardCancha({required this.cancha, required this.fecha});

  final Cancha cancha;
  final String fecha;

  @override
  Widget build(BuildContext context) {
    // Navegación ( RD detalle-hero RF-02 ): la card abre el Detalle con esta
    // cancha ( reemplaza la inercia del RD inicio-canchas RF-02 ).
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DetalleScreen(cancha: cancha, fecha: fecha),
        ),
      ),
      child: Container(
        key: ValueKey('cancha-${cancha.nombre}'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    cancha.foto,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              cancha.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              cancha.tag,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin,
                              size: 13, color: AppColors.text2),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              cancha.distancia,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(LucideIcons.star,
                              size: 13, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              cancha.rating,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Flexible: en pantallas angostas la fila de precio absorbe
                // el encogimiento ( '/ hora' elipsa ); en real nunca trunca.
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cancha.precio,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          '/ hora',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.text2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón con la misma navegación que la card ( RD detalle-hero
                // RF-02 ).
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetalleScreen(cancha: cancha, fecha: fecha),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 11, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Reservar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloque "Categorías" del mockup ( RD inicio-categorias §4 ): título + 2
/// chips con ícono y label. Inerte ( RF-02 ): el filtrado por categoría
/// llega con su RD.
class _Categorias extends StatelessWidget {
  const _Categorias();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
              child: _ChipCategoria(
                slug: 'futbol5',
                icono: LucideIcons.users,
                label: 'Fútbol 5',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _ChipCategoria(
                slug: 'futbol7',
                icono: LucideIcons.layoutGrid,
                label: 'Fútbol 7',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Chip de categoría: caja de ícono 44×44 verde claro + label ( mockup:
/// vertical, hueco 8, padding 18/12, radio 14, borde ).
class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria({
    required this.slug,
    required this.icono,
    required this.label,
  });

  final String slug;
  final IconData icono;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Inerte ( RF-02 ): solo descarta el teclado, como el resto del fondo.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        key: ValueKey('categoria-$slug'),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.all(Radius.circular(22)),
              ),
              child: Center(
                child: Icon(icono, size: 20, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
