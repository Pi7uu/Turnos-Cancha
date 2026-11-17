/// Modelo de cancha y datos simulados ( RD `docs/requerimientos/inicio-canchas.md`
/// RF-01 ): las 3 canchas fijas del mockup, hasta que llegue el filtrado y la
/// API REST.
class Cancha {
  const Cancha({
    required this.nombre,
    required this.tag,
    required this.distancia,
    required this.rating,
    required this.precio,
    required this.foto,
    required this.direccion,
    required this.puntuacion,
    required this.premium,
    required this.hero,
  });

  final String nombre;
  final String tag;

  /// Texto ya armado, ej: `1.2 km de vos`.
  final String distancia;

  /// Texto ya armado, ej: `4.8 (124 reseñas)`.
  final String rating;

  /// Monto sin unidad, ej: `$45` ( la unidad `/ hora` la dibuja la UI ).
  final String precio;

  /// Path del asset local ( sin HTTP en runtime ).
  final String foto;

  /// Dirección del Detalle ( RD detalle-hero §4 ).
  final String direccion;

  /// Valor numérico del rating, ej: 4.8 ( el Detalle lo muestra solo ).
  final double puntuacion;

  /// Muestra el badge `PREMIUM` en el Detalle.
  final bool premium;

  /// Foto del hero del Detalle ( si no hay propia, usa [foto] ).
  final String hero;
}

/// Las 3 canchas del mockup, en orden ( RD §4 ).
const List<Cancha> canchasSimuladas = [
  Cancha(
    nombre: 'Elite Arena Central',
    tag: '5v5',
    distancia: '1.2 km de vos',
    rating: '4.8 (124 reseñas)',
    precio: r'$45',
    foto: 'assets/img/canchas/elite_arena.jpg',
    direccion: 'Av. de los Deportes 123, Centro',
    puntuacion: 4.8,
    premium: true,
    hero: 'assets/img/canchas/elite_arena_hero.jpg',
  ),
  Cancha(
    nombre: 'Skyline Sports Hub',
    tag: '7v7',
    distancia: '2.8 km de vos',
    rating: '4.6 (89 reseñas)',
    precio: r'$60',
    foto: 'assets/img/canchas/skyline_sports.jpg',
    direccion: 'Av. del Parque 789, Oeste',
    puntuacion: 4.6,
    premium: true,
    hero: 'assets/img/canchas/skyline_sports.jpg',
  ),
  Cancha(
    nombre: 'Cancha Municipal',
    tag: '5v5',
    distancia: '3.5 km de vos',
    rating: '4.9 (210 reseñas)',
    precio: r'$40',
    foto: 'assets/img/canchas/cancha_municipal.jpg',
    direccion: 'Calle San Martín 45, Centro',
    puntuacion: 4.9,
    premium: false,
    hero: 'assets/img/canchas/cancha_municipal.jpg',
  ),
];
