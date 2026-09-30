/// Modelos de dominio de la app (espejo del modelo de datos del backend).
class Usuario {
  const Usuario({
    required this.id,
    required this.email,
    required this.rol,
    this.nombre = '',
    this.telefono = '',
  });

  final int id;
  final String email;
  final String rol;
  final String nombre;
  final String telefono;

  bool get esAdmin => rol == 'ADMIN';

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int,
        email: json['email'] as String? ?? '',
        rol: json['rol'] as String? ?? 'CLIENTE',
        nombre: [
          json['first_name'] as String? ?? '',
          json['last_name'] as String? ?? '',
        ].where((p) => p.isNotEmpty).join(' '),
        telefono: json['telefono'] as String? ?? '',
      );
}

class Slot {
  const Slot({
    required this.horaInicio,
    required this.horaFin,
    required this.f5A,
    required this.f5B,
    required this.f7,
  });

  final String horaInicio;
  final String horaFin;
  final bool f5A;
  final bool f5B;
  final bool f7;

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        horaInicio: json['hora_inicio'] as String,
        horaFin: json['hora_fin'] as String,
        f5A: json['f5_a'] as bool,
        f5B: json['f5_b'] as bool,
        f7: json['f7'] as bool,
      );

  bool get algunoLibre => f5A || f5B || f7;
}

class Disponibilidad {
  const Disponibilidad({required this.fecha, required this.slots});

  final String fecha;
  final List<Slot> slots;

  factory Disponibilidad.fromJson(Map<String, dynamic> json) => Disponibilidad(
        fecha: json['fecha'] as String,
        slots: (json['slots'] as List)
            .map((s) => Slot.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class Reserva {
  const Reserva({
    required this.id,
    required this.tipo,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.canchas,
    required this.clientePuedeCancelar,
    this.clienteEmail = '',
    this.clienteNombre = '',
  });

  final int id;
  final String tipo;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;
  final List<String> canchas;
  final bool clientePuedeCancelar;
  final String clienteEmail;
  final String clienteNombre;

  bool get esPendiente => estado == 'PENDIENTE';
  bool get estaActiva => estado == 'PENDIENTE' || estado == 'CONFIRMADA';

  factory Reserva.fromJson(Map<String, dynamic> json) => Reserva(
        id: json['id'] as int,
        tipo: json['tipo'] as String,
        fecha: json['fecha'] as String,
        horaInicio: _horaCorta(json['hora_inicio'] as String? ?? ''),
        horaFin: _horaCorta(json['hora_fin'] as String? ?? ''),
        estado: json['estado'] as String,
        canchas: (json['canchas'] as List? ?? [])
            .map((c) => c.toString())
            .toList(),
        clientePuedeCancelar: json['cliente_puede_cancelar'] as bool? ?? false,
        clienteEmail: json['cliente_email'] as String? ?? '',
        clienteNombre: json['cliente_nombre'] as String? ?? '',
      );

  static String _horaCorta(String hora) =>
      hora.length >= 5 ? hora.substring(0, 5) : hora;
}
