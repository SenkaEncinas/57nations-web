import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

/// Barra de navegación pública. Resalta la ruta activa, ancla el menú de
/// Servicios a su botón (MenuAnchor) y en mobile abre un panel lateral de
/// marca en vez de un bottom sheet genérico.
class NavBar extends StatelessWidget {
  const NavBar({super.key});

  static const _servicios = [
    ('Bots & Sistemas', AppRoutes.botsScreen, Icons.smart_toy_outlined),
    ('Apps Flutter', AppRoutes.flutterScreen, Icons.phone_android_outlined),
    ('Arduino & ESP32', AppRoutes.arduinoScreen, Icons.memory_outlined),
    ('Impresión 3D', AppRoutes.impresion3dScreen, Icons.view_in_ar_outlined),
    ('Entrenamiento', AppRoutes.entrenamientoScreen, Icons.sports_basketball_outlined),
  ];

  static bool _esRutaServicio(String? ruta) =>
      _servicios.any((s) => s.$2 == ruta);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final rutaActual = ModalRoute.of(context)?.settings.name;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LOGO
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false),
              child: Image.asset(
                'assets/logos/logo_57nations.png',
                height: 34,
                fit: BoxFit.contain,
              ),
            ),
          ),

          if (!isMobile)
            Row(
              children: [
                _NavItem(
                  label: 'Inicio',
                  activo: rutaActual == AppRoutes.home,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                ),
                _ServiciosMenu(activo: _esRutaServicio(rutaActual)),
                _NavItem(
                  label: 'Portfolio',
                  activo: rutaActual == AppRoutes.portfolio,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.portfolio),
                ),
                _NavItem(
                  label: 'Catálogo 3D',
                  activo: rutaActual == AppRoutes.catalogo3d,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.catalogo3d),
                ),
                _NavItem(
                  label: 'Sobre Nosotros',
                  activo: rutaActual == AppRoutes.sobreNosotros,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.sobreNosotros),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.contacto),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: const Text('CONTACTO'),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Menú',
              onPressed: () => _abrirMenuMobile(context, rutaActual),
            ),
        ],
      ),
    );
  }

  /// Panel lateral derecho con animación de slide — se siente app nativa,
  /// no bottom sheet genérico.
  void _abrirMenuMobile(BuildContext context, String? rutaActual) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar menú',
      barrierColor: AppColors.overlayDark,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.centerRight,
        child: _MobileMenuPanel(rutaActual: rutaActual),
      ),
      transitionBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        );
      },
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool activo;

  const _NavItem({
    required this.label,
    required this.onTap,
    this.activo = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final resaltado = _isHovered || widget.activo;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: resaltado ? AppColors.cianTech : AppColors.textLight,
                  fontWeight: widget.activo ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
                child: Text(widget.label),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2,
                width: resaltado ? 26 : 0,
                color: AppColors.cianTech,
                margin: const EdgeInsets.only(top: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menú de Servicios anclado a su propio botón (antes salía en la esquina
/// superior izquierda de la pantalla con showMenu(0,50)).
class _ServiciosMenu extends StatelessWidget {
  final bool activo;

  const _ServiciosMenu({required this.activo});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceElevated),
        shape: WidgetStatePropertyAll(
          AppTheme.cutCorner(side: const BorderSide(color: AppColors.border)),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 8)),
      ),
      menuChildren: NavBar._servicios
          .map(
            (s) => MenuItemButton(
              leadingIcon: Icon(s.$3, size: 18, color: AppColors.textMuted),
              style: MenuItemButton.styleFrom(
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () => Navigator.pushNamed(context, s.$2),
              child: Text(s.$1, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      builder: (context, controller, _) => _NavItem(
        label: 'Servicios ▾',
        activo: activo,
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

class _MobileMenuPanel extends StatelessWidget {
  final String? rutaActual;

  const _MobileMenuPanel({required this.rutaActual});

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('Inicio', AppRoutes.home),
      ('Portfolio', AppRoutes.portfolio),
      ('Catálogo 3D', AppRoutes.catalogo3d),
      ('Sobre Nosotros', AppRoutes.sobreNosotros),
    ];

    return Material(
      color: AppColors.surface,
      child: Container(
        width: 300,
        height: double.infinity,
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/logos/logo_57nations.png', height: 28),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    _MobileMenuItem(
                      label: 'Inicio',
                      activo: rutaActual == AppRoutes.home,
                      onTap: () => _ir(context, AppRoutes.home),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Text(
                        'SERVICIOS',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    ...NavBar._servicios.map(
                      (s) => _MobileMenuItem(
                        label: s.$1,
                        icon: s.$3,
                        activo: rutaActual == s.$2,
                        onTap: () => _ir(context, s.$2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, indent: 24, endIndent: 24),
                    const SizedBox(height: 8),
                    ...items.skip(1).map(
                          (i) => _MobileMenuItem(
                            label: i.$1,
                            activo: rutaActual == i.$2,
                            onTap: () => _ir(context, i.$2),
                          ),
                        ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () => _ir(context, AppRoutes.contacto),
                  child: const Text('CONTACTO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _ir(BuildContext context, String ruta) {
    Navigator.pop(context);
    Navigator.pushNamed(context, ruta);
  }
}

class _MobileMenuItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool activo;
  final VoidCallback onTap;

  const _MobileMenuItem({
    required this.label,
    this.icon,
    this.activo = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: activo ? AppColors.violetaPrincipal.withValues(alpha: 0.1) : null,
          border: Border(
            left: BorderSide(
              color: activo ? AppColors.cianTech : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: activo ? AppColors.cianTech : AppColors.textMuted),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: TextStyle(
                color: activo ? AppColors.textLight : AppColors.textMuted,
                fontSize: 15,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
