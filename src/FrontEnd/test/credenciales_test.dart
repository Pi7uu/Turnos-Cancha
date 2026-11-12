import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/auth/credenciales.dart';
import 'package:turnos_cancha/features/auth/usuarios_locales.dart';

void main() {
  group('credencialesValidas (RF-03)', () {
    test('credenciales_validas_match_exacto', () {
      expect(
        credencialesValidas('igpi7uu@gmail.com', 'igpi7uu'),
        isTrue,
      );
    });

    test('credenciales_validas_email_case_insensitive_y_trim', () {
      expect(
        credencialesValidas('  IgPi7Uu@GmAiL.com ', 'igpi7uu'),
        isTrue,
        reason: 'el email se compara sin mayúsculas y sin espacios externos',
      );
    });

    test('credenciales_validas_password_no_se_trimpea', () {
      expect(
        credencialesValidas('igpi7uu@gmail.com', 'igpi7uu '),
        isFalse,
        reason: 'la contraseña se compara exacta (sin trim)',
      );
      expect(
        credencialesValidas('igpi7uu@gmail.com', ' Igpi7uu'),
        isFalse,
      );
    });

    test('credenciales_validas_email_incorrecto', () {
      expect(
        credencialesValidas('otro@gmail.com', 'igpi7uu'),
        isFalse,
      );
    });

    test('credenciales_validas_password_incorrecto', () {
      expect(
        credencialesValidas('igpi7uu@gmail.com', 'otra'),
        isFalse,
      );
    });

    test('credenciales_validas_vacios', () {
      expect(credencialesValidas('', ''), isFalse);
      expect(credencialesValidas('', 'igpi7uu'), isFalse);
      expect(credencialesValidas('igpi7uu@gmail.com', ''), isFalse);
    });
  });

  group('credencialesValidas con usuarios registrados (RF-06)', () {
    setUp(() => resetUsuarios());

    test('credenciales_validas_acepta_usuario_registrado', () {
      registrarUsuario('Marta Gómez', 'marta@test.com', 'qwerty1234');
      expect(credencialesValidas('marta@test.com', 'qwerty1234'), isTrue);
    });

    test('credenciales_validas_acepta_variaciones_del_registrado', () {
      registrarUsuario('Marta Gómez', ' Marta@Test.com ', 'qwerty1234');
      expect(credencialesValidas(' MARTA@test.com ', 'qwerty1234'), isTrue);
    });

    test('credenciales_validas_usuario_registrado_password_distinta_falla', () {
      registrarUsuario('Marta Gómez', 'marta@test.com', 'qwerty1234');
      expect(credencialesValidas('marta@test.com', 'otra1234'), isFalse);
      expect(
        credencialesValidas('marta@test.com', 'Qwerty1234'),
        isFalse,
        reason: 'la contraseña del registrado también se compara case-sensitive',
      );
    });

    test('credenciales_validas_semilla_sigue_funcionando', () {
      expect(credencialesValidas('igpi7uu@gmail.com', 'igpi7uu'), isTrue);
    });
  });
}
