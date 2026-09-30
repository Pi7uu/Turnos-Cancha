/// Utilidades de fecha (es-AR, sin dependencias externas).
const List<String> _diasSemana = [
  'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
];
const List<String> _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String hoyIso() {
  final d = DateTime.now();
  return toIso(d);
}

String toIso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime fromIso(String iso) {
  final p = iso.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

/// "lunes 23 de septiembre de 2026"
String fechaLarga(String iso) {
  final d = fromIso(iso);
  final nombreDia = _diasSemana[d.weekday - 1];
  return '$nombreDia ${d.day} de ${_meses[d.month - 1]} de ${d.year}';
}

/// "23/09/2026"
String fechaCorta(String iso) {
  final d = fromIso(iso);
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String sumarDias(String iso, int dias) => toIso(fromIso(iso).add(Duration(days: dias)));
