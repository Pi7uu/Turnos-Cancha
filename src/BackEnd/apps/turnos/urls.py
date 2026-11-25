"""Rutas de la API de autenticación — `/api/auth/`."""

from django.urls import path

from . import api

urlpatterns = [
    path("registro/", api.registro, name="api-auth-registro"),
    path("login/", api.login_api, name="api-auth-login"),
    path("logout/", api.logout_api, name="api-auth-logout"),
    path("perfil/", api.perfil, name="api-auth-perfil"),
]
