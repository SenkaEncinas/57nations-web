import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // LOGO
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
            child: Text(
              '57 NATIONS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                SizedBox(width: 24),
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? AppColors.accent : AppColors.textLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              if (_isHovered)
                Container(
                  height: 2,
                  width: 30,
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
