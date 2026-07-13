import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fondo técnico reutilizable del Hero: grid de plano tipo blueprint,
/// watermark "57" gigante, glow violeta radial y, solo en pantallas anchas
/// (>= 900px), un clúster de ilustraciones técnicas hardcodeadas (chip
/// ESP32, cubo isométrico wireframe, arcos de wifi, snippets de código
/// flotantes y trazas de PCB conectándolos) alineado a la derecha.
///
/// Todas las capas son dibujo vectorial fijo (nada de random ni partículas
/// animadas) — es intencional, hace juego con el resto del sitio, que es
/// minimalista y estático. Reutilizado en el Hero (opacidad 1) y en el
/// banner de cierre (`opacidad: 0.4`, ver `home_screen.dart`).
class TechBackground extends StatelessWidget {
  final double opacidad;

  const TechBackground({super.key, this.opacidad = 1.0});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacidad,
        child: CustomPaint(
          size: Size.infinite,
          painter: _TechBackgroundPainter(),
        ),
      ),
    );
  }
}

class _TechBackgroundPainter extends CustomPainter {
  /// Ancho de referencia del clúster técnico (chip/cubo/wifi/código/trazas).
  /// Las coordenadas de esas capas están hardcodeadas dentro de este marco
  /// de 700x420 y se lo ubica pegado al borde derecho del canvas real.
  static const double _clusterAncho = 700;
  static const double _clusterAlto = 420;
  static const double _anchoMinimoCluster = 900;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawGlow(canvas, size);
    _drawWatermark(canvas, size);

    if (size.width >= _anchoMinimoCluster) {
      final dx = size.width - _clusterAncho;
      final dy = ((size.height - _clusterAlto) / 2).clamp(0.0, size.height);
      canvas.save();
      canvas.translate(dx, dy);
      _drawTrazasPCB(canvas);
      _drawChip(canvas);
      _drawCubo(canvas);
      _drawWifi(canvas);
      _drawCodigo(canvas);
      canvas.restore();
    }
  }

  // ---- 1. Grid de plano (blueprint), cada 80px, violeta 4% ----
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violetaPrincipal.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // ---- 8. Glow radial violeta, máximo 5% de opacidad ----
  void _drawGlow(Canvas canvas, Size size) {
    final centro = Offset(size.width * 0.78, size.height * 0.32);
    final radio = size.width * 0.42;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.violetaPrincipal.withValues(alpha: 0.05),
          AppColors.violetaPrincipal.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: centro, radius: radio));
    canvas.drawCircle(centro, radio, paint);
  }

  // ---- 7. Watermark "57" gigante, violeta 4% ----
  void _drawWatermark(Canvas canvas, Size size) {
    final texto = TextPainter(
      text: TextSpan(
        text: '57',
        style: TextStyle(
          color: AppColors.violetaPrincipal.withValues(alpha: 0.04),
          fontSize: 260,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = Offset(
      size.width - texto.width * 0.85,
      size.height - texto.height * 0.9,
    );
    texto.paint(canvas, offset);
  }

  // ---- 6. Trazas de PCB en L conectando el clúster, violeta 22% ----
  void _drawTrazasPCB(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.violetaPrincipal.withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final nodo = Paint()..color = AppColors.violetaPrincipal.withValues(alpha: 0.3);

    void trazaL(Offset a, Offset codo, Offset b) {
      canvas.drawLine(a, codo, paint);
      canvas.drawLine(codo, b, paint);
      canvas.drawCircle(a, 2, nodo);
      canvas.drawCircle(b, 2, nodo);
    }

    // Chip -> cubo
    trazaL(const Offset(560, 150), const Offset(600, 150), const Offset(600, 220));
    // Chip -> wifi
    trazaL(const Offset(490, 190), const Offset(490, 260), const Offset(460, 280));
    // Chip -> código
    trazaL(const Offset(500, 190), const Offset(500, 310), const Offset(480, 330));
    // Cubo -> código
    trazaL(const Offset(580, 290), const Offset(580, 340), const Offset(550, 350));
  }

  // ---- 2. Chip ESP32, x:470-560 y:120-190 ----
  void _drawChip(Canvas canvas) {
    const rect = Rect.fromLTWH(470, 120, 90, 70);
    final borde = Paint()
      ..color = AppColors.violetaPrincipal.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRect(rect, borde);

    // Pines arriba/abajo
    for (var i = 0; i < 5; i++) {
      final x = 480 + i * 16.0;
      canvas.drawLine(Offset(x, 120), Offset(x, 110), borde);
      canvas.drawLine(Offset(x, 190), Offset(x, 200), borde);
    }
    // Pines izquierda/derecha
    for (var i = 0; i < 4; i++) {
      final y = 132 + i * 14.0;
      canvas.drawLine(Offset(470, y), Offset(460, y), borde);
      canvas.drawLine(Offset(560, y), Offset(570, y), borde);
    }

    final punto = Paint()..color = AppColors.cianTech.withValues(alpha: 0.35);
    canvas.drawCircle(const Offset(482, 132), 2, punto);

    final texto = TextPainter(
      text: TextSpan(
        text: 'ESP32',
        style: TextStyle(
          color: AppColors.violetaPrincipal.withValues(alpha: 0.32),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    texto.paint(canvas, const Offset(492, 147));
  }

  // ---- 3. Cubo isométrico wireframe, x:560-640 y:220-290 ----
  void _drawCubo(Canvas canvas) {
    final linea = Paint()
      ..color = AppColors.violetaPrincipal.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const centroX = 600.0;
    const topY = 220.0;
    const alto = 45.0;
    const medioAncho = 40.0;

    // Cara superior (rombo)
    const top = Offset(centroX, topY);
    const der = Offset(centroX + medioAncho, topY + 22);
    const izq = Offset(centroX - medioAncho, topY + 22);
    const fondo = Offset(centroX, topY + 44);

    // Cuerpo del cubo hacia abajo
    const topB = top;
    final derB = Offset(der.dx, der.dy + alto);
    final izqB = Offset(izq.dx, izq.dy + alto);
    final fondoB = Offset(fondo.dx, fondo.dy + alto);

    canvas.drawLine(top, der, linea);
    canvas.drawLine(top, izq, linea);
    canvas.drawLine(der, fondo, linea);
    canvas.drawLine(izq, fondo, linea);

    canvas.drawLine(der, derB, linea);
    canvas.drawLine(izq, izqB, linea);
    canvas.drawLine(fondo, fondoB, linea);

    canvas.drawLine(topB, derB, linea);
    canvas.drawLine(topB, izqB, linea);
    canvas.drawLine(derB, fondoB, linea);
    canvas.drawLine(izqB, fondoB, linea);
  }

  // ---- 4. Arcos de wifi/señal, x:430-490 y:280-310 ----
  void _drawWifi(Canvas canvas) {
    final paint = Paint()
      ..color = AppColors.cianTech.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const centro = Offset(450, 310);
    for (var i = 1; i <= 3; i++) {
      final radio = i * 12.0;
      canvas.drawArc(
        Rect.fromCircle(center: centro, radius: radio),
        3.6, // ~206°, arco hacia arriba-derecha
        1.9,
        false,
        paint,
      );
    }
    canvas.drawCircle(centro, 2.2, Paint()..color = AppColors.cianTech.withValues(alpha: 0.35));
  }

  // ---- 5. Snippets de código flotantes, x:430-550 y:330-370 ----
  void _drawCodigo(Canvas canvas) {
    const lineas = ['<div/>', 'if (ok)', '01 10', '{...}'];
    var y = 330.0;
    for (final l in lineas) {
      final texto = TextPainter(
        text: TextSpan(
          text: l,
          style: TextStyle(
            color: AppColors.violetaPrincipal.withValues(alpha: 0.24),
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      texto.paint(canvas, Offset(430, y));
      y += 12;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
