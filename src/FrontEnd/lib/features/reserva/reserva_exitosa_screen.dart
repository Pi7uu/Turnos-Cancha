import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../inicio/cancha.dart';
import '../navegacion/main_shell.dart';
import '../navegacion/tab_bar.dart';

/// Pantalla "¡Reserva exitosa!" ( mockup `Contenido`, RD
/// `docs/requerimientos/reserva-exitosa.md` ): confirmación de la reserva con
/// N° de orden, estado de pago y precio. Se abre desde `Confirmar reserva`
/// del Detalle.
///
/// Datos simulados: `PAGADO` fijo y sin persistencia ( la pantalla de error
/// definirá cuándo no hay éxito ).
class ReservaExitosaScreen extends StatelessWidget {
  const ReservaExitosaScreen({
    super.key,
    required this.cancha,
    required this.fecha,
    required this.hora,
  });

  final Cancha cancha;

  /// Label de la fecha reservada ( ej: `Mié, 16 oct` ).
  final String fecha;

  /// Hora reservada ( ej: `19:00` ).
  final String hora;

  /// N° de orden: contador determinista que arranca en el valor del mockup
  /// ( `#GB-882910` ) — cada pantalla nueva genera el siguiente.
  static int _ultimoOrden = 882910;

  @override
  Widget build(BuildContext context) {
    final orden = '#GB-${_ultimoOrden++}';
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Ilustracion(),
                const SizedBox(height: 16),
                const Text(
                  '¡Reserva exitosa!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu cancha ${cancha.nombre} quedó reservada para el '
                  '${_diaDeFecha()} de octubre a las $hora.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.text2,
                  ),
                ),
                const SizedBox(height: 16),
                _CardResumen(cancha: cancha, orden: orden),
                const SizedBox(height: 16),
                const Text(
                  'Te enviamos la confirmación a tu email registrado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.text2),
                ),
                const SizedBox(height: 16),
                // RF-02: abre el shell con el tab Mis reservas activo.
                FilledButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const MainShell(tabInicial: TabApp.misReservas),
                    ),
                    (route) => false,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver mis reservas',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                // RF-02: regresa al shell conservando su estado.
                OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.text,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: AppColors.border, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Día del label de fecha ( `Mié, 16 oct` → `16` ).
  String _diaDeFecha() => RegExp(r'(\d+)').firstMatch(fecha)?.group(1) ?? '';
}

/// Ilustración del mockup ( simplificada, vectorial ): círculo verde con
/// check blanco y 2 puntitos decorativos.
class _Ilustracion extends StatelessWidget {
  const _Ilustracion();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.check, size: 56, color: Colors.white),
          ),
          const Positioned(
            top: 8,
            right: 60,
            child: _Punto(color: Color(0xFFF59E0B), tamano: 12),
          ),
          const Positioned(
            top: 70,
            left: 55,
            child: _Punto(color: Color(0xFF3B82F6), tamano: 9),
          ),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.color, required this.tamano});

  final Color color;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Card con el resumen de la reserva ( mockup: 3 filas `spaceBetween` ).
class _CardResumen extends StatelessWidget {
  const _CardResumen({required this.cancha, required this.orden});

  final Cancha cancha;
  final String orden;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          _FilaResumen(label: 'N° DE ORDEN', valor: _ValorTexto(orden)),
          const SizedBox(height: 16),
          _FilaResumen(
            label: 'ESTADO DE PAGO',
            valor: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PAGADO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FilaResumen(
            label: 'PRECIO TOTAL',
            valor: Text(
              '${cancha.precio}.00',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaResumen extends StatelessWidget {
  const _FilaResumen({required this.label, required this.valor});

  final String label;
  final Widget valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.text2,
            ),
          ),
        ),
        valor,
      ],
    );
  }
}

class _ValorTexto extends StatelessWidget {
  const _ValorTexto(this.valor);

  final String valor;

  @override
  Widget build(BuildContext context) {
    return Text(
      valor,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    );
  }
}
