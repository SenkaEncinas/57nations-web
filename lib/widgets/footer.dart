import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../utils/whatsapp_helper.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal(context),
        vertical: AppSpacing.section,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: Column(
            children: [
              if (!isMobile)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _FooterMarca()),
                    Expanded(child: _FooterLinksColumn()),
                    Expanded(child: _FooterContactColumn()),
                  ],
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FooterMarca(),
                    SizedBox(height: AppSpacing.xxl),
                    _FooterLinksColumn(),
                    SizedBox(height: AppSpacing.xxl),
                    _FooterContactColumn(),
                  ],
                ),
              const SizedBox(height: AppSpacing.section),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.xl),
              Flex(
                direction: isMobile ? Axis.vertical : Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                    isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Text(
                    '© ${DateTime.now().year} 57 Nations · Santa Cruz, Bolivia',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (isMobile) const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const _SocialIcon(
                        icon: Icons.camera_alt_outlined,
                        tooltip: 'Instagram',
                        url: 'https://www.instagram.com/nations_57_?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _SocialIcon(
                        icon: Icons.chat_bubble_outline,
                        tooltip: 'WhatsApp',
                        onTap: () =>
                            WhatsAppHelper.abrirChat(telefono: AppConfig.whatsappAdminNumero),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Acceso discreto al panel interno
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.panelLogin),
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
        ),
      ),
    );
  }
}

class _FooterMarca extends StatelessWidget {
  const _FooterMarca();

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
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Soluciones tech integrales: software, hardware, impresión 3D y '
            'entrenamiento. De la idea al producto real.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}

class _FooterTituloColumna extends StatelessWidget {
  final String titulo;

  const _FooterTituloColumna(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}

class _FooterLinksColumn extends StatelessWidget {
  const _FooterLinksColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FooterTituloColumna('Enlaces'),
        const SizedBox(height: AppSpacing.lg),
        _FooterLink(label: 'Inicio', onTap: () => Navigator.pushNamed(context, AppRoutes.home)),
        _FooterLink(
            label: 'Portfolio', onTap: () => Navigator.pushNamed(context, AppRoutes.portfolio)),
        _FooterLink(
            label: 'Catálogo 3D', onTap: () => Navigator.pushNamed(context, AppRoutes.catalogo3d)),
        _FooterLink(
            label: 'Cotizar proyecto',
            onTap: () => Navigator.pushNamed(context, AppRoutes.cotizacion)),
        _FooterLink(
            label: 'Contacto', onTap: () => Navigator.pushNamed(context, AppRoutes.contacto)),
      ],
    );
  }
}

class _FooterContactColumn extends StatelessWidget {
  const _FooterContactColumn();

  @override
  Widget build(BuildContext context) {
    const estilo = TextStyle(color: AppColors.textDim, fontSize: 13, height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FooterTituloColumna('Contacto'),
        const SizedBox(height: AppSpacing.lg),
        _FooterLink(
          label: 'WhatsApp directo',
          onTap: () => WhatsAppHelper.abrirChat(telefono: AppConfig.whatsappAdminNumero),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text('Lunes a Viernes · 9:00 - 18:00', style: estilo),
        const SizedBox(height: AppSpacing.xs),
        const Text('Santa Cruz de la Sierra, Bolivia', style: estilo),
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
          constraints: const BoxConstraints(minHeight: 36),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              color: _isHovered ? AppColors.cianTech : AppColors.textMuted,
              fontSize: 14,
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
  final String tooltip;
  final String? url;
  final VoidCallback? onTap;

  const _SocialIcon({
    required this.icon,
    required this.tooltip,
    this.url,
    this.onTap,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  Future<void> _abrir() async {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    if (widget.url != null) {
      final uri = Uri.parse(widget.url!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _abrir,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: _isHovered ? 1.15 : 1.0,
                child: Icon(
                  widget.icon,
                  color: _isHovered ? AppColors.cianTech : AppColors.textMuted,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
