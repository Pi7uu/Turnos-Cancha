from rest_framework.authentication import SessionAuthentication


class SessionSinCSRF(SessionAuthentication):
    """Sesión sin verificación CSRF: la app móvil no participa del flujo CSRF."""

    def enforce_csrf(self, request):
        return
