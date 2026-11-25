"""API de autenticación ( RD `docs/HistRequerimientos/api-auth.md` §4 ).

Endpoints bajo `/api/auth/` con sesión Django sin CSRF ( `SessionSinCSRF` ).
Todos los mensajes de error en español; jamás se devuelve la contraseña.
"""

from django.contrib.auth import authenticate, get_user_model, login, logout
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    authentication_classes,
    permission_classes,
)
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from .auth import SessionSinCSRF
from .serializers import UsuarioSerializer

Usuario = get_user_model()


@api_view(["POST"])
@authentication_classes([SessionSinCSRF])
@permission_classes([AllowAny])
def registro(request):
    """Crea el usuario ( hash de contraseña ) y deja la sesión iniciada."""
    email = (request.data.get("email") or "").strip()
    password = request.data.get("password") or ""
    if not email or not password:
        return Response(
            {"error": "Faltan el email o la contraseña."},
            status=status.HTTP_400_BAD_REQUEST,
        )
    if Usuario.objects.filter(email=email).exists():
        return Response(
            {"error": "Ya existe una cuenta con ese email."},
            status=status.HTTP_400_BAD_REQUEST,
        )
    nombre = (request.data.get("nombre") or "").strip() or email.split("@")[0]
    user = Usuario.objects.create_user(email=email, password=password)
    user.first_name = nombre
    user.save(update_fields=["first_name"])
    login(request, user)
    return Response(UsuarioSerializer(user).data, status=status.HTTP_201_CREATED)


@api_view(["POST"])
@authentication_classes([SessionSinCSRF])
@permission_classes([AllowAny])
def login_api(request):
    """Valida credenciales e inicia la sesión. No revela si el email existe."""
    email = (request.data.get("email") or "").strip()
    password = request.data.get("password") or ""
    user = authenticate(request, email=email, password=password)
    if user is None:
        return Response(
            {"error": "Email o contraseña incorrectos."},
            status=status.HTTP_401_UNAUTHORIZED,
        )
    login(request, user)
    return Response(UsuarioSerializer(user).data, status=status.HTTP_200_OK)


@api_view(["POST"])
@authentication_classes([SessionSinCSRF])
@permission_classes([AllowAny])
def logout_api(request):
    """Cierra la sesión ( `401` si no había )."""
    if not request.user.is_authenticated:
        return Response(status=status.HTTP_401_UNAUTHORIZED)
    logout(request)
    return Response(status=status.HTTP_204_NO_CONTENT)


@api_view(["GET"])
@authentication_classes([SessionSinCSRF])
@permission_classes([AllowAny])
def perfil(request):
    """Usuario logueado ( `401` si no hay sesión )."""
    if not request.user.is_authenticated:
        return Response(status=status.HTTP_401_UNAUTHORIZED)
    return Response(UsuarioSerializer(request.user).data, status=status.HTTP_200_OK)
