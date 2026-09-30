import 'package:flutter/material.dart';

import 'colores.dart';

/// Color de fondo de cada estado de reserva.
Color colorEstado(String estado) {
  switch (estado) {
    case 'CONFIRMADA':
      return AppColores.primario;
    case 'PENDIENTE':
      return AppColores.alerta;
    case 'VENCIDA':
      return AppColores.peligro;
    case 'CANCELADA':
      return AppColores.textoSuave;
    default:
      return AppColores.textoSuave;
  }
}

/// Etiqueta a mostrar para cada estado (en mayúsculas, como el mockup).
String etiquetaEstado(String estado) => estado.toUpperCase();
