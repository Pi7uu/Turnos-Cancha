import 'package:flutter_test/flutter_test.dart';
import 'package:turnos_cancha/features/auth/usuarios_locales.dart';
import 'package:turnos_cancha/features/auth/validacion_registro.dart';

void main() {
  setUp(() => resetUsuarios());

  group('validacion_registro (RD registro RF-03)', () {
    test('validar_registro_todo_vacio_muestra_4_errores_a_la_vez', () {
      final ErroresRegistro e = validarRegistro(
        nombre: '   ',
        email: '',
        password: '',
        repetir: '',
        terminos: false,
      );
      expect(e.nombre, 'Ingresá tu nombre');
      expect(e.email, 'Ingresá un email válido');
      expect(e.password, 'Mínimo 8 caracteres');
      expect(e.repetir, isNull, reason: '"" == "" coincide: sin error (RF-03)');
      expect(e.terminos, 'Aceptá los términos y condiciones');
      expect(e.hayError, isTrue);
    });

    test('validar_registro_password_7_falla_8_pasa', () {
      final ErroresRegistro corta = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'marta@test.com',
        password: '1234567',
        repetir: '1234567',
        terminos: true,
      );
      expect(corta.password, 'Mínimo 8 caracteres');

      final ErroresRegistro justa = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'marta@test.com',
        password: '12345678',
        repetir: '12345678',
        terminos: true,
      );
      expect(justa.password, isNull);
    });

    test('validar_registro_email_formato', () {
      final ErroresRegistro sinDominio = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'a@b',
        password: 'qwerty1234',
        repetir: 'qwerty1234',
        terminos: true,
      );
      expect(sinDominio.email, 'Ingresá un email válido');

      final ErroresRegistro conEspacio = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'a b@c.com',
        password: 'qwerty1234',
        repetir: 'qwerty1234',
        terminos: true,
      );
      expect(conEspacio.email, 'Ingresá un email válido');

      final ErroresRegistro valido = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'a@bc.com',
        password: 'qwerty1234',
        repetir: 'qwerty1234',
        terminos: true,
      );
      expect(valido.email, isNull);
    });

    test('validar_registro_email_duplicado_con_usuario_semilla', () {
      final ErroresRegistro e = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'IGPI7UU@gmail.com',
        password: 'qwerty1234',
        repetir: 'qwerty1234',
        terminos: true,
      );
      expect(e.email, 'Ya hay una cuenta con ese email');
    });

    test('validar_registro_email_duplicado_con_usuario_registrado', () {
      registrarUsuario('Marta Gómez', 'marta@test.com', 'qwerty1234');

      final ErroresRegistro e = validarRegistro(
        nombre: 'Otra Persona',
        email: ' Marta@Test.com ',
        password: 'qwerty1234',
        repetir: 'qwerty1234',
        terminos: true,
      );
      expect(e.email, 'Ya hay una cuenta con ese email');
    });

    test('validar_registro_repetir_exacto_sin_trim', () {
      final ErroresRegistro conEspacio = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'marta@test.com',
        password: 'Abcdefg8',
        repetir: ' Abcdefg8',
        terminos: true,
      );
      expect(conEspacio.repetir, 'Las contraseñas no coinciden');

      final ErroresRegistro exacto = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'marta@test.com',
        password: 'Abcdefg8',
        repetir: 'Abcdefg8',
        terminos: true,
      );
      expect(exacto.repetir, isNull);
    });

    test('validar_registro_formulario_valido_sin_errores', () {
      final ErroresRegistro e = validarRegistro(
        nombre: 'Marta Gómez',
        email: 'marta@test.com',
        password: 'qwerty1234',
        repetir: 'qwerty1234',
        terminos: true,
      );
      expect(e.nombre, isNull);
      expect(e.email, isNull);
      expect(e.password, isNull);
      expect(e.repetir, isNull);
      expect(e.terminos, isNull);
      expect(e.hayError, isFalse);
    });
  });
}
