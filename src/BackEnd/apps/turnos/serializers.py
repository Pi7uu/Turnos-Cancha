"""Serializers de la API — TurnosCancha."""

from django.contrib.auth import get_user_model
from rest_framework import serializers

Usuario = get_user_model()


class UsuarioSerializer(serializers.ModelSerializer):
    """Usuario público ( jamás expone la contraseña — RD api-auth §4 )."""

    nombre = serializers.CharField(source="first_name", default="")

    class Meta:
        model = Usuario
        fields = ["id", "email", "nombre"]
