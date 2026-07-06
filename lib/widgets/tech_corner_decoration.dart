import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Decoración de "circuito sutil" para esquinas, según el manual de marca
/// (sección 05: líneas finas violetas con pequeños círculos en los extremos,
/// tal como aparecen en el header/footer de cada página del manual).
///
/// Uso: ponelo dentro de un Stack, posicionado en una esquina, detrás del
/// contenido principal. Por defecto dibuja para la esquina superior
/// izquierda; usá `espejado: true` para la esquina superior derecha.
class TechCornerDecoration extends StatelessWidget {
  final double width;
  final double height;
  final bool espejado;
  final Color color;

  const TechCornerDecoration({
    super.key,
    this.width = 160,
    this.height = 80,
    this.espejado = false,
    this.color = AppColors.violetaPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    final child = CustomPaint(
      size: Size(width, height),
      painter: _TechCornerPainter(color: color),
    );

    return espejado
        ? Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(3.1416), // espejo horizontal
            child: child,
          )
        : child;
  }
}

class _TechCornerPainter extends CustomPainter {
  final Color color;

  _TechCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final linea = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final punto = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Línea horizontal superior (borde en L)
    canvas.drawLine(const Offset(0, 0), Offset(size.width * 0.7, 0), linea);
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height * 0.6), linea);

    // Líneas horizontales cortas decorativas (como en el manual)
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.55, size.height * 0.25),
      linea,
    );
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.4),
      linea,
    );

    // Puntos en los extremos (como circuitos)
    canvas.drawCircle(const Offset(0, 0), 2.5, punto);
    canvas.drawCircle(Offset(size.width * 0.7, 0), 2.5, punto);
    canvas.drawCircle(Offset(0, size.height * 0.6), 2.5, punto);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.25), 2, punto);
    canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.4), 2, punto);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}