/// Store de reservas en memoria ( RD
/// `docs/HistRequerimientos/mis-reservas-acciones.md` RF-02 ): lista
/// mutable sembrada con [reservasSimuladas]. El flujo de reserva registra
/// acá sus éxitos y la pantalla Mis reservas lee/muta esta lista.
///
/// Vive en memoria: al reiniciar la app vuelve a la semilla.
library;

import 'package:flutter/foundation.dart';

import 'reserva.dart';

/// La lista de reservas de la sesión ( orden: las nuevas al inicio ).
final List<Reserva> reservasLocales = [...reservasSimuladas];

/// Registra una reserva nueva ( la agrega al inicio — las más nuevas primero ).
void registrarReserva(Reserva reserva) {
  reservasLocales.insert(0, reserva);
}

/// Cancela una reserva ( pasa a [EstadoReserva.cancelada] ).
void cancelarReserva(Reserva reserva) {
  _reemplazar(reserva, reserva.copyWith(estado: EstadoReserva.cancelada));
}

/// Confirma una reserva pendiente ( pasa a [EstadoReserva.confirmada] ).
void confirmarReserva(Reserva reserva) {
  _reemplazar(reserva, reserva.copyWith(estado: EstadoReserva.confirmada));
}

void _reemplazar(Reserva actual, Reserva nueva) {
  final i = reservasLocales.indexOf(actual);
  if (i != -1) {
    reservasLocales[i] = nueva;
  }
}

/// Devuelve el store a la semilla ( para tests ).
@visibleForTesting
void resetReservas() {
  reservasLocales
    ..clear()
    ..addAll(reservasSimuladas);
}
