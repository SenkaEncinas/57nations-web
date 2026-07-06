import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Tarjeta de servicio del Home. Sigue el sistema de marca: esquinas
/// recortadas, borde fino, glow sutil del color de categoría al hover y
/// una leve elevación animada.
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
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: AppColors.surfaceElevated,
            shape: AppTheme.cutCorner(
              side: BorderSide(
                color: _isHovered ? widget.color : AppColors.border,
                width: _isHovered ? 1.4 : 1,
              ),
            ),
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICONO en marco recortado del color de categoría
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 56,
                height: 56,
                decoration: ShapeDecoration(
                  color: widget.color.withValues(alpha: _isHovered ? 0.18 : 0.10),
                  shape: AppTheme.cutCorner(
                    size: AppTheme.cutSizeSm,
                    side: BorderSide(color: widget.color.withValues(alpha: 0.35)),
                  ),
                ),
                child: Icon(widget.icon, color: widget.color, size: 28),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 10),
              Text(
                widget.description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // "Ver más" aparece resaltado al hover
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: _isHovered ? widget.color : AppColors.textDim,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('VER MÁS'),
                    const SizedBox(width: 6),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 180),
                      offset: _isHovered ? const Offset(0.15, 0) : Offset.zero,
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: _isHovered ? widget.color : AppColors.textDim,
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
