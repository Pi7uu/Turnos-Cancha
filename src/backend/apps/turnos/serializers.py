"""Serializers de la API — TurnosCancha."""
from django.contrib.auth import password_validation
from rest_framework import serializers

from .models import Cancha, Configuracion, Reserva, Usuario


class UsuarioSerializer(serializers.ModelSerializer):
    es_admin = serializers.BooleanField(read_only=True)

    class Meta:
        model = Usuario
        fields = ["id", "username", "email", "first_name", "last_name", "telefono", "rol", "es_admin"]
        read_only_fields = ["id", "username", "rol"]


class RegistroSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = Usuario
        fields = ["email", "password", "first_name", "last_name", "telefono"]

    def validate_password(self, value):
        password_validation.validate_password(value)
        return value

    def create(self, validated_data):
        email = validated_data.pop("email").lower()
        password = validated_data.pop("password")
        return Usuario.objects.create_user(
            username=email,
            email=email,
            password=password,
            rol=Usuario.Rol.CLIENTE,
            **validated_data,
        )


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class ReservaSerializer(serializers.ModelSerializer):
    canchas = serializers.SlugRelatedField(
        slug_field="nombre", many=True, read_only=True
    )
    cliente_email = serializers.EmailField(source="usuario.email", read_only=True)
    cliente_nombre = serializers.SerializerMethodField()
    cliente_puede_cancelar = serializers.BooleanField(read_only=True)

    class Meta:
        model = Reserva
        fields = [
            "id", "usuario", "cliente_email", "cliente_nombre", "tipo", "fecha",
            "hora_inicio", "hora_fin", "estado", "canchas", "creada_en",
            "confirmada_en", "cancelada_en", "cancelada_por", "cliente_puede_cancelar",
        ]
        read_only_fields = fields

    def get_cliente_nombre(self, obj) -> str:
        return obj.usuario.get_full_name() or obj.usuario.email


class ReservaCreateSerializer(serializers.Serializer):
    tipo = serializers.ChoiceField(choices=Reserva.Tipo.choices)
    fecha = serializers.DateField()
    hora_inicio = serializers.TimeField(format="%H:%M", input_formats=["%H:%M", "%H:%M:%S"])
    cancha = serializers.ChoiceField(
        choices=Cancha.Nombre.choices, required=False, allow_null=True
    )

    def validate(self, attrs):
        if attrs["tipo"] == Reserva.Tipo.F5 and not attrs.get("cancha"):
            raise serializers.ValidationError(
                {"cancha": "Para F5 indicá la cancha F5-A o F5-B."}
            )
        return attrs


class ReservaManualSerializer(ReservaCreateSerializer):
    """Reserva manual del admin: además define el cliente y puede confirmarla al toque."""

    cliente_email = serializers.EmailField()
    confirmada = serializers.BooleanField(default=True, required=False)


class ConfiguracionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Configuracion
        fields = [
            "horario_inicio", "horario_fin", "duracion_turno_min",
            "plazo_vencimiento_h", "plazo_cancelacion_h", "anticipacion_max_dias",
        ]
