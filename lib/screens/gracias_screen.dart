import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../widgets/widgets.dart';

/// Página de agradecimiento post-compra. Pensada para llegar por LINK
/// DIRECTO (hoy: el chip NFC de los llaveros que arma Senka) — no está en
/// la Navbar a propósito. Además de agradecer, empuja tráfico al resto del
/// sitio (Catálogo 3D, Portfolio, Cotización) para que cada venta física
/// también sume visitas. Ver CLAUDE.md sección "Producto: llaveros NFC"
/// para la URL exacta que hay que grabar en cada chip.
class GraciasScreen extends StatelessWidget {
  const GraciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const WhatsAppFlotante(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              overline: 'Gracias',
              titulo: '¡Gracias por tu compra!',
              subtitulo:
                  'Tu llavero NFC ya es parte de 57 Nations — esperamos que te '
                  'encante. Mientras tanto, date una vuelta por lo que más '
                  'hacemos: quizás tu próxima idea también empieza acá.',
            ),
            _buildDescubriMas(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDescubriMas(BuildContext context) {
    final columnas = Responsive.valor(context, mobile: 1, tablet: 3, desktop: 3);

    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Seguí explorando',
            titulo: 'Descubrí más de 57 Nations',
            subtitulo:
                'Bots, apps, electrónica, impresión 3D y entrenamiento — todo '
                'bajo un mismo techo.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columnas,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: Responsive.valor(context, mobile: 1.7, tablet: 1.05, desktop: 1.05),
            children: [
              _DescubrirCard(
                icon: Icons.view_in_ar_outlined,
                titulo: 'Catálogo 3D',
                descripcion: 'Piezas listas para pedir, con precio y detalle de cada una.',
                accion: 'Ver catálogo',
                onTap: () => Navigator.pushNamed(context, AppRoutes.catalogo3d),
              ),
              _DescubrirCard(
                icon: Icons.collections_bookmark_outlined,
                titulo: 'Portfolio',
                descripcion: 'Proyectos reales que ya entregamos a otros clientes.',
                accion: 'Ver portfolio',
                onTap: () => Navigator.pushNamed(context, AppRoutes.portfolio),
              ),
              _DescubrirCard(
                icon: Icons.chat_bubble_outline,
                titulo: 'Cotizá tu proyecto',
                descripcion: '¿Tenés una idea? Contanos y te ayudamos a hacerla realidad.',
                accion: 'Cotizar ahora',
                onTap: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DescubrirCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final String accion;
  final VoidCallback onTap;

  const _DescubrirCard({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    required this.accion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TechCard(
      onTap: onTap,
      accentColor: AppColors.cianTech,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.cianTech, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            descripcion,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                accion.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.cianTech,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.cianTech),
            ],
          ),
        ],
      ),
    );
  }
}
