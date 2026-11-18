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
    required this.comodidadesNoDisponibles,
    required this.descripcion,
    required this.horasOcupadas,
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

  /// Labels exactos de las comodidades NO disponibles ( `Estac.`, `WiFi`… );
  /// vacío = las 5 del mockup disponibles ( RD detalle-comodidades §4 ).
  final List<String> comodidadesNoDisponibles;

  /// Párrafo del bloque "Sobre esta cancha".
  final String descripcion;

  /// Horas ocupadas ( formato `HH:00`, ej: `21:00` ) — data simulada
  /// ( RD detalle-horarios §4 ).
  final List<String> horasOcupadas;
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
    comodidadesNoDisponibles: [],
    descripcion:
        'Césped sintético de grado profesional, iluminación LED de alta '
        'intensidad para partidos nocturnos y vestuarios con aire '
        'acondicionado. Perfecto para quinta con amigos o torneos '
        'competitivos.',
    horasOcupadas: ['21:00'],
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
    comodidadesNoDisponibles: ['Estac.', 'WiFi'],
    descripcion:
        'Cancha techada de última generación, ideal para partidos nocturnos '
        'y torneos corporativos. Vestuarios amplios y acceso controlado.',
    horasOcupadas: ['17:00', '21:00'],
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
    comodidadesNoDisponibles: [],
    descripcion:
        'Cancha al aire libre en el corazón de la ciudad, con césped '
        'renovado y fácil acceso en transporte público. Ideal para '
        'partidos con amigos.',
    horasOcupadas: ['20:00'],
  ),
];
