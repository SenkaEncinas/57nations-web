import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
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
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              ),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violetaPrincipal.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/logos/logo_57nations.png',
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // NAVEGACIÓN
          if (!isMobile)
            Row(
              children: [
                _NavItem(
                  label: 'Inicio',
                  onTap: () => Navigator.pushNamed(context, '/'),
                ),
                _NavItem(
                  label: 'Servicios',
                  onTap: () => _showServicesMenu(context),
                ),
                _NavItem(
                  label: 'Portfolio',
                  onTap: () => Navigator.pushNamed(context, '/portfolio'),
                ),
                _NavItem(
                  label: 'Catálogo 3D',
                  onTap: () => Navigator.pushNamed(context, '/catalogo-3d'),
                ),
                _NavItem(
                  label: 'Sobre Nosotros',
                  onTap: () => Navigator.pushNamed(context, '/sobre-nosotros'),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/contacto'),
                  child: const Text('CONTACTO'),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showMobileMenu(context),
            ),
        ],
      ),
    );
  }

  void _showServicesMenu(BuildContext context) {
    final services = [
      ('Bots & Sistemas', '/bots'),
      ('Apps Flutter', '/flutter'),
      ('Arduino & ESP32', '/arduino'),
      ('Impresión 3D', '/impresion3d'),
      ('Entrenamiento', '/entrenamiento'),
    ];

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 50, 0, 0),
      items: services
          .map(
            (e) => PopupMenuItem(
              onTap: () => Navigator.pushNamed(context, e.$2),
              child: Text(e.$1),
            ),
          )
          .toList(),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MobileMenuItem(
              label: 'Inicio',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            _MobileMenuItem(
              label: 'Servicios',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/bots');
              },
            ),
            _MobileMenuItem(
              label: 'Portfolio',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/portfolio');
              },
            ),
            _MobileMenuItem(
              label: 'Catálogo 3D',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/catalogo-3d');
              },
            ),
            _MobileMenuItem(
              label: 'Sobre Nosotros',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/sobre-nosotros');
              },
            ),
            _MobileMenuItem(
              label: 'Contacto',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/contacto');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: _isHovered ? AppColors.accent : AppColors.textLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                child: Text(widget.label),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: _isHovered ? 30 : 0,
                color: AppColors.accent,
                margin: const EdgeInsets.only(top: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MobileMenuItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: onTap,
    );
  }
}
