import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/favoritos/favoritos_locales.dart';
import 'package:turnos_cancha/features/inicio/cancha.dart';

void main() {
  setUp(resetFavoritos);

  group('favoritosLocales (RD favoritos RF-02)', () {
    test('store_arranca_con_las_3', () {
      expect(favoritosLocales.length, 3);
      expect(favoritosLocales[0].nombre, 'Elite Arena Central');
      expect(favoritosLocales[1].nombre, 'Skyline Sports Hub');
      expect(favoritosLocales[2].nombre, 'Cancha Municipal');
    });

    test('quitar_favorito_elimina_de_la_lista', () {
      quitarFavorito(favoritosLocales[1]);
      expect(favoritosLocales.length, 2);
      expect(
        favoritosLocales.map((c) => c.nombre),
        ['Elite Arena Central', 'Cancha Municipal'],
      );
    });

    test('reset_vuelve_a_la_semilla', () {
      quitarFavorito(favoritosLocales[0]);
      resetFavoritos();
      expect(favoritosLocales.length, 3);
      expect(favoritosLocales.first.nombre, 'Elite Arena Central');
    });
  });
}
