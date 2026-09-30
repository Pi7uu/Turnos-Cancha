"""Modelos de dominio — TurnosCancha."""
from django.contrib.auth.models import AbstractUser
from django.core.exceptions import ValidationError
from django.db import models
from django.utils import timezone


class Usuario(AbstractUser):
    """Usuario de la app. Login con email y contraseña (ver auth.py)."""

    class Rol(models.TextChoices):
        CLIENTE = "CLIENTE", "Cliente"
        ADMIN = "ADMIN", "Administrador"

    email = models.EmailField("Email", unique=True)
    telefono = models.CharField("Teléfono", max_length=30, blank=True)
    rol = models.CharField(
        "Rol", max_length=10, choices=Rol.choices, default=Rol.CLIENTE
    )

    REQUIRED_FIELDS = ["email"]

    @property
    def es_admin(self) -> bool:
        return self.rol == self.Rol.ADMIN or self.is_superuser

    def __str__(self) -> str:
        return self.email


class Cancha(models.Model):
    """Cancha física. La cancha F7 se divide en dos mitades F5 (A y B)."""

    class Nombre(models.TextChoices):
        F5_A = "F5-A", "Fútbol 5 - A"
        F5_B = "F5-B", "Fútbol 5 - B"

    nombre = models.CharField("Nombre", max_length=10, choices=Nombre.choices, unique=True)
    activa = models.BooleanField("Activa", default=True)

    class Meta:
        ordering = ["nombre"]

    def __str__(self) -> str:
        return self.get_nombre_display()


class Reserva(models.Model):
    """Reserva de turno. Ocupa canchas físicas: F5 → 1 cancha, F7 → 2 canchas."""

    class Tipo(models.TextChoices):
        F5 = "F5", "Fútbol 5"
        F7 = "F7", "Fútbol 7"

    class Estado(models.TextChoices):
        PENDIENTE = "PENDIENTE", "Pendiente"
        CONFIRMADA = "CONFIRMADA", "Confirmada"
        VENCIDA = "VENCIDA", "Vencida"
        CANCELADA = "CANCELADA", "Cancelada"

    ESTADOS_QUE_OCUPAN = (Estado.PENDIENTE, Estado.CONFIRMADA)

    usuario = models.ForeignKey(
        Usuario, on_delete=models.CASCADE, related_name="reservas"
    )
    tipo = models.CharField("Tipo", max_length=2, choices=Tipo.choices)
    fecha = models.DateField("Fecha")
    hora_inicio = models.TimeField("Hora inicio")
    hora_fin = models.TimeField("Hora fin")
    estado = models.CharField(
        "Estado",
        max_length=12,
        choices=Estado.choices,
        default=Estado.PENDIENTE,
    )
    canchas = models.ManyToManyField(Cancha, related_name="reservas", verbose_name="Canchas")
    creada_en = models.DateTimeField("Creada en", auto_now_add=True)
    confirmada_en = models.DateTimeField("Confirmada en", null=True, blank=True)
    cancelada_en = models.DateTimeField("Cancelada en", null=True, blank=True)
    cancelada_por = models.ForeignKey(
        Usuario,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="reservas_canceladas",
        verbose_name="Cancelada por",
    )

    class Meta:
        ordering = ["fecha", "hora_inicio"]

    def __str__(self) -> str:
        return f"{self.get_tipo_display()} {self.fecha} {self.hora_inicio:%H:%M}"

    @property
    def plazo_limite(self):
        """Momento límite para confirmar/cancelar (24 h antes del turno)."""
        inicio = timezone.make_aware(
            timezone.datetime.combine(self.fecha, self.hora_inicio)
        )
        horas = Configuracion.get_solo().plazo_cancelacion_h
        return inicio - timezone.timedelta(hours=horas)

    @property
    def cliente_puede_cancelar(self) -> bool:
        return timezone.now() < self.plazo_limite


class Configuracion(models.Model):
    """Configuración del sistema (singleton). Horarios, duración y plazos."""

    horario_inicio = models.TimeField("Horario inicio", default="09:00")
    horario_fin = models.TimeField("Horario fin", default="23:00")
    duracion_turno_min = models.PositiveIntegerField("Duración del turno (min)", default=60)
    plazo_vencimiento_h = models.PositiveIntegerField(
        "Plazo de vencimiento (h antes del turno)", default=24
    )
    plazo_cancelacion_h = models.PositiveIntegerField(
        "Plazo de cancelación libre (h antes del turno)", default=24
    )
    anticipacion_max_dias = models.PositiveIntegerField(
        "Anticipación máxima para reservar (días)", default=30
    )

    class Meta:
        verbose_name = "Configuración"
        verbose_name_plural = "Configuraciones"

    def __str__(self) -> str:
        return f"Config #{self.pk}"

    @classmethod
    def get_solo(cls) -> "Configuracion":
        obj, _ = cls.objects.get_or_create(pk=1)
        return obj
