import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../colores.dart';
import '../fechas.dart';
import '../../features/auth/auth_providers.dart';

const _diasCortos = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

/// Selector de fecha estilo mockup: título + mes (abre calendario)
/// y chips horizontales de días alrededor de la fecha elegida.
class SelectorFecha extends ConsumerWidget {
  const SelectorFecha({
    super.key,
    this.retrocesoDias = 0,
    this.titulo = 'Elegí la fecha',
  });

  /// Días hacia el pasado que permite el calendario (el admin ve agenda histórica).
  final int retrocesoDias;
  final String titulo;

  Future<void> _elegirFecha(BuildContext context, WidgetRef ref) async {
    final actual = fromIso(ref.read(fechaSeleccionadaProvider));
    final limite = DateTime.now().subtract(Duration(days: retrocesoDias));
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(limite.year, limite.month, limite.day),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (seleccionada != null) {
      ref.read(fechaSeleccionadaProvider.notifier).state = toIso(seleccionada);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fecha = ref.watch(fechaSeleccionadaProvider);
    final d = fromIso(fecha);
    final hoy = DateTime.now();
    final primerDia = DateTime(hoy.year, hoy.month, hoy.day)
        .subtract(Duration(days: retrocesoDias));

    final chips = <Widget>[
      for (var i = -3; i <= 3; i++)
        _DiaChip(
          fecha: d.add(Duration(days: i)),
          seleccionado: i == 0,
          habilitado: !d.add(Duration(days: i)).isBefore(primerDia),
          onTap: () =>
              ref.read(fechaSeleccionadaProvider.notifier).state =
                  toIso(d.add(Duration(days: i))),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColores.texto,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _elegirFecha(context, ref),
                icon: Text(
                  _mes(d.month),
                  style: const TextStyle(
                    color: AppColores.primario,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                label: const Icon(Icons.arrow_drop_down,
                    color: AppColores.primario, size: 22),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppColores.texto),
                tooltip: 'Día anterior',
                onPressed: () =>
                    ref.read(fechaSeleccionadaProvider.notifier).state =
                        sumarDias(fecha, -1),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppColores.texto),
                tooltip: 'Día siguiente',
                onPressed: () =>
                    ref.read(fechaSeleccionadaProvider.notifier).state =
                        sumarDias(fecha, 1),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: chips),
          ),
        ],
      ),
    );
  }
}

class _DiaChip extends StatelessWidget {
  const _DiaChip({
    required this.fecha,
    required this.seleccionado,
    required this.habilitado,
    required this.onTap,
  });

  final DateTime fecha;
  final bool seleccionado;
  final bool habilitado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = seleccionado
        ? AppColores.primario
        : habilitado
            ? AppColores.superficie
            : AppColores.neutroClaro;
    final fgTexto = seleccionado
        ? Colors.white
        : habilitado
            ? AppColores.texto
            : AppColores.textoSuave;
    final fgDia = seleccionado ? const Color(0xCCFFFFFF) : AppColores.textoSuave;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: habilitado ? onTap : null,
        child: Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: seleccionado
                  ? AppColores.primario
                  : habilitado
                      ? AppColores.borde
                      : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Text(
                _diasCortos[fecha.weekday - 1],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fgDia,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${fecha.day}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: fgTexto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _mes(int mes) {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  return meses[mes - 1];
}
