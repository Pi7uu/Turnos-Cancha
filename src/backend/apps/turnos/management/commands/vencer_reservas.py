"""Marca como VENCIDA las reservas pendientes que pasaron su plazo."""
from django.core.management.base import BaseCommand

from apps.turnos.services import vencer_reservas_pendientes


class Command(BaseCommand):
    help = "Vence reservas PENDIENTE que no se confirmaron 24 h antes del turno."

    def handle(self, *args, **options):
        total = vencer_reservas_pendientes()
        self.stdout.write(self.style.SUCCESS(f"{total} reserva(s) vencida(s)."))
