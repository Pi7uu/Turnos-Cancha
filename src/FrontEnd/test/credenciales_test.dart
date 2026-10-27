import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/auth/credenciales.dart';

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
}
