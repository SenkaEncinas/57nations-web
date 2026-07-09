import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Card estándar del sistema de marca: esquinas recortadas, borde fino,
/// y al pasar el mouse un glow violeta sutil + borde en el color de acento.
/// Reemplaza a los Container con BoxDecoration redondeada repetidos en
/// cada pantalla.
///
/// - [accentColor]: color del borde/glow en hover (default violeta de marca).
/// - [onTap]: si se pasa, la card entera es clickeable (cursor + InkWell).
/// - [showCornerBrackets]: dibuja los "brackets" de circuito en dos esquinas
///   (usar solo en cards destacadas, no en listados largos — el manual pide
///   no saturar el sistema gráfico).
class TechCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool showCornerBrackets;
  final Color? backgroundColor;
  final Clip clipBehavior;

  const TechCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.accentColor,
    this.onTap,
    this.showCornerBrackets = false,
    this.backgroundColor,
    this.clipBehavior = Clip.none,
  });

  @override
  State<TechCard> createState() => _TechCardState();
}

class _TechCardState extends State<TechCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final acento = widget.accentColor ?? AppColors.violetaPrincipal;
    final interactiva = widget.onTap != null;

    Widget contenido = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      clipBehavior: widget.clipBehavior,
      decoration: ShapeDecoration(
        color: widget.backgroundColor ?? AppColors.surfaceElevated,
        shape: AppTheme.cutCorner(
          side: BorderSide(
            color: _hovered && interactiva ? acento : AppColors.border,
            width: _hovered && interactiva ? 1.4 : 1,
          ),
        ),
        // Sombra sutil y puntual (dirección minimalista): solo al hover,
        // nunca como decoración ambiental constante.
        shadows: _hovered && interactiva
            ? [
                BoxShadow(
                  color: acento.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.showCornerBrackets) {
      contenido = Stack(
        children: [
          contenido,
          Positioned(top: 6, left: 6, child: _CornerBracket(color: acento)),
          Positioned(
            bottom: 6,
            right: 6,
            child: Transform.rotate(angle: 3.1416, child: _CornerBracket(color: acento)),
          ),
        ],
      );
    }

    if (!interactiva) return contenido;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(onTap: widget.onTap, child: contenido),
    );
  }
}

/// Bracket en "L" fino, mismo lenguaje que TechCornerDecoration pero mínimo,
/// para marcar esquinas de cards destacadas.
class _CornerBracket extends StatelessWidget {
  final Color color;

  const _CornerBracket({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14, 14),
      painter: _CornerBracketPainter(color: color.withValues(alpha: 0.55)),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) => oldDelegate.color != color;
}
