"""URLs del proyecto — TurnosCancha. Solo /admin/ y /api/."""
from django.contrib import admin
from django.urls import path

urlpatterns = [
    path("admin/", admin.site.urls),
]
