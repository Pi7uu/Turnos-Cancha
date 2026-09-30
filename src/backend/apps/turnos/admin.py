from django.contrib import admin

from .models import Cancha, Configuracion, Reserva, Usuario


@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = ["email", "first_name", "last_name", "rol", "is_active"]
    list_filter = ["rol", "is_active"]
    search_fields = ["email", "first_name", "last_name"]


@admin.register(Cancha)
class CanchaAdmin(admin.ModelAdmin):
    list_display = ["nombre", "activa"]


@admin.register(Reserva)
class ReservaAdmin(admin.ModelAdmin):
    list_display = [
        "fecha", "hora_inicio", "hora_fin", "tipo", "estado", "usuario", "creada_en",
    ]
    list_filter = ["estado", "tipo", "fecha"]
    search_fields = ["usuario__email"]
    filter_horizontal = ["canchas"]


@admin.register(Configuracion)
class ConfiguracionAdmin(admin.ModelAdmin):
    list_display = [
        "horario_inicio", "horario_fin", "duracion_turno_min",
        "plazo_vencimiento_h", "plazo_cancelacion_h", "anticipacion_max_dias",
    ]
