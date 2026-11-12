import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/auth/usuarios_locales.dart';

void main() {
  setUp(() => resetUsuarios());

  group('usuarios_locales (RD registro §2 modelo de datos)', () {
    test('usuarios_arranca_con_usuario_semilla', () {
      expect(emailRegistrado('igpi7uu@gmail.com'), isTrue);
      expect(emailRegistrado('  igpi7uu@GMAIL.com '), isTrue);
      expect(emailRegistrado('marta@test.com'), isFalse);
    });

    test('usuarios_email_registrado_normaliza_y_login_acepta_variaciones', () {
      registrarUsuario('Marta Gómez', ' Marta@Test.com ', 'qwerty1234');
      expect(emailRegistrado('marta@test.com'), isTrue);
      expect(emailRegistrado(' MARTA@test.com '), isTrue);
    });

    test('usuarios_registrar_guarda_norma_y_valores', () {
      registrarUsuario(' José  ', ' jose@test.com ', 'contraseña8');
      expect(emailRegistrado('JOSE@test.com'), isTrue);
    });

    test('usuarios_registrar_ya_existente_lanza_error', () {
      registrarUsuario('Uno', 'a@test.com', 'contraseña8');
      expect(() => registrarUsuario('Dos', ' A@test.com ', 'contraseña8'),
          throwsArgumentError);
    });

    test('usuarios_reset_vuelve_al_estado_semilla', () {
      registrarUsuario('Marta Gómez', 'marta@test.com', 'qwerty1234');
      resetUsuarios();
      expect(emailRegistrado('marta@test.com'), isFalse);
      expect(emailRegistrado('igpi7uu@gmail.com'), isTrue);
    });
  });
}
