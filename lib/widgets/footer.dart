import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 40,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          if (!isMobile)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FooterColumn(),
                _FooterLinksColumn(),
                _FooterContactColumn(),
              ],
            )
          else
            Column(
              children: [
                _FooterColumn(),
                const SizedBox(height: 32),
                _FooterLinksColumn(),
                const SizedBox(height: 32),
                _FooterContactColumn(),
              ],
            ),
          const SizedBox(height: 40),
          const Divider(
            color: AppColors.border,
            height: 1,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2025 57 Nations | Todos los derechos reservados',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Row(
                children: [
                  const _SocialIcon(
                    icon: Icons.camera_alt,
                    url: 'https://instagram.com/57nations_',
                  ),
                  const SizedBox(width: 16),
                  const _SocialIcon(
                    icon: Icons.language,
                    url: 'https://linkedin.com',
                  ),
                  const SizedBox(width: 16),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/panel'),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Icon(
                            Icons.lock_outline,
                            color: AppColors.textDim,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
Image.asset(
          'assets/logos/logo_57nations.png',
          height: 36,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          'Soluciones Tech Integrales',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Text(
          'Santa Cruz, Bolivia',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _FooterLinksColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enlaces Rápidos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _FooterLink(label: 'Inicio', onTap: () {}),
        _FooterLink(label: 'Servicios', onTap: () {}),
        _FooterLink(label: 'Portfolio', onTap: () {}),
        _FooterLink(label: 'Catálogo 3D', onTap: () {}),
        _FooterLink(label: 'Contacto', onTap: () {}),
      ],
    );
  }
}

class _FooterContactColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contacto',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text('📱 WhatsApp', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('📧 Email', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text('⏰ Lunes-Viernes 9am-6pm', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({
    required this.label,
    required this.onTap,
  });

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _isHovered ? AppColors.accent : AppColors.textLight,
              fontSize: 14,
              decoration: _isHovered ? TextDecoration.underline : null,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({
    required this.icon,
    required this.url,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // TODO: Abrir URL en navegador
        },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: _isHovered ? 1.15 : 1.0,
              child: Icon(
                widget.icon,
                color: _isHovered ? AppColors.accent : AppColors.textLight,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
