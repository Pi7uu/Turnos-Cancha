/// Modelo de reserva y data simulada ( RD
/// `docs/HistRequerimientos/mis-reservas-lista.md` §4 ): las reservas que
/// se muestran en la pantalla Mis reservas, hasta que llegue el store
/// compartido con el flujo ( parte 2 ) y la API REST.
library;

/// Estado de la reserva en Mis reservas ( badge de la card ).
enum EstadoReserva { confirmada, pendiente, completada, cancelada }

/// Una reserva de Mis reservas.
class Reserva {
  const Reserva({
    required this.nombre,
    required this.foto,
    required this.fecha,
    required this.horario,
    required this.sector,
    required this.estado,
  });

  /// Nombre de la cancha reservada.
  final String nombre;

  /// Path del asset de la foto ( `cancha.foto` correspondiente ).
  final String foto;

  /// Fecha con año, ej: `Mar, 15 oct 2026`.
  final String fecha;

  /// Rango horario, ej: `19:00 - 20:00`.
  final String horario;

  /// Sector/cancha reservada, ej: `Cancha A (5v5)`.
  final String sector;

  final EstadoReserva estado;
}

/// Reservas simuladas, en orden ( RD §4 ): las 2 Próximas del mockup y una
/// Completada y una Cancelada inventadas para ver las 3 pestañas.
const List<Reserva> reservasSimuladas = [
  Reserva(
    nombre: 'Elite Arena Central',
    foto: 'assets/img/canchas/elite_arena.jpg',
    fecha: 'Mar, 15 oct 2026',
    horario: '19:00 - 20:00',
    sector: 'Cancha A (5v5)',
    estado: EstadoReserva.confirmada,
  ),
  Reserva(
    nombre: 'Skyline Sports Hub',
    foto: 'assets/img/canchas/skyline_sports.jpg',
    fecha: 'Sáb, 19 oct 2026',
    horario: '10:00 - 11:30',
    sector: 'Cancha principal (7v7)',
    estado: EstadoReserva.pendiente,
  ),
  Reserva(
    nombre: 'Cancha Municipal',
    foto: 'assets/img/canchas/cancha_municipal.jpg',
    fecha: 'Lun, 12 oct 2026',
    horario: '18:00 - 19:00',
    sector: 'Cancha B (5v5)',
    estado: EstadoReserva.completada,
  ),
  Reserva(
    nombre: 'Elite Arena Central',
    foto: 'assets/img/canchas/elite_arena.jpg',
    fecha: 'Vie, 23 oct 2026',
    horario: '20:00 - 21:00',
    sector: 'Cancha A (5v5)',
    estado: EstadoReserva.cancelada,
  ),
];
