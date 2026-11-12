import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_colors.dart';

/// Tabs del Tab Bar (RD `docs/requerimientos/navegacion.md` §4).
///
/// El orden es el del mockup: Inicio, Mis reservas, Favoritos, Perfil.
enum TabApp { inicio, misReservas, favoritos, perfil }

/// Tab Bar del mockup: píldora flotante de 375×56 con 4 tabs
/// ( ícono lucide 21px + label 10px ) en estados activo/inactivo.
///
/// Widget puramente presentacional (RD RF-01): muestra el tab activo y
/// notifica la selección; la navegación la resuelve [MainShell].
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.activo, required this.onTab});

  /// Tab marcado como activo (por defecto lo decide quien lo usa).
  final TabApp activo;

  /// Se invoca al tocar cualquier tab, activo o no.
  final ValueChanged<TabApp> onTab;

  static const List<(TabApp, String, IconData)> _tabs = [
    (TabApp.inicio, 'Inicio', LucideIcons.home),
    (TabApp.misReservas, 'Mis reservas', LucideIcons.calendarCheck),
    (TabApp.favoritos, 'Favoritos', LucideIcons.heart),
    (TabApp.perfil, 'Perfil', LucideIcons.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // Píldora del mockup: blanco al 90%, radio 28, sombra suave.
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: const BoxDecoration(
        color: Color(0xE6FFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A0F172A),
            offset: Offset(0, 6),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final (tab, label, icon) in _tabs)
            Flexible(
              child: _TabItem(
                key: ValueKey('tab-${tab.name}'),
                label: label,
                icon: icon,
                activo: tab == activo,
                onTap: () => onTab(tab),
              ),
            ),
        ],
      ),
    );
  }
}

/// Un tab: columna con ícono arriba y label abajo.
class _TabItem extends StatelessWidget {
  const _TabItem({
    super.key,
    required this.label,
    required this.icon,
    required this.activo,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Colores según el estado (RD §4): activo primary sobre primarySoft,
    // inactivo text2 sin fondo.
    final color = activo ? AppColors.primary : AppColors.text2;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
        decoration: BoxDecoration(
          color: activo ? AppColors.primarySoft : null,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.0,
                fontWeight: activo ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
