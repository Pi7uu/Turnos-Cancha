/// Store de favoritos en memoria ( RD
/// `docs/HistRequerimientos/favoritos.md` RF-02 ): lista mutable sembrada
/// con [canchasSimuladas]. La pantalla Favoritos lee/muta esta lista.
///
/// Vive en memoria: al reiniciar la app vuelve a la semilla ( las 3 canchas
/// del mockup son favoritas por defecto ).
library;

import 'package:flutter/foundation.dart';

import '../inicio/cancha.dart';

/// La lista de favoritos de la sesión ( orden: Elite / Skyline / Municipal ).
final List<Cancha> favoritosLocales = [...canchasSimuladas];

/// Quita una cancha de favoritos.
void quitarFavorito(Cancha cancha) {
  favoritosLocales.remove(cancha);
}

/// Devuelve el store a la semilla ( para tests ).
@visibleForTesting
void resetFavoritos() {
  favoritosLocales
    ..clear()
    ..addAll(canchasSimuladas);
}
