from django.urls import path

from . import api

app_name = "turnos"

urlpatterns = [
    # Auth
    path("auth/registro/", api.registro, name="registro"),
    path("auth/login/", api.login_view, name="login"),
    path("auth/logout/", api.logout_view, name="logout"),
    path("auth/me/", api.yo, name="yo"),
    # Disponibilidad y reservas (cliente)
    path("disponibilidad/", api.disponibilidad_view, name="disponibilidad"),
    path("reservas/", api.crear_reserva_view, name="crear_reserva"),
    path("reservas/mias/", api.mis_reservas, name="mis_reservas"),
    path("reservas/<int:pk>/confirmar/", api.confirmar_reserva_view, name="confirmar"),
    path("reservas/<int:pk>/cancelar/", api.cancelar_reserva_view, name="cancelar"),
    # Admin
    path("admin/agenda/", api.agenda_view, name="agenda"),
    path("admin/reservas/", api.reserva_manual, name="reserva_manual"),
    path("admin/clientes/", api.clientes, name="clientes"),
    path("admin/clientes/<int:pk>/reservas/", api.reservas_de_cliente, name="reservas_de_cliente"),
    path("admin/configuracion/", api.configuracion, name="configuracion"),
]
