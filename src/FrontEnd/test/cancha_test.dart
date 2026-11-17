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
  });
}
