import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'page_hero.dart' show CircuitGridPainter;
import 'status_badge.dart';

/// Card pública de proyecto del Portfolio. Compartida entre la página de
/// Portfolio y el preview de proyectos recientes del Home — una sola card
/// para que ambas vistas queden siempre iguales.
class ProyectoCard extends StatefulWidget {
  final Proyecto proyecto;
  final VoidCallback onTap;

  const ProyectoCard({super.key, required this.proyecto, required this.onTap});

  @override
  State<ProyectoCard> createState() => _ProyectoCardState();
}

class _ProyectoCardState extends State<ProyectoCard> {
  bool _isHovered = false;

  /// Color de acento según categoría, para el placeholder sin foto.
  Color get _colorCategoria {
    switch (widget.proyecto.categoria) {
      case CategoriasProyecto.bots:
        return AppColors.botColor;
      case CategoriasProyecto.flutter:
        return AppColors.flutterColor;
      case CategoriasProyecto.arduino:
        return AppColors.arduinoColor;
      case CategoriasProyecto.impresion3d:
        return AppColors.impresion3dColor;
      case CategoriasProyecto.entrenamiento:
        return AppColors.entrenamientoColor;
      default:
        return AppColors.violetaPrincipal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final proyecto = widget.proyecto;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          clipBehavior: Clip.hardEdge,
          decoration: ShapeDecoration(
            color: AppColors.surfaceElevated,
            shape: AppTheme.cutCorner(
              side: BorderSide(
                color: _isHovered ? AppColors.violetaPrincipal : AppColors.border,
                width: _isHovered ? 1.4 : 1,
              ),
            ),
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.violetaPrincipal.withValues(alpha: 0.14),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: proyecto.imagenes.isNotEmpty
                    ? SizedBox(
                        width: double.infinity,
                        child: Image.network(CloudinaryService.optimizar(proyecto.imagenes.first, ancho: 600), fit: BoxFit.cover),
                      )
                    : _PlaceholderFoto(color: _colorCategoria),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proyecto.titulo,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        StatusBadge(
                          texto: proyecto.categoria,
                          color: AppColors.cianTech,
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _isHovered ? 1 : 0,
                          child: const Icon(Icons.arrow_forward,
                              size: 16, color: AppColors.cianTech),
                        ),
                      ],
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

/// Placeholder prolijo para proyectos que todavía no tienen foto: fondo
/// surface con grid de circuito sutil e ícono en el color de la categoría.
/// Nunca un ícono de imagen rota.
class _PlaceholderFoto extends StatelessWidget {
  final Color color;

  const _PlaceholderFoto({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: CircuitGridPainter(
              color: color.withValues(alpha: 0.06),
              spacing: 28,
            ),
          ),
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: ShapeDecoration(
                color: color.withValues(alpha: 0.1),
                shape: AppTheme.cutCorner(
                  size: AppTheme.cutSizeSm,
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                ),
              ),
              child: Icon(Icons.terminal_outlined, color: color, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
