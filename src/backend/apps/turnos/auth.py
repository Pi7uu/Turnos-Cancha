"""Autenticación para la API móvil (sin CSRF para clientes móviles)."""
from django.contrib.auth import authenticate, get_user_model
from rest_framework.authentication import SessionAuthentication

Usuario = get_user_model()


class SessionSinCSRF(SessionAuthentication):
    """Session auth sin token CSRF: los clientes móviles no llevan cookies de origin."""

    def enforce_csrf(self, request):
        return


def autenticar_por_email(email: str, password: str):
    """Login con email + contraseña (el username interno es el email)."""
    email = (email or "").strip().lower()
    try:
        user = Usuario.objects.get(email=email)
    except Usuario.DoesNotExist:
        return None
    return authenticate(username=user.username, password=password)
