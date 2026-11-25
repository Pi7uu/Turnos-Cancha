import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../inicio/inicio_screen.dart';
import 'tab_bar.dart';

/// Shell de navegación de la app (RD `docs/HistRequerimientos/navegacion.md`
/// RF-02/03): muestra la pantalla del tab activo en un [IndexedStack] con
/// las 4 pantallas precargadas y el [AppTabBar] en la zona inferior del
/// mockup.
///
/// Por esta etapa las 4 pantallas son placeholders vacíos ( RF-03 ); su
/// contenido llega en RDs propios ( inicio-*.md, mis-reservas-*.md, etc. ).
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.tabInicial = TabApp.inicio});

  /// Tab activo al entrar ( RD reserva-exitosa §8: `Ver mis reservas` abre
  /// el shell con este tab activo ).
  final TabApp tabInicial;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  TabApp _activo = TabApp.inicio;

  @override
  void initState() {
    super.initState();
    _activo = widget.tabInicial;
  }

  void _seleccionar(TabApp tab) => setState(() => _activo = tab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // Precargadas y sin rebuild al cambiar de tab (RD RF-02). El tab
      // Inicio muestra su pantalla real (header); los otros 3 siguen como
      // placeholders hasta sus RDs.
      body: IndexedStack(
        index: _activo.index,
        children: const [
          InicioScreen(key: ValueKey('placeholder-inicio')),
          _Placeholder(key: ValueKey('placeholder-mis-reservas')),
          _Placeholder(key: ValueKey('placeholder-favoritos')),
          _Placeholder(key: ValueKey('placeholder-perfil')),
        ],
      ),
      // Zona del mockup (§4): fondo transparente sobre $bg, bordes a 16px
      // laterales y 12px inferior.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: AppTabBar(activo: _activo, onTab: _seleccionar),
        ),
      ),
    );
  }
}

/// Pantalla placeholder: fondo `$bg`, sin contenido (RF-03). El `key`
/// identifica cada tab en los tests hasta que llegue la pantalla real.
class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: SizedBox.expand()),
    );
  }
}
