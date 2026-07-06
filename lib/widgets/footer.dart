import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

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
                SizedBox(height: 32),
                _FooterLinksColumn(),
                SizedBox(height: 32),
                _FooterContactColumn(),
              ],
            ),
          SizedBox(height: 40),
          Divider(
            color: Colors.white12,
            height: 1,
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2025 57 Nations | Todos los derechos reservados',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  _SocialIcon(
                    icon: Icons.camera_alt,
                    url: 'https://instagram.com/57nations_',
                  ),
                  SizedBox(width: 16),
                  _SocialIcon(
                    icon: Icons.language,
                    url: 'https://linkedin.com',
                  ),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/panel'),
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.white24,
                      size: 16,
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
        SizedBox(height: 12),
        Text(
          'Soluciones Tech Integrales',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        SizedBox(height: 16),
        Text(
          'Santa Cruz, Bolivia',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 16),
        Text(
          '📱 WhatsApp',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        SizedBox(height: 8),
        Text(
          '📧 Email',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
        SizedBox(height: 8),
        Text(
          '⏰ Lunes-Viernes 9am-6pm',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
        ),
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _isHovered ? AppColors.accent : Colors.white70,
              fontSize: 14,
              decoration: _isHovered ? TextDecoration.underline : null,
            ),
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // TODO: Abrir URL en navegador
        },
        child: Icon(
          widget.icon,
          color: _isHovered ? AppColors.accent : Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}
