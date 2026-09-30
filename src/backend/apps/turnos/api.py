"""Endpoints REST de la app turnos (prefijo /api/)."""
from datetime import datetime

from django.contrib.auth import login, logout
from django.shortcuts import get_object_or_404
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    authentication_classes,
    permission_classes,
)
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from .auth import autenticar_por_email
from .models import Configuracion, Reserva, Usuario
from .serializers import (
    ConfiguracionSerializer,
    LoginSerializer,
    RegistroSerializer,
    ReservaCreateSerializer,
    ReservaManualSerializer,
    ReservaSerializer,
    UsuarioSerializer,
)
from .services import (
    ErrorDeReserva,
    agenda,
    cancelar_reserva,
    confirmar_reserva,
    crear_reserva,
    disponibilidad,
)


class SoloAdmin(IsAuthenticated):
    """Solo usuarios con rol ADMIN (o superusuario)."""

    def has_permission(self, request, view):
        return super().has_permission(request, view) and bool(
            request.user and request.user.es_admin
        )


def _error(e: ErrorDeReserva) -> Response:
    return Response({"detalle": e.mensaje}, status=e.status)


def _parse_fecha(query):
    valor = query.get("fecha")
    if not valor:
        return None
    try:
        return datetime.strptime(valor, "%Y-%m-%d").date()
    except ValueError:
        return None


# ---------------------------------------------------------------- auth


@api_view(["POST"])
@authentication_classes([])
@permission_classes([AllowAny])
def registro(request):
    ser = RegistroSerializer(data=request.data)
    ser.is_valid(raise_exception=True)
    usuario = ser.save()
    login(request, usuario)
    return Response(UsuarioSerializer(usuario).data, status=status.HTTP_201_CREATED)


@api_view(["POST"])
@authentication_classes([])
@permission_classes([AllowAny])
def login_view(request):
    ser = LoginSerializer(data=request.data)
    ser.is_valid(raise_exception=True)
    usuario = autenticar_por_email(
        ser.validated_data["email"], ser.validated_data["password"]
    )
    if usuario is None:
        return Response(
            {"detalle": "Email o contraseña incorrectos."},
            status=status.HTTP_400_BAD_REQUEST,
        )
    login(request, usuario)
    return Response(UsuarioSerializer(usuario).data)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def logout_view(request):
    logout(request)
    return Response({"detalle": "Sesión cerrada."})


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def yo(request):
    return Response(UsuarioSerializer(request.user).data)


# ---------------------------------------------------------------- disponibilidad


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def disponibilidad_view(request):
    fecha = _parse_fecha(request.query_params)
    if fecha is None:
        return Response(
            {"detalle": "Parámetro fecha inválido (usar YYYY-MM-DD)."},
            status=status.HTTP_400_BAD_REQUEST,
        )
    return Response(disponibilidad(fecha))


# ---------------------------------------------------------------- reservas (cliente)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def crear_reserva_view(request):
    ser = ReservaCreateSerializer(data=request.data)
    ser.is_valid(raise_exception=True)
    try:
        reserva = crear_reserva(
            usuario=request.user,
            tipo=ser.validated_data["tipo"],
            fecha=ser.validated_data["fecha"],
            hora_inicio=ser.validated_data["hora_inicio"],
            cancha=ser.validated_data.get("cancha"),
        )
    except ErrorDeReserva as e:
        return _error(e)
    return Response(ReservaSerializer(reserva).data, status=status.HTTP_201_CREATED)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def mis_reservas(request):
    qs = (
        Reserva.objects.filter(usuario=request.user)
        .select_related("usuario")
        .prefetch_related("canchas")
    )
    return Response(ReservaSerializer(qs, many=True).data)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def confirmar_reserva_view(request, pk):
    reserva = get_object_or_404(
        Reserva.objects.select_related("usuario"), pk=pk, usuario=request.user
    )
    try:
        reserva = confirmar_reserva(reserva)
    except ErrorDeReserva as e:
        return _error(e)
    return Response(ReservaSerializer(reserva).data)


@api_view(["POST"])
@permission_classes([IsAuthenticated])
def cancelar_reserva_view(request, pk):
    reserva = get_object_or_404(Reserva.objects.select_related("usuario"), pk=pk)
    if not request.user.es_admin and reserva.usuario_id != request.user.pk:
        return Response(
            {"detalle": "No podés cancelar una reserva de otro usuario."},
            status=status.HTTP_403_FORBIDDEN,
        )
    try:
        reserva = cancelar_reserva(reserva, por=request.user)
    except ErrorDeReserva as e:
        return _error(e)
    return Response(ReservaSerializer(reserva).data)


# ---------------------------------------------------------------- admin


@api_view(["GET"])
@permission_classes([SoloAdmin])
def agenda_view(request):
    fecha = _parse_fecha(request.query_params)
    if fecha is None:
        return Response(
            {"detalle": "Parámetro fecha inválido (usar YYYY-MM-DD)."},
            status=status.HTTP_400_BAD_REQUEST,
        )
    cancha = request.query_params.get("cancha") or None
    return Response({"fecha": fecha.isoformat(), "reservas": agenda(fecha, cancha)})


@api_view(["POST"])
@permission_classes([SoloAdmin])
def reserva_manual(request):
    ser = ReservaManualSerializer(data=request.data)
    ser.is_valid(raise_exception=True)
    email = ser.validated_data["cliente_email"].lower()
    cliente, _ = Usuario.objects.get_or_create(
        email=email,
        defaults={"username": email},
    )
    try:
        reserva = crear_reserva(
            usuario=cliente,
            tipo=ser.validated_data["tipo"],
            fecha=ser.validated_data["fecha"],
            hora_inicio=ser.validated_data["hora_inicio"],
            cancha=ser.validated_data.get("cancha"),
        )
        if ser.validated_data.get("confirmada", True):
            reserva = confirmar_reserva(reserva)
    except ErrorDeReserva as e:
        return _error(e)
    return Response(ReservaSerializer(reserva).data, status=status.HTTP_201_CREATED)


@api_view(["GET"])
@permission_classes([SoloAdmin])
def clientes(request):
    qs = Usuario.objects.filter(rol=Usuario.Rol.CLIENTE).order_by("email")
    return Response(UsuarioSerializer(qs, many=True).data)


@api_view(["GET"])
@permission_classes([SoloAdmin])
def reservas_de_cliente(request, pk):
    """Historial de reservas de un cliente (panel admin)."""
    cliente = get_object_or_404(Usuario, pk=pk)
    qs = (
        Reserva.objects.filter(usuario=cliente)
        .select_related("usuario")
        .prefetch_related("canchas")
    )
    return Response(ReservaSerializer(qs, many=True).data)


@api_view(["GET", "PUT"])
@permission_classes([SoloAdmin])
def configuracion(request):
    cfg = Configuracion.get_solo()
    if request.method == "PUT":
        ser = ConfiguracionSerializer(cfg, data=request.data, partial=True)
        ser.is_valid(raise_exception=True)
        ser.save()
        return Response(ser.data)
    return Response(ConfiguracionSerializer(cfg).data)
