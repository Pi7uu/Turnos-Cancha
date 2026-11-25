import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import 'reserva.dart';
import 'reservas_locales.dart';

/// Pantalla Mis reservas ( pantalla 03, parte 1 — RD
/// `docs/HistRequerimientos/mis-reservas-lista.md` ): header + pestañas
/// Próximas/Completadas/Canceladas + lista de reservas.
///
/// Es el tab del shell ( clave `placeholder-mis-reservas` ); `onVolver`
/// cambia al tab Inicio ( la pantalla vive precargada en el shell ).
/// Las acciones de las cards llegan en la parte 2 ( hoy inertes ).
class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key, this.onVolver});

  /// Cambia al tab Inicio ( inyectado por `MainShell` ).
  final VoidCallback? onVolver;

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  /// Pestaña activa: 0 = Próximas, 1 = Completadas, 2 = Canceladas.
  int _pestana = 0;

  static const List<(String, String)> _pestanas = [
    ('Próximas', 'proximas'),
    ('Completadas', 'completadas'),
    ('Canceladas', 'canceladas'),
  ];

  List<Reserva> _reservasDeLaPestana() {
    return reservasLocales
        .where((r) => switch (r.estado) {
              EstadoReserva.confirmada || EstadoReserva.pendiente =>
                _pestana == 0,
              EstadoReserva.completada => _pestana == 1,
              EstadoReserva.cancelada => _pestana == 2,
            })
        .toList();
  }

  void _cancelar(Reserva reserva) {
    setState(() => cancelarReserva(reserva));
  }

  void _confirmar(Reserva reserva) {
    setState(() => confirmarReserva(reserva));
  }

  /// Diálogo simulado con el QR ( extensión — el mockup no define pantalla
  /// de QR; RD §4 ).
  Future<void> _mostrarQr(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tu QR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.qrCode,
                    size: 96,
                    color: AppColors.text2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mostrá este código en la entrada.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.text2),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                key: const ValueKey('qr-cerrar'),
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onVolver: widget.onVolver),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (final (i, (label, slug)) in _pestanas.indexed)
                    Expanded(
                      child: _Pestana(
                        label: label,
                        slug: slug,
                        activa: i == _pestana,
                        onTap: () => setState(() => _pestana = i),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _reservasDeLaPestana().length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final reserva = _reservasDeLaPestana()[i];
                    return _CardReserva(
                      reserva: reserva,
                      indice: i,
                      onCancelar: () => _cancelar(reserva),
                      onConfirmar: () => _confirmar(reserva),
                      onVerQr: () => _mostrarQr(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header del mockup: Volver + título.
class _Header extends StatelessWidget {
  const _Header({required this.onVolver});

  final VoidCallback? onVolver;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          label: 'Volver',
          child: GestureDetector(
            onTap: () => onVolver?.call(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
              ),
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
        const SizedBox(width: 14),
        const Flexible(
          child: Text(
            'Mis reservas',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }
}

/// Pestaña con su subrayado ( mockup §4 ).
class _Pestana extends StatelessWidget {
  const _Pestana({
    required this.label,
    required this.slug,
    required this.activa,
    required this.onTap,
  });

  final String label;
  final String slug;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: ValueKey('pestana-$slug'),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: activa ? FontWeight.w600 : FontWeight.w500,
                color: activa ? AppColors.primary : AppColors.text2,
              ),
            ),
            const SizedBox(height: 9),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: activa ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card de reserva ( mockup §4 ): superior + detalle + acciones según estado.
class _CardReserva extends StatelessWidget {
  const _CardReserva({
    required this.reserva,
    required this.indice,
    required this.onCancelar,
    required this.onConfirmar,
    required this.onVerQr,
  });

  final Reserva reserva;
  final int indice;
  final VoidCallback onCancelar;
  final VoidCallback onConfirmar;
  final VoidCallback onVerQr;

  @override
  Widget build(BuildContext context) {
    // Acciones según el estado ( RD RF-01/RF-04 ): Próximas con Cancelar +
    // ( Ver QR si confirmada con QR | Confirmar si pendiente ); una
    // confirmada sin QR muestra solo Cancelar ( variante "Sin QR" ).
    final acciones = <Widget>[
      Expanded(
        child: GestureDetector(
          onTap: onCancelar,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Cancelar reserva',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
        ),
      ),
    ];
    if (reserva.estado == EstadoReserva.pendiente) {
      acciones
        ..add(const SizedBox(width: 10))
        ..add(_BotonAccion(
          texto: 'Confirmar',
          onTap: onConfirmar,
        ));
    } else if (reserva.estado == EstadoReserva.confirmada &&
        reserva.tieneQr) {
      acciones
        ..add(const SizedBox(width: 10))
        ..add(_BotonAccion(
          texto: 'Ver QR',
          onTap: onVerQr,
        ));
    }
    return Container(
      key: ValueKey('reserva-$indice'),
      padding: const EdgeInsets.all(16),
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
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  reserva.foto,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reserva.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reserva.fecha,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.text2,
                      ),
                    ),
                  ],
                ),
              ),
              _BadgeEstado(estado: reserva.estado),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CampoDetalle(label: 'HORARIO', valor: reserva.horario),
              _CampoDetalle(
                label: 'CANCHA',
                valor: reserva.sector,
                alineadoDerecha: true,
              ),
            ],
          ),
          if (reserva.estado == EstadoReserva.confirmada ||
              reserva.estado == EstadoReserva.pendiente) ...[
            const SizedBox(height: 14),
            Row(children: acciones),
          ],
        ],
      ),
    );
  }
}

/// Fila HORARIO / CANCHA de la card.
class _CampoDetalle extends StatelessWidget {
  const _CampoDetalle({
    required this.label,
    required this.valor,
    this.alineadoDerecha = false,
  });

  final String label;
  final String valor;
  final bool alineadoDerecha;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: alineadoDerecha
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de acción de la card ( Confirmar / Ver QR — `$primary` ).
class _BotonAccion extends StatelessWidget {
  const _BotonAccion({required this.texto, required this.onTap});

  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge de estado de la reserva ( colores del mockup + extensiones — RD §4 ).
class _BadgeEstado extends StatelessWidget {
  const _BadgeEstado({required this.estado});

  final EstadoReserva estado;

  @override
  Widget build(BuildContext context) {
    final (texto, fondo, colorTexto) = switch (estado) {
      EstadoReserva.confirmada => ('CONFIRMADA', AppColors.primary, Colors.white),
      EstadoReserva.pendiente => ('PENDIENTE', const Color(0xFFF59E0B), Colors.white),
      EstadoReserva.completada => ('COMPLETADA', AppColors.primarySoft, AppColors.primary),
      EstadoReserva.cancelada => ('CANCELADA', const Color(0xFFFEE2E2), AppColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: colorTexto,
        ),
      ),
    );
  }
}