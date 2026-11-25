"""Tests de la API de autenticación ( RD `docs/HistRequerimientos/api-auth.md` §4 )."""

from django.contrib.auth import get_user_model
from rest_framework import status
from rest_framework.test import APITestCase

Usuario = get_user_model()


class AuthApiTests(APITestCase):
    """Endpoints /api/auth/ — sesión Django, mensajes en español."""

    def setUp(self):
        self.usuario = Usuario.objects.create_user(
            email="igpi7uu@gmail.com", password="igpi7uu", first_name="Pitu"
        )

    # --- login ---------------------------------------------------------
    def test_login_ok_devuelve_usuario_y_sesion(self):
        r = self.client.post(
            "/api/auth/login/",
            {"email": "igpi7uu@gmail.com", "password": "igpi7uu"},
        )
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        self.assertEqual(r.data["email"], "igpi7uu@gmail.com")
        self.assertEqual(r.data["nombre"], "Pitu")
        self.assertNotIn("password", r.data)
        self.assertIn("_auth_user_id", self.client.session)

    def test_login_invalido_401_mensaje_es(self):
        r = self.client.post(
            "/api/auth/login/", {"email": "igpi7uu@gmail.com", "password": "mala"}
        )
        self.assertEqual(r.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(r.data["error"], "Email o contraseña incorrectos.")

    def test_login_normaliza_email(self):
        """Mayúsculas y espacios no impiden entrar ( mismo criterio que el
        login local — RD api-auth §8 )."""
        r = self.client.post(
            "/api/auth/login/", {"email": "  IGPI7UU@GMAIL.COM ", "password": "igpi7uu"}
        )
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        self.assertEqual(r.data["email"], "igpi7uu@gmail.com")

    # --- registro ------------------------------------------------------
    def test_registro_ok_crea_hash_y_sesion(self):
        r = self.client.post(
            "/api/auth/registro/",
            {"email": "nueva@gmail.com", "password": "secreta123", "nombre": "Ana"},
        )
        self.assertEqual(r.status_code, status.HTTP_201_CREATED)
        self.assertEqual(r.data["email"], "nueva@gmail.com")
        self.assertEqual(r.data["nombre"], "Ana")
        self.assertNotIn("password", r.data)
        u = Usuario.objects.get(email="nueva@gmail.com")
        self.assertNotEqual(u.password, "secreta123")  # hash, no texto plano
        self.assertTrue(u.check_password("secreta123"))
        self.assertIn("_auth_user_id", self.client.session)

    def test_registro_sin_nombre_usa_email(self):
        r = self.client.post(
            "/api/auth/registro/", {"email": "sin@nombre.com", "password": "clave123"}
        )
        self.assertEqual(r.status_code, status.HTTP_201_CREATED)
        self.assertEqual(r.data["nombre"], "sin")

    def test_registro_email_repetido_400(self):
        r = self.client.post(
            "/api/auth/registro/",
            {"email": "igpi7uu@gmail.com", "password": "otra1234"},
        )
        self.assertEqual(r.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(r.data["error"], "Ya existe una cuenta con ese email.")

    # --- perfil --------------------------------------------------------
    def test_perfil_con_sesion_200(self):
        self.client.login(email="igpi7uu@gmail.com", password="igpi7uu")
        r = self.client.get("/api/auth/perfil/")
        self.assertEqual(r.status_code, status.HTTP_200_OK)
        self.assertEqual(r.data["email"], "igpi7uu@gmail.com")

    def test_perfil_sin_sesion_401(self):
        r = self.client.get("/api/auth/perfil/")
        self.assertEqual(r.status_code, status.HTTP_401_UNAUTHORIZED)

    # --- logout --------------------------------------------------------
    def test_logout_cierra_sesion_204(self):
        self.client.login(email="igpi7uu@gmail.com", password="igpi7uu")
        r = self.client.post("/api/auth/logout/")
        self.assertEqual(r.status_code, status.HTTP_204_NO_CONTENT)
        self.assertNotIn("_auth_user_id", self.client.session)

    def test_logout_sin_sesion_401(self):
        r = self.client.post("/api/auth/logout/")
        self.assertEqual(r.status_code, status.HTTP_401_UNAUTHORIZED)
