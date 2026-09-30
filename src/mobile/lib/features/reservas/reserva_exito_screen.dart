import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/colores.dart';
import '../../core/fechas.dart';

/// Pantalla de confirmación tras crear una reserva (equivalente a la
/// pantalla "Booking Successful!" del mockup, con datos reales).
class ReservaExitoScreen extends StatelessWidget {
  const ReservaExitoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final q = GoRouterState.of(context).uri.queryParameters;
    final fecha = q['fecha'] ?? '';
    final desde = q['desde'] ?? '';
    final hasta = q['hasta'] ?? '';
    final cancha = q['cancha'] ?? '';
    final estado = q['estado'] ?? 'PENDIENTE';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: AppColores.primario,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4016A34A),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check,
                            size: 60, color: Colors.white),
                      ),
                      Positioned(
                        top: 4,
                        right: 10,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColores.alerta,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '¡Reserva creada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColores.texto,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu cancha $cancha quedó reservada para '
                '${fecha.isNotEmpty ? fechaLarga(fecha) : ''}'
                '${desde.isNotEmpty ? ', de $desde a $hasta' : ''}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, color: AppColores.textoSuave, height: 1.4),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColores.superficie,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColores.borde),
                ),
                child: Column(
                  children: [
                    _filaResumen(
                      'FECHA',
                      fecha.isNotEmpty ? fechaCorta(fecha) : '—',
                    ),
                    const Divider(height: 24),
                    _filaResumen(
                      'HORARIO',
                      desde.isNotEmpty ? '$desde - $hasta' : '—',
                    ),
                    const Divider(height: 24),
                    _filaResumen('CANCHA', cancha),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ESTADO',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColores.textoSuave)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColores.alertaClaro,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            estado,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Recordá confirmarla desde "Mis reservas" antes de que venca.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColores.textoSuave),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => context.go('/mis-reservas'),
                child: const Text('Ver mis reservas'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaResumen(String label, String valor) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColores.textoSuave)),
          Text(valor,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColores.texto)),
        ],
      );
}
