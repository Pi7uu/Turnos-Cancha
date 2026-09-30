import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/app_nav.dart';
import '../../core/colores.dart';
import '../../core/estados.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/encabezado_app.dart';
import '../../core/widgets/selector_fecha.dart';
import '../../core/widgets/vista_estado.dart';
import '../auth/auth_providers.dart';
import '../reservas/reservas_providers.dart';

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  Future<void> _cancelar(
      BuildContext context, WidgetRef ref, Map<String, dynamic> reserva) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: Text(
          '${reserva['cliente_nombre']} · ${reserva['hora_inicio']} - '
          '${reserva['hora_fin']} · ${(reserva['canchas'] as List).join(' + ')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancelar reserva'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ref
          .read(reservasRepositoryProvider)
          .cancelar(reserva['id'] as int);
      ref.invalidate(agendaProvider(ref.read(fechaSeleccionadaProvider)));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva cancelada.')),
        );
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
    final agenda = ref.watch(agendaProvider(fecha));
    final ruta = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      bottomNavigationBar: AppNav(rutaActual: ruta, esAdmin: true),
      body: SafeArea(
        child: Column(
          children: [
            EncabezadoApp(
              titulo: 'Agenda',
              acciones: [
                BotonSalir(
                    onPressed: () => ref.read(authProvider.notifier).logout()),
              ],
            ),
            const SelectorFecha(
                retrocesoDias: 30, titulo: 'Fecha de la agenda'),
            const SizedBox(height: 8),
            Expanded(
              child: agenda.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    VistaError(mensaje: ApiClient.mensajeDeError(e)),
                data: (reservas) {
                  if (reservas.isEmpty) {
                    return const VistaVacia(
                      texto: 'No hay reservas este día.',
                      icono: Icons.event_available,
                    );
                  }
                  final ordenadas = [...reservas]
                    ..sort((a, b) =>
                        (a['hora_inicio'] as String)
                            .compareTo(b['hora_inicio'] as String));
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(agendaProvider(fecha)),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      itemCount: ordenadas.length,
                      itemBuilder: (context, i) {
                        final r = ordenadas[i];
                        final estado = r['estado'] as String;
                        final activa =
                            estado == 'PENDIENTE' || estado == 'CONFIRMADA';
                        return AppCard(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorEstado(estado),
                              child: Text(
                                '${r['hora_inicio']}'.substring(0, 2),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(
                              '${r['hora_inicio']} - ${r['hora_fin']} · '
                              '${r['tipo']} (${(r['canchas'] as List).join(' + ')})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${r['cliente_nombre']} · $estado',
                              style: const TextStyle(
                                  color: AppColores.textoSuave),
                            ),
                            trailing: activa
                                ? IconButton(
                                    icon: const Icon(Icons.cancel_outlined,
                                        color: AppColores.peligro),
                                    tooltip: 'Cancelar reserva',
                                    onPressed: () => _cancelar(context, ref, r),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
