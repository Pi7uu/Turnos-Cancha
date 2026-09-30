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
import '../../core/widgets/estado_badge.dart';
import '../../core/widgets/vista_estado.dart';
import '../auth/auth_providers.dart';
import 'reservas_providers.dart';

const _tabs = ['Próximas', 'Completadas', 'Canceladas'];

class MisReservasScreen extends ConsumerStatefulWidget {
  const MisReservasScreen({super.key});

  @override
  ConsumerState<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends ConsumerState<MisReservasScreen> {
  int _tab = 0;

  List<Reserva> _filtradas(List<Reserva> lista) {
    final hoy = hoyIso();
    final ordenadas = [...lista]..sort((a, b) {
        final c = a.fecha.compareTo(b.fecha);
        if (c != 0) return c;
        return a.horaInicio.compareTo(b.horaInicio);
      });
    switch (_tab) {
      case 0: // Próximas: activas de hoy en adelante
        return ordenadas
            .where((r) => r.estaActiva && r.fecha.compareTo(hoy) >= 0)
            .toList();
      case 1: // Completadas: todo lo no cancelado que ya no es próximo
        return ordenadas
            .where((r) => r.estado != 'CANCELADA' &&
                !(r.estaActiva && r.fecha.compareTo(hoy) >= 0))
            .toList();
      case 2: // Canceladas
        return ordenadas.where((r) => r.estado == 'CANCELADA').toList();
      default:
        return ordenadas;
    }
  }

  String get _vacio {
    switch (_tab) {
      case 0:
        return 'Todavía no tenés reservas próximas.';
      case 1:
        return 'Todavía no tenés reservas completadas.';
      default:
        return 'No tenés reservas canceladas.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservas = ref.watch(misReservasProvider);
    final ruta = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      bottomNavigationBar: AppNav(rutaActual: ruta, esAdmin: false),
      body: SafeArea(
        child: Column(
          children: [
            EncabezadoApp(
              titulo: 'Mis reservas',
              acciones: [
                BotonSalir(
                    onPressed: () => ref.read(authProvider.notifier).logout()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: _TabItem(
                        label: _tabs[i],
                        activo: _tab == i,
                        onTap: () => setState(() => _tab = i),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: reservas.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    VistaError(mensaje: ApiClient.mensajeDeError(e)),
                data: (lista) {
                  final filtradas = _filtradas(lista);
                  if (filtradas.isEmpty) {
                    return VistaVacia(
                      texto: _vacio,
                      icono: Icons.event_note,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(misReservasProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      itemCount: filtradas.length,
                      itemBuilder: (context, i) =>
                          _TarjetaReserva(reserva: filtradas[i]),
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

/// Tabs de filtro con underline, estilo mockup.
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  final String label;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: activo ? FontWeight.w800 : FontWeight.w500,
                color: activo ? AppColores.primario : AppColores.textoSuave,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 28,
              decoration: BoxDecoration(
                color: activo
                    ? AppColores.primario
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaReserva extends ConsumerWidget {
  const _TarjetaReserva({required this.reserva});

  final Reserva reserva;

  Future<void> _accion(
    BuildContext context,
    WidgetRef ref, {
    required bool confirmar,
  }) async {
    try {
      if (confirmar) {
        await ref.read(reservasRepositoryProvider).confirmar(reserva.id);
      } else {
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(confirmar ? 'Confirmar reserva' : 'Cancelar reserva'),
            content: Text(
              '${fechaCorta(reserva.fecha)} · ${reserva.horaInicio} - ${reserva.horaFin}\n'
              '${reserva.canchas.join(' + ')}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmar ? 'Sí, confirmar' : 'Sí, cancelar'),
              ),
            ],
          ),
        );
        if (ok != true) return;
        await ref.read(reservasRepositoryProvider).cancelar(reserva.id);
      }
      ref.invalidate(misReservasProvider);
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
    final r = reserva;
    final tipo = r.tipo == 'F7' ? 'Fútbol 7' : 'Fútbol 5';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColores.primarioClaro,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_soccer,
                    size: 20, color: AppColores.primario),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tipo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColores.texto,
                      ),
                    ),
                    Text(
                      fechaLarga(r.fecha),
                      style: const TextStyle(
                          fontSize: 13, color: AppColores.textoSuave),
                    ),
                  ],
                ),
              ),
              EstadoBadge(estado: r.estado),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HORARIO',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColores.textoSuave)),
                    const SizedBox(height: 4),
                    Text(
                      '${r.horaInicio} - ${r.horaFin}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColores.texto,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CANCHA',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColores.textoSuave)),
                    const SizedBox(height: 4),
                    Text(
                      r.canchas.join(' + '),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColores.texto,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (r.esPendiente)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        _accion(context, ref, confirmar: false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        _accion(context, ref, confirmar: true),
                    child: const Text('Confirmar'),
                  ),
                ),
              ],
            )
          else if (r.estado == 'CONFIRMADA' && r.clientePuedeCancelar)
            OutlinedButton(
              onPressed: () => _accion(context, ref, confirmar: false),
              child: const Text('Cancelar reserva'),
            )
          else if (r.estado == 'CONFIRMADA')
            const Text(
              'Cancelación solo por el administrador (faltan menos de 24 h)',
              style: TextStyle(fontSize: 12, color: AppColores.textoSuave),
            ),
        ],
      ),
    );
  }
}
