"""Lógica de negocio — TurnosCancha.

Reglas centrales (ver turnos-futbol.md §3):
- F7 ocupa las 2 canchas físicas (F5-A y F5-B); F5 ocupa solo la mitad elegida.
- Superposición validada dentro de una transacción sobre las canchas físicas.
- Ciclo de vida: PENDIENTE → CONFIRMADA | VENCIDA | CANCELADA.
"""
from datetime import date, datetime, time, timedelta

from django.db import transaction
from django.utils import timezone

from .models import Cancha, Configuracion, Reserva, Usuario


class ErrorDeReserva(Exception):
    """Error de negocio traducido a HTTP 400/409 por la API."""

    def __init__(self, mensaje: str, status: int = 400):
        super().__init__(mensaje)
        self.mensaje = mensaje
        self.status = status


def canchas_para_tipo(tipo: str, cancha: str | None = None) -> list[Cancha]:
    """Resuelve las canchas físicas que ocupa una reserva del tipo dado."""
    activas = list(Cancha.objects.filter(activa=True))
    por_nombre = {c.nombre: c for c in activas}

    if tipo == Reserva.Tipo.F7:
        faltantes = [n for n in (Cancha.Nombre.F5_A, Cancha.Nombre.F5_B) if n not in por_nombre]
        if faltantes:
            raise ErrorDeReserva("Las canchas físicas no están configuradas.")
        return [por_nombre[Cancha.Nombre.F5_A], por_nombre[Cancha.Nombre.F5_B]]

    if tipo == Reserva.Tipo.F5:
        if cancha not in (Cancha.Nombre.F5_A, Cancha.Nombre.F5_B):
            raise ErrorDeReserva("Para F5 hay que indicar la cancha F5-A o F5-B.")
        if cancha not in por_nombre or not por_nombre[cancha].activa:
            raise ErrorDeReserva(f"La cancha {cancha} no está disponible.")
        return [por_nombre[cancha]]

    raise ErrorDeReserva("Tipo de cancha inválido (debe ser F5 o F7).")


def reservas_en_horario(
    canchas: list[Cancha],
    fecha: date,
    hora_inicio: time,
    hora_fin: time,
    excluir_pk: int | None = None,
):
    """Reservas activas (PENDIENTE/CONFIRMADA) que pisan las canchas en el horario."""
    if not canchas:
        return Reserva.objects.none()
    qs = (
        Reserva.objects.filter(
            estado__in=Reserva.ESTADOS_QUE_OCUPAN,
            fecha=fecha,
            hora_inicio__lt=hora_fin,
            hora_fin__gt=hora_inicio,
            canchas__in=canchas,
        )
        .distinct()
        .select_related("usuario")
    )
    if excluir_pk:
        qs = qs.exclude(pk=excluir_pk)
    return qs


def slots_del_dia(fecha: date) -> list[tuple[time, time]]:
    """Horarios de inicio del día según la configuración (duración fija)."""
    cfg = Configuracion.get_solo()
    duracion = timedelta(minutes=cfg.duracion_turno_min)
    actual = datetime.combine(fecha, cfg.horario_inicio)
    fin = datetime.combine(fecha, cfg.horario_fin)
    slots = []
    while actual + duracion <= fin:
        slots.append((actual.time(), (actual + duracion).time()))
        actual += duracion
    return slots


def vencer_reservas_pendientes(ahora=None) -> int:
    """Marca VENCIDA toda reserva PENDIENTE cuyo plazo ya venció. Devuelve cuántas."""
    ahora = ahora or timezone.now()
    cfg = Configuracion.get_solo()
    limite = ahora + timedelta(hours=cfg.plazo_vencimiento_h)
    pendientes = Reserva.objects.filter(estado=Reserva.Estado.PENDIENTE)
    a_vencer = [
        r.pk
        for r in pendientes
        if timezone.make_aware(datetime.combine(r.fecha, r.hora_inicio)) <= limite
    ]
    if a_vencer:
        pendientes.filter(pk__in=a_vencer).update(
            estado=Reserva.Estado.VENCIDA, cancelada_en=ahora
        )
    return len(a_vencer)


def disponibilidad(fecha: date) -> dict:
    """Disponibilidad del día: por slot, qué tipos de cancha están libres.

    Ejemplo de slot:
    {"hora_inicio": "10:00", "hora_fin": "11:00",
     "f5_a": true, "f5_b": true, "f7": false}
    """
    vencer_reservas_pendientes()
    canchas = {c.nombre: c for c in Cancha.objects.filter(activa=True)}
    slots = []
    for hora_inicio, hora_fin in slots_del_dia(fecha):
        ocupadas = set(
            reservas_en_horario(list(canchas.values()), fecha, hora_inicio, hora_fin)
            .values_list("canchas__pk", flat=True)
        )

        def libre(nombre: str) -> bool:
            c = canchas.get(nombre)
            return c is not None and c.pk not in ocupadas

        f5_a_ok = libre(Cancha.Nombre.F5_A)
        f5_b_ok = libre(Cancha.Nombre.F5_B)
        slots.append(
            {
                "hora_inicio": hora_inicio.strftime("%H:%M"),
                "hora_fin": hora_fin.strftime("%H:%M"),
                "f5_a": f5_a_ok,
                "f5_b": f5_b_ok,
                "f7": f5_a_ok and f5_b_ok,
            }
        )
    return {"fecha": fecha.isoformat(), "slots": slots}


def crear_reserva(
    usuario: Usuario,
    tipo: str,
    fecha: date,
    hora_inicio: time,
    cancha: str | None = None,
) -> Reserva:
    """Crea una reserva PENDIENTE validando superposición en transacción."""
    vencer_reservas_pendientes()

    if not usuario.es_admin:
        cfg = Configuracion.get_solo()
        if fecha > timezone.now().date() + timedelta(days=cfg.anticipacion_max_dias):
            raise ErrorDeReserva(
                f"No se puede reservar con más de {cfg.anticipacion_max_dias} días de anticipación."
            )
        if fecha < timezone.now().date():
            raise ErrorDeReserva("No se puede reservar en el pasado.")

    duracion = timedelta(minutes=Configuracion.get_solo().duracion_turno_min)
    slot_valido = any(
        h == hora_inicio for h, _ in slots_del_dia(fecha)
    )
    if not slot_valido:
        raise ErrorDeReserva("El horario de inicio no corresponde a un turno válido.")

    hora_fin = (datetime.combine(fecha, hora_inicio) + duracion).time()
    ocupadas = canchas_para_tipo(tipo, cancha)

    with transaction.atomic():
        # Bloqueo las canchas físicas para serializar reservas concurrentes.
        list(Cancha.objects.select_for_update().filter(pk__in=[c.pk for c in ocupadas]))
        choques = reservas_en_horario(ocupadas, fecha, hora_inicio, hora_fin)
        if choques.exists():
            raise ErrorDeReserva("El horario ya no está disponible para esa cancha.", status=409)

        reserva = Reserva.objects.create(
            usuario=usuario,
            tipo=tipo,
            fecha=fecha,
            hora_inicio=hora_inicio,
            hora_fin=hora_fin,
            estado=Reserva.Estado.PENDIENTE,
        )
        reserva.canchas.set(ocupadas)
    return reserva


def confirmar_reserva(reserva: Reserva) -> Reserva:
    if reserva.estado == Reserva.Estado.CONFIRMADA:
        return reserva
    if reserva.estado != Reserva.Estado.PENDIENTE:
        raise ErrorDeReserva("Solo se pueden confirmar reservas pendientes.")
    vencer_reservas_pendientes()
    reserva.refresh_from_db()
    if reserva.estado == Reserva.Estado.VENCIDA:
        raise ErrorDeReserva("La reserva ya venció.", status=409)
    reserva.estado = Reserva.Estado.CONFIRMADA
    reserva.confirmada_en = timezone.now()
    reserva.save(update_fields=["estado", "confirmada_en"])
    return reserva


def cancelar_reserva(reserva: Reserva, por: Usuario) -> Reserva:
    if reserva.estado in (Reserva.Estado.CANCELADA, Reserva.Estado.VENCIDA):
        raise ErrorDeReserva("La reserva ya no está activa.")
    if not por.es_admin and reserva.usuario_id != por.pk:
        raise ErrorDeReserva("No podés cancelar una reserva de otro usuario.", status=403)
    if not por.es_admin and not reserva.cliente_puede_cancelar:
        raise ErrorDeReserva(
            "El plazo de cancelación libre venció (24 h antes del turno). "
            "Solo el administrador puede cancelar.",
            status=403,
        )
    reserva.estado = Reserva.Estado.CANCELADA
    reserva.cancelada_en = timezone.now()
    reserva.cancelada_por = por
    reserva.save(update_fields=["estado", "cancelada_en", "cancelada_por"])
    return reserva


def agenda(fecha: date, cancha: str | None = None) -> list[dict]:
    """Agenda del día para el admin: todas las reservas activas del día."""
    qs = Reserva.objects.filter(fecha=fecha).select_related("usuario").prefetch_related("canchas")
    if cancha:
        qs = qs.filter(canchas__nombre=cancha)
    return [
        {
            "id": r.pk,
            "hora_inicio": r.hora_inicio.strftime("%H:%M"),
            "hora_fin": r.hora_fin.strftime("%H:%M"),
            "tipo": r.tipo,
            "estado": r.estado,
            "cliente": r.usuario.email,
            "cliente_nombre": r.usuario.get_full_name() or r.usuario.email,
            "canchas": [c.nombre for c in r.canchas.all()],
        }
        for r in qs.distinct()
    ]
