import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/app_nav.dart';
import '../../core/fechas.dart';
import '../reservas/reservas_providers.dart';

/// Reserva manual del admin (clientes que llaman por teléfono) — Etapa 2 §4.
class ReservaManualScreen extends ConsumerStatefulWidget {
  const ReservaManualScreen({super.key});

  @override
  ConsumerState<ReservaManualScreen> createState() =>
      _ReservaManualScreenState();
}

class _ReservaManualScreenState extends ConsumerState<ReservaManualScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cliente = TextEditingController();
  final _fecha = TextEditingController(text: hoyIso());
  final _hora = TextEditingController(text: '20:00');
  String _tipo = 'F5';
  String _cancha = 'F5-A';
  bool _confirmada = true;
  bool _cargando = false;

  @override
  void dispose() {
    _cliente.dispose();
    _fecha.dispose();
    _hora.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final actual = fromIso(_fecha.text.isEmpty ? hoyIso() : _fecha.text);
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (seleccionada != null) {
      _fecha.text = toIso(seleccionada);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      await ref.read(reservasRepositoryProvider).reservaManual(
            clienteEmail: _cliente.text.trim(),
            tipo: _tipo,
            fecha: _fecha.text,
            horaInicio: _hora.text,
            cancha: _tipo == 'F5' ? _cancha : null,
            confirmada: _confirmada,
          );
      ref.invalidate(agendaProvider(_fecha.text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_confirmada
                ? 'Reserva creada y confirmada.'
                : 'Reserva creada (pendiente de confirmar).'),
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiClient.mensajeDeError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ruta = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppBar(title: const Text('Reserva manual')),
      bottomNavigationBar: AppNav(rutaActual: ruta, esAdmin: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _cliente,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email del cliente',
                ),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Ingresá un email válido',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fecha,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _elegirFecha,
                  ),
                ),
                validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Elegí la fecha',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hora,
                decoration: const InputDecoration(
                  labelText: 'Hora de inicio (HH:MM)',
                  helperText: 'Ej: 20:00',
                ),
                validator: (v) {
                  if (v == null || !RegExp(r'^\d{2}:\d{2}$').hasMatch(v)) {
                    return 'Formato HH:MM';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cancha',
                ),
                items: const [
                  DropdownMenuItem(value: 'F5', child: Text('Fútbol 5')),
                  DropdownMenuItem(value: 'F7', child: Text('Fútbol 7')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'F5'),
              ),
              if (_tipo == 'F5') ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _cancha,
                  decoration: const InputDecoration(
                    labelText: 'Cancha',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'F5-A', child: Text('F5 - A')),
                    DropdownMenuItem(value: 'F5-B', child: Text('F5 - B')),
                  ],
                  onChanged: (v) => setState(() => _cancha = v ?? 'F5-A'),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Confirmar ahora'),
                subtitle: const Text(
                    'Si está desactivada, la reserva queda PENDIENTE para el cliente'),
                value: _confirmada,
                onChanged: (v) => setState(() => _confirmada = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _cargando ? null : _guardar,
                child: _cargando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
