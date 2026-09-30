"""Tests de TurnosCancha: reglas de superposición, ciclo de vida y API."""
from datetime import date, time, timedelta

from django.contrib.auth import get_user_model
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone

from .models import Cancha, Reserva
from .services import (
    ErrorDeReserva,
    cancelar_reserva,
    confirmar_reserva,
    crear_reserva,
    disponibilidad,
    vencer_reservas_pendientes,
)

Usuario = get_user_model()


def _futuro(dias=7, hora=time(20, 0)):
    return (timezone.now().date() + timedelta(days=dias), hora)


class BaseTurnosTest(TestCase):
    def setUp(self):
        self.cancha_a = Cancha.objects.create(nombre=Cancha.Nombre.F5_A)
        self.cancha_b = Cancha.objects.create(nombre=Cancha.Nombre.F5_B)
        self.cliente = Usuario.objects.create_user(
            username="cliente@test.com",
            email="cliente@test.com",
            password="secret123",
            rol=Usuario.Rol.CLIENTE,
        )
        self.admin = Usuario.objects.create_user(
            username="admin@test.com",
            email="admin@test.com",
            password="secret123",
            rol=Usuario.Rol.ADMIN,
        )


class SuperposicionTest(BaseTurnosTest):
    """Regla §3.1: F7 ocupa las 2 mitades; F5 solo su mitad."""

    def test_f7_ocupa_ambas_mitades(self):
        fecha, hora = _futuro()
        crear_reserva(self.cliente, "F7", fecha, hora)
        with self.assertRaises(ErrorDeReserva):
            crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-A")
        with self.assertRaises(ErrorDeReserva):
            crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-B")
        with self.assertRaises(ErrorDeReserva):
            crear_reserva(self.cliente, "F7", fecha, hora)

    def test_f5_ocupa_solo_su_mitad(self):
        fecha, hora = _futuro()
        crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-A")
        # F5-B sigue libre
        r2 = crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-B")
        self.assertEqual(r2.estado, Reserva.Estado.PENDIENTE)
        # F7 queda bloqueada
        with self.assertRaises(ErrorDeReserva):
            crear_reserva(self.cliente, "F7", fecha, hora)

    def test_f5_en_horario_distinto_no_molesta(self):
        fecha, hora = _futuro()
        crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-A")
        r2 = crear_reserva(self.cliente, "F7", fecha, time(21, 0))
        self.assertEqual(r2.estado, Reserva.Estado.PENDIENTE)

    def test_reservas_canceladas_liberan_horario(self):
        fecha, hora = _futuro()
        r1 = crear_reserva(self.cliente, "F7", fecha, hora)
        cancelar_reserva(r1, por=self.admin)
        r2 = crear_reserva(self.cliente, "F7", fecha, hora)
        self.assertEqual(r2.pk != r1.pk, True)


class CicloDeVidaTest(BaseTurnosTest):
    """Regla §3.3: PENDIENTE → CONFIRMADA / VENCIDA / CANCELADA."""

    def test_reserva_creada_como_pendiente(self):
        fecha, hora = _futuro()
        r = crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-A")
        self.assertEqual(r.estado, Reserva.Estado.PENDIENTE)
        self.assertIsNotNone(r.creada_en)

    def test_confirmar_reserva(self):
        fecha, hora = _futuro()
        r = crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-A")
        r = confirmar_reserva(r)
        self.assertEqual(r.estado, Reserva.Estado.CONFIRMADA)
        self.assertIsNotNone(r.confirmada_en)

    def test_cliente_cancela_antes_del_limite(self):
        fecha, hora = _futuro()
        r = crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-A")
        r = cancelar_reserva(r, por=self.cliente)
        self.assertEqual(r.estado, Reserva.Estado.CANCELADA)
        self.assertEqual(r.cancelada_por_id, self.cliente.pk)

    def test_cliente_no_cancela_despues_del_limite(self):
        # Hora local (hora de la cancha), no UTC
        ahora_local = timezone.localtime()
        # Reserva cuyo plazo libre venció (turno "mañana" a la hora actual: el
        # límite de 24 h era "hoy" a esta hora, ya pasó).
        r = Reserva.objects.create(
            usuario=self.cliente,
            tipo="F5",
            fecha=(ahora_local + timedelta(days=1)).date(),
            hora_inicio=ahora_local.time().replace(microsecond=0),
            hora_fin=(ahora_local + timedelta(hours=1)).time().replace(microsecond=0),
            estado=Reserva.Estado.CONFIRMADA,
        )
        r.canchas.add(self.cancha_a)
        self.assertFalse(r.cliente_puede_cancelar)
        with self.assertRaises(ErrorDeReserva):
            cancelar_reserva(r, por=self.cliente)
        # El admin sí puede cancelar después del límite
        r = cancelar_reserva(r, por=self.admin)
        self.assertEqual(r.estado, Reserva.Estado.CANCELADA)

    def test_admin_cancela_igual_despues_del_limite(self):
        # Reserva confirmada con el plazo de cancelación ya vencido
        r = Reserva.objects.create(
            usuario=self.cliente,
            tipo="F5",
            fecha=timezone.now().date() + timedelta(days=1),
            hora_inicio=time(12, 0),
            hora_fin=time(13, 0),
            estado=Reserva.Estado.CONFIRMADA,
        )
        r.canchas.add(self.cancha_a)
        # Trucamos plazo_limite vencido usando una fecha pasada en el property
        r.fecha = timezone.now().date() - timedelta(days=2)
        r.save()
        r = cancelar_reserva(r, por=self.admin)
        self.assertEqual(r.estado, Reserva.Estado.CANCELADA)

    def test_vencimiento_por_plazo(self):
        # Reserva pendiente creada "hace" más de 24 h sin confirmar
        ayer = timezone.now() - timedelta(hours=30)
        fecha = ayer.date()
        r = Reserva.objects.create(
            usuario=self.cliente,
            tipo="F5",
            fecha=fecha,
            hora_inicio=time(20, 0),
            hora_fin=time(21, 0),
            estado=Reserva.Estado.PENDIENTE,
        )
        r.canchas.add(self.cancha_a)
        total = vencer_reservas_pendientes()
        r.refresh_from_db()
        self.assertGreaterEqual(total, 1)
        self.assertEqual(r.estado, Reserva.Estado.VENCIDA)
        # El horario queda libre para una nueva reserva
        nueva = crear_reserva(self.admin, "F5", fecha, time(20, 0), cancha="F5-A")
        self.assertEqual(nueva.estado, Reserva.Estado.PENDIENTE)

    def test_no_confirmar_reserva_ajena(self):
        fecha, hora = _futuro()
        r = crear_reserva(self.cliente, "F5", fecha, hora, cancha="F5-A")
        with self.assertRaises(Reserva.DoesNotExist):
            Reserva.objects.get(pk=r.pk, usuario=self.admin)
        # El servicio de cancelación de otro usuario lanza error de permiso
        r2 = crear_reserva(self.cliente, "F5", fecha, time(21, 0), cancha="F5-A")
        with self.assertRaises(ErrorDeReserva):
            cancelar_reserva(r2, por=self.admin.__class__(
                username="otro", email="otro@test.com", rol=Usuario.Rol.CLIENTE
            ))


class DisponibilidadTest(BaseTurnosTest):
    def test_disponibilidad_del_dia(self):
        fecha = timezone.now().date() + timedelta(days=7)
        crear_reserva(self.cliente, "F5", fecha, time(20, 0), cancha="F5-A")
        data = disponibilidad(fecha)
        self.assertEqual(data["fecha"], fecha.isoformat())
        slot_20 = next(s for s in data["slots"] if s["hora_inicio"] == "20:00")
        self.assertFalse(slot_20["f5_a"])
        self.assertTrue(slot_20["f5_b"])
        self.assertFalse(slot_20["f7"])
        slot_19 = next(s for s in data["slots"] if s["hora_inicio"] == "19:00")
        self.assertTrue(slot_19["f7"])


class ApiTest(BaseTurnosTest):
    def test_registro_login_y_me(self):
        r = self.client.post(
            "/api/auth/registro/",
            {
                "email": "nuevo@test.com",
                "password": "clave-segura-1",
                "first_name": "Ana",
            },
            content_type="application/json",
        )
        self.assertEqual(r.status_code, 201, r.content)
        self.client.logout()
        r = self.client.post(
            "/api/auth/login/",
            {"email": "nuevo@test.com", "password": "clave-segura-1"},
            content_type="application/json",
        )
        self.assertEqual(r.status_code, 200, r.content)
        r = self.client.get("/api/auth/me/")
        self.assertEqual(r.json()["email"], "nuevo@test.com")

    def test_crear_reserva_y_confirmar(self):
        self.client.force_login(self.cliente)
        fecha, hora = _futuro()
        payload = {
            "tipo": "F5",
            "fecha": fecha.isoformat(),
            "hora_inicio": "20:00",
            "cancha": "F5-A",
        }
        r = self.client.post("/api/reservas/", payload, content_type="application/json")
        self.assertEqual(r.status_code, 201, r.content)
        pk = r.json()["id"]
        r = self.client.post(f"/api/reservas/{pk}/confirmar/", content_type="application/json")
        self.assertEqual(r.status_code, 200, r.content)
        self.assertEqual(r.json()["estado"], "CONFIRMADA")
        r = self.client.get("/api/reservas/mias/")
        self.assertEqual(len(r.json()), 1)

    def test_disponibilidad_requiere_login(self):
        fecha = timezone.now().date() + timedelta(days=1)
        r = self.client.get(f"/api/disponibilidad/?fecha={fecha.isoformat()}")
        self.assertEqual(r.status_code, 403)

    def test_admin_agenda(self):
        fecha, hora = _futuro()
        crear_reserva(self.cliente, "F7", fecha, hora)
        self.client.force_login(self.admin)
        r = self.client.get(f"/api/admin/agenda/?fecha={fecha.isoformat()}")
        self.assertEqual(r.status_code, 200)
        self.assertEqual(len(r.json()["reservas"]), 1)

    def test_cliente_no_accede_admin(self):
        self.client.force_login(self.cliente)
        fecha = timezone.now().date() + timedelta(days=1)
        r = self.client.get(f"/api/admin/agenda/?fecha={fecha.isoformat()}")
        self.assertEqual(r.status_code, 403)

    def test_reserva_manual_admin(self):
        self.client.force_login(self.admin)
        fecha, hora = _futuro()
        payload = {
            "tipo": "F5",
            "fecha": fecha.isoformat(),
            "hora_inicio": "22:00",
            "cancha": "F5-B",
            "cliente_email": "tel@test.com",
            "confirmada": True,
        }
        r = self.client.post(
            "/api/admin/reservas/", payload, content_type="application/json"
        )
        self.assertEqual(r.status_code, 201, r.content)
        self.assertEqual(r.json()["estado"], "CONFIRMADA")
