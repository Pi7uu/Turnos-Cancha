import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';

void main() {
  group('canchasSimuladas (RD inicio-canchas §4)', () {
    test('canchas_simuladas_son_3_en_orden_del_mockup', () {
      expect(canchasSimuladas.map((c) => c.nombre).toList(),
          ['Elite Arena Central', 'Skyline Sports Hub', 'Cancha Municipal']);
    });

    test('canchas_simuladas_datos_exactos', () {
      expect(canchasSimuladas[0].tag, '5v5');
      expect(canchasSimuladas[0].distancia, '1.2 km de vos');
      expect(canchasSimuladas[0].rating, '4.8 (124 reseñas)');
      expect(canchasSimuladas[0].precio, r'$45');
      expect(canchasSimuladas[1].tag, '7v7');
      expect(canchasSimuladas[1].distancia, '2.8 km de vos');
      expect(canchasSimuladas[1].rating, '4.6 (89 reseñas)');
      expect(canchasSimuladas[1].precio, r'$60');
      expect(canchasSimuladas[2].tag, '5v5');
      expect(canchasSimuladas[2].distancia, '3.5 km de vos');
      expect(canchasSimuladas[2].rating, '4.9 (210 reseñas)');
      expect(canchasSimuladas[2].precio, r'$40');
    });

    test('canchas_simuladas_referencian_assets', () {
      for (final c in canchasSimuladas) {
        expect(c.foto, startsWith('assets/img/canchas/'));
      }
    });

    test('canchas_simuladas_campos_del_detalle', () {
      expect(canchasSimuladas[0].direccion, 'Av. de los Deportes 123, Centro');
      expect(canchasSimuladas[0].puntuacion, 4.8);
      expect(canchasSimuladas[0].premium, isTrue);
      expect(
          canchasSimuladas[0].hero, 'assets/img/canchas/elite_arena_hero.jpg');
      expect(canchasSimuladas[1].direccion, 'Av. del Parque 789, Oeste');
      expect(canchasSimuladas[1].puntuacion, 4.6);
      expect(canchasSimuladas[2].direccion, 'Calle San Martín 45, Centro');
      expect(canchasSimuladas[2].puntuacion, 4.9);
      expect(canchasSimuladas[2].premium, isFalse);
      expect(canchasSimuladas[2].hero, canchasSimuladas[2].foto,
          reason: 'sin hero propio usa su foto de card');
    });

    test('canchas_simuladas_comodidades_y_descripcion', () {
      expect(canchasSimuladas[0].comodidadesNoDisponibles, isEmpty);
      expect(
          canchasSimuladas[0].descripcion,
          'Césped sintético de grado profesional, iluminación LED de alta '
          'intensidad para partidos nocturnos y vestuarios con aire '
          'acondicionado. Perfecto para quinta con amigos o torneos '
          'competitivos.');
      expect(canchasSimuladas[1].comodidadesNoDisponibles, ['Estac.', 'WiFi']);
      expect(
          canchasSimuladas[1].descripcion,
          'Cancha techada de última generación, ideal para partidos nocturnos '
          'y torneos corporativos. Vestuarios amplios y acceso controlado.');
      expect(canchasSimuladas[2].comodidadesNoDisponibles, isEmpty);
      expect(
          canchasSimuladas[2].descripcion,
          'Cancha al aire libre en el corazón de la ciudad, con césped '
          'renovado y fácil acceso en transporte público. Ideal para '
          'partidos con amigos.');
    });

    test('canchas_simuladas_horas_ocupadas', () {
      expect(canchasSimuladas[0].horasOcupadas, ['21:00']);
      expect(canchasSimuladas[1].horasOcupadas, ['17:00', '21:00']);
      expect(canchasSimuladas[2].horasOcupadas, ['20:00']);
    });
  });
}
