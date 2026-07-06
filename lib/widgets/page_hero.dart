import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import 'tech_corner_decoration.dart';

/// Encabezado reutilizable para páginas internas (Servicios, Portfolio,
/// Contacto, Sobre Nosotros): gradiente de marca, grid de circuito sutil,
/// decoración de esquinas (manual, sección 05), overline + título + subtítulo
/// y acciones opcionales (botones CTA).
class PageHero extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color? colorAcento;
  final String? overline;
  final List<Widget> acciones;

  const PageHero({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.colorAcento,
    this.overline,
    this.acciones = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final acento = colorAcento ?? AppColors.violetaPrincipal;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        children: [
          // Grid de circuito sutil sobre todo el hero
          Positioned.fill(
            child: CustomPaint(
              painter: CircuitGridPainter(color: acento.withValues(alpha: 0.05)),
            ),
          ),
          if (!isMobile) ...[
            const Positioned(top: 24, left: 24, child: TechCornerDecoration()),
            const Positioned(top: 24, right: 24, child: TechCornerDecoration(espejado: true)),
          ],
          // Glow radial suave
          Positioned(
            top: -100,
            left: isMobile ? -80 : 100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [acento.withValues(alpha: 0.20), acento.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal(context),
              vertical: isMobile ? AppSpacing.sectionLg : 90,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (overline != null) ...[
                      Row(
                        children: [
                          Container(width: 20, height: 1.2, color: acento.withValues(alpha: 0.7)),
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: acento, shape: BoxShape.circle),
                          ),
                          Text(
                            overline!.toUpperCase(),
                            style: TextStyle(
                              color: acento,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontSize: isMobile ? 30 : 44,
                          ),
                    ),
                    SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),
                    SizedBox(
                      width: isMobile ? double.infinity : 640,
                      child: Text(
                        subtitulo,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              height: 1.6,
                            ),
                      ),
                    ),
                    if (acciones.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      Wrap(
                        spacing: AppSpacing.lg,
                        runSpacing: AppSpacing.md,
                        children: acciones,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid de líneas finas tipo plano de circuito, para fondos de hero.
/// El color ya debe venir con alpha bajo — esto NUNCA debe competir con
/// el contenido (manual: glow y gráfica siempre sutiles).
class CircuitGridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  CircuitGridPainter({required this.color, this.spacing = 48});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CircuitGridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}
