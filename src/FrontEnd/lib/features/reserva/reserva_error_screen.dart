import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../inicio/cancha.dart';

/// Pantalla "No se pudo completar la reserva" ( mockup frame 10, RD
/// `docs/HistRequerimientos/reserva-error.md` ): el intento de reserva falló
/// porque otro usuario tomó el horario ( simulado vía
/// `cancha.horasEnConflicto` ).
///
/// `Elegir otro horario` vuelve al Detalle ( la selección sigue viva );
/// `Volver al inicio` regresa al shell conservando su estado.
class ReservaErrorScreen extends StatelessWidget {
  const ReservaErrorScreen({
    super.key,
    required this.cancha,
    required this.fecha,
    required this.hora,
  });

  final Cancha cancha;

  /// Label de la fecha intentada ( ej: `Mié, 16 oct` ).
  final String fecha;

  /// Hora intentada ( ej: `18:00` ).
  final String hora;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              // Contenido centrado verticalmente como el mockup ( patrón
              // del login: cuando sobra espacio, el bloque queda al medio ).
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _IconoError(),
                    const SizedBox(height: 18),
                    const Text(
                      'No se pudo completar la reserva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'La cancha ${cancha.nombre} del ${_diaDeFecha()} de '
                      'octubre a las $hora ya fue reservada por otro usuario.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.text2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CardError(cancha: cancha, hora: hora),
                    const SizedBox(height: 20),
                    const Text(
                      'Te avisamos por email en cuanto se libere un horario.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.text2),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      key: const ValueKey('error-elegir-otro'),
                      // RF-03: vuelve al Detalle ( la selección sigue viva ).
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Elegir otro horario',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      key: const ValueKey('error-volver'),
                      // RF-03: regresa al shell conservando su estado.
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.text,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side:
                            const BorderSide(color: AppColors.border, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Volver al inicio',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Día del label de fecha ( `Mié, 16 oct` → `16` ).
  String _diaDeFecha() => RegExp(r'(\d+)').firstMatch(fecha)?.group(1) ?? '';
}

/// Círculo rojo con la cruz ( mockup §4 ).
class _IconoError extends StatelessWidget {
  const _IconoError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: Color(0xFFFEE2E2),
          borderRadius: BorderRadius.all(Radius.circular(48)),
        ),
        child: const Center(
          child: Icon(LucideIcons.x, size: 46, color: AppColors.danger),
        ),
      ),
    );
  }
}

/// Card con el detalle del error ( mockup §4: 3 filas con separadores ).
class _CardError extends StatelessWidget {
  const _CardError({required this.cancha, required this.hora});

  final Cancha cancha;
  final String hora;

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
          const _FilaError(label: 'MOTIVO', valor: _ValorTexto('Horario ocupado')),
          const _Separador(),
          const _FilaError(
            label: 'ESTADO DE PAGO',
            valor: _BadgeSinCobro(),
          ),
          const _Separador(),
          _FilaError(
            label: 'ALTERNATIVAS',
            valor: Text(
              _alternativas(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Otras canchas simuladas con esa hora libre ( RD RF-02 ).
  String _alternativas() {
    final libres = canchasSimuladas
        .where((c) =>
            c != cancha &&
            !c.horasOcupadas.contains(hora) &&
            !c.horasEnConflicto.contains(hora))
        .length;
    return libres == 1 ? '1 cancha libre' : '$libres canchas libres';
  }
}

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: AppColors.border),
      ),
    );
  }
}

class _FilaError extends StatelessWidget {
  const _FilaError({required this.label, required this.valor});

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
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );
  }
}

class _BadgeSinCobro extends StatelessWidget {
  const _BadgeSinCobro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'SIN COBRO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
