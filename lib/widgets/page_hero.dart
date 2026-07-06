import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'tech_corner_decoration.dart';

/// Encabezado reutilizable para páginas internas (Servicios, Portfolio,
/// Contacto, Sobre Nosotros): fondo con gradiente de marca, decoración de
/// circuito en las esquinas (manual, sección 05) y título + subtítulo.
class PageHero extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color? colorAcento;

  const PageHero({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final acento = colorAcento ?? AppColors.violetaPrincipal;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        children: [
          if (!isMobile) ...[
            const Positioned(top: 24, left: 24, child: TechCornerDecoration()),
            const Positioned(top: 24, right: 24, child: TechCornerDecoration(espejado: true)),
          ],
          Positioned(
            top: -100,
            left: isMobile ? -80 : 100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [acento.withValues(alpha: 0.22), acento.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 60,
              vertical: isMobile ? 60 : 90,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: isMobile ? 30 : 42,
                      ),
                ),
                SizedBox(height: isMobile ? 12 : 16),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
