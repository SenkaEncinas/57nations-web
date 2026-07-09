import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Tarjeta de servicio del Home. Dirección minimalista: el color de
/// categoría queda SOLO como tinte del ícono (identificador funcional,
/// pequeño); el resto de la card (borde, sombra, hover) usa un único
/// acento — violeta, el primario del sitio — para que la grilla de 5
/// tarjetas no muestre cinco colores compitiendo a la vez.
class ServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: ShapeDecoration(
            color: AppColors.surfaceElevated,
            shape: AppTheme.cutCorner(
              side: BorderSide(
                color: _isHovered ? AppColors.violetaPrincipal : AppColors.border,
                width: _isHovered ? 1.2 : 1,
              ),
            ),
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.violetaPrincipal.withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Único uso del color de categoría: un tinte chico en el
              // ícono, para poder identificar el servicio de un vistazo
              // sin que compita con el resto de la tarjeta.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: widget.color, size: 26),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              // "Ver más" aparece resaltado al hover, siempre en el
              // acento único de la sección (violeta) — no en el color
              // de categoría.
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: _isHovered ? AppColors.violetaPrincipal : AppColors.textDim,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Ver más'),
                    const SizedBox(width: 6),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 180),
                      offset: _isHovered ? const Offset(0.15, 0) : Offset.zero,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: _isHovered ? AppColors.violetaPrincipal : AppColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
