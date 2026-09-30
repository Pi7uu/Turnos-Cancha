import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/app_nav.dart';
import '../../core/colores.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/encabezado_app.dart';
import '../../core/widgets/vista_estado.dart';
import '../auth/auth_providers.dart';
import '../reservas/reservas_providers.dart';

/// Listado de clientes con su historial (Etapa 2 §4).
class ClientesScreen extends ConsumerWidget {
  const ClientesScreen({super.key});

  Future<void> _verHistorial(
      BuildContext context, WidgetRef ref, int clienteId) async {
    final reservas =
        await ref.read(reservasRepositoryProvider).reservasDeCliente(clienteId);
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: reservas.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Sin reservas registradas.'),
              )
            : ListView.builder(
                itemCount: reservas.length,
                itemBuilder: (context, i) {
                  final r = reservas[i];
                  return ListTile(
                    leading: Icon(
                      r.estado == 'CONFIRMADA'
                          ? Icons.check_circle
                          : r.estado == 'PENDIENTE'
                              ? Icons.hourglass_top
                              : Icons.cancel,
                      color: r.estado == 'CONFIRMADA'
                          ? AppColores.primario
                          : r.estado == 'PENDIENTE'
                              ? AppColores.alerta
                              : AppColores.peligro,
                    ),
                    title: Text(
                        '${r.fecha} · ${r.horaInicio} - ${r.horaFin} · ${r.canchas.join(' + ')}'),
                    subtitle: Text(r.estado),
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientes = ref.watch(clientesProvider);
    final ruta = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      bottomNavigationBar: AppNav(rutaActual: ruta, esAdmin: true),
      body: SafeArea(
        child: Column(
          children: [
            EncabezadoApp(
              titulo: 'Clientes',
              acciones: [
                BotonSalir(
                    onPressed: () => ref.read(authProvider.notifier).logout()),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: clientes.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    VistaError(mensaje: ApiClient.mensajeDeError(e)),
                data: (lista) {
                  if (lista.isEmpty) {
                    return const VistaVacia(
                      texto: 'Todavía no hay clientes registrados.',
                      icono: Icons.people_outline,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(clientesProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      itemCount: lista.length,
                      itemBuilder: (context, i) {
                        final u = lista[i];
                        return AppCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          onTap: () => _verHistorial(context, ref, u.id),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColores.primarioClaro,
                              child: Icon(Icons.person,
                                  color: AppColores.primario),
                            ),
                            title: Text(
                              u.nombre.isNotEmpty ? u.nombre : u.email,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              u.email,
                              style: const TextStyle(
                                  color: AppColores.textoSuave),
                            ),
                            trailing: const Icon(Icons.history,
                                color: AppColores.textoSuave),
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
