import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/app_nav.dart';
import '../../core/colores.dart';
import '../../core/fechas.dart';
import '../../core/models.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/encabezado_app.dart';
import '../../core/widgets/seccion_titulo.dart';
import '../../core/widgets/selector_fecha.dart';
import '../../core/widgets/vista_estado.dart';
import '../auth/auth_providers.dart';
import 'reservas_providers.dart';

class DisponibilidadScreen extends ConsumerWidget {
  const DisponibilidadScreen({super.key});

  Future<void> _reservar(
      BuildContext context, WidgetRef ref, String fecha, Slot slot) async {
    final opciones = <Widget>[
      if (slot.f5A)
        ListTile(
          leading: const Icon(Icons.sports_soccer, color: AppColores.primario),
          title: const Text('Fútbol 5 - A'),
          subtitle: const Text('Ocupa solo la mitad A'),
          onTap: () => Navigator.of(context).pop('F5-A'),
        ),
      if (slot.f5B)
        ListTile(
          leading: const Icon(Icons.sports_soccer, color: AppColores.primario),
          title: const Text('Fútbol 5 - B'),
          subtitle: const Text('Ocupa solo la mitad B'),
          onTap: () => Navigator.of(context).pop('F5-B'),
        ),
      if (slot.f7)
        ListTile(
          leading: const Icon(Icons.sports, color: AppColores.primario),
          title: const Text('Fútbol 7'),
          subtitle: const Text('Ocupa las dos canchas completas'),
          onTap: () => Navigator.of(context).pop('F7'),
        ),
    ];

    final elegida = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Reservar ${slot.horaInicio} - ${slot.horaFin}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ...opciones,
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (elegida == null || !context.mounted) return;

    final esF7 = elegida == 'F7';
    final nombreCancha =
        esF7 ? 'Fútbol 7' : elegida == 'F5-A' ? 'Fútbol 5 - A' : 'Fútbol 5 - B';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar reserva'),
        content: Text(
          '¿Reservar $nombreCancha el ${fechaCorta(fecha)} a las ${slot.horaInicio}?\n\n'
          'Quedará PENDIENTE hasta que la confirmes (o vence 24 h antes).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reservar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !context.mounted) return;

    try {
      final reserva = await ref.read(reservasRepositoryProvider).crear(
            tipo: esF7 ? 'F7' : 'F5',
            fecha: fecha,
            horaInicio: slot.horaInicio,
            cancha: esF7 ? null : elegida,
          );
      ref.invalidate(disponibilidadProvider(fecha));
      ref.invalidate(misReservasProvider);
      if (context.mounted) {
        final q = Uri(queryParameters: {
          'fecha': reserva.fecha,
          'desde': reserva.horaInicio,
          'hasta': reserva.horaFin,
          'cancha': reserva.canchas.join(' + '),
          'estado': reserva.estado,
        }).query;
        context.go('/reserva-exito?$q');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.mensajeDeError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fecha = ref.watch(fechaSeleccionadaProvider);
    final disponibilidad = ref.watch(disponibilidadProvider(fecha));
    final ruta = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      bottomNavigationBar: AppNav(rutaActual: ruta, esAdmin: false),
      body: SafeArea(
        child: Column(
          children: [
            EncabezadoApp(
              titulo: 'TurnosCancha',
              acciones: [
                BotonSalir(
                    onPressed: () => ref.read(authProvider.notifier).logout()),
              ],
            ),
            const SelectorFecha(),
            const SeccionTitulo(titulo: 'Turnos disponibles'),
            Expanded(
              child: disponibilidad.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    VistaError(mensaje: ApiClient.mensajeDeError(e)),
                data: (dispo) {
                  if (dispo.slots.isEmpty) {
                    return const VistaVacia(
                      texto: 'No hay turnos configurados.',
                      icono: Icons.event_busy,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(disponibilidadProvider(fecha)),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      itemCount: dispo.slots.length,
                      itemBuilder: (context, i) {
                        final slot = dispo.slots[i];
                        final libre = slot.algunoLibre;
                        return AppCard(
                          onTap: libre
                              ? () => _reservar(context, ref, fecha, slot)
                              : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${slot.horaInicio} - ${slot.horaFin}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColores.texto,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (!libre)
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColores.neutroClaro,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'OCUPADO',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.6,
                                                color: AppColores.textoSuave,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _ChipCancha(
                                          label: 'F5-A',
                                          libre: slot.f5A,
                                          onTap: slot.f5A
                                              ? () => _reservar(
                                                  context, ref, fecha, slot)
                                              : null,
                                        ),
                                        _ChipCancha(
                                          label: 'F5-B',
                                          libre: slot.f5B,
                                          onTap: slot.f5B
                                              ? () => _reservar(
                                                  context, ref, fecha, slot)
                                              : null,
                                        ),
                                        _ChipCancha(
                                          label: 'F7',
                                          libre: slot.f7,
                                          onTap: slot.f7
                                              ? () => _reservar(
                                                  context, ref, fecha, slot)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (libre)
                                const Icon(Icons.chevron_right,
                                    color: AppColores.textoSuave)
                              else
                                const Tooltip(
                                  message: 'Ocupado',
                                  child: Icon(Icons.lock,
                                      color: AppColores.textoSuave),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Tocá un horario libre para reservar',
                  style: TextStyle(color: AppColores.textoSuave, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipCancha extends StatelessWidget {
  const _ChipCancha({
    required this.label,
    required this.libre,
    this.onTap,
  });

  final String label;
  final bool libre;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = libre ? AppColores.primarioClaro : AppColores.peligroClaro;
    final fg = libre ? const Color(0xFF15803D) : const Color(0xFFB91C1C);
    final texto = libre ? 'libre' : 'ocupado';
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              libre ? Icons.check_circle : Icons.cancel,
              size: 14,
              color: fg,
            ),
            const SizedBox(width: 4),
            Text(
              '$label · $texto',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
