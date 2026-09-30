import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navegación inferior según rol (cliente / admin).
class AppNav extends StatelessWidget {
  const AppNav({super.key, required this.rutaActual, required this.esAdmin});

  final String rutaActual;
  final bool esAdmin;

  @override
  Widget build(BuildContext context) {
    final items = esAdmin
        ? const [
            _NavItem(ruta: '/', icon: Icons.event_note, label: 'Agenda'),
            _NavItem(ruta: '/admin/manual', icon: Icons.add_circle_outline, label: 'Reservar'),
            _NavItem(ruta: '/admin/clientes', icon: Icons.people_outline, label: 'Clientes'),
          ]
        : const [
            _NavItem(ruta: '/', icon: Icons.calendar_month, label: 'Disponibilidad'),
            _NavItem(ruta: '/mis-reservas', icon: Icons.event_available, label: 'Mis reservas'),
          ];

    var indice = items.indexWhere((i) => i.ruta == rutaActual);
    if (indice < 0) indice = 0;

    return NavigationBar(
      selectedIndex: indice,
      onDestinationSelected: (i) => context.go(items[i].ruta),
      destinations: [
        for (final item in items)
          NavigationDestination(icon: Icon(item.icon), label: item.label),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({required this.ruta, required this.icon, required this.label});

  final String ruta;
  final IconData icon;
  final String label;
}
