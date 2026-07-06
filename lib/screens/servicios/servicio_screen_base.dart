import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

/// Capacidad puntual de un servicio (tarjeta chica en la página del servicio).
class CapacidadServicio {
  final IconData icon;
  final String titulo;
  final String descripcion;

  const CapacidadServicio({
    required this.icon,
    required this.titulo,
    required this.descripcion,
  });
}

/// Plantilla común de las 5 páginas de servicio. Todas comparten estructura
/// (hero con color de categoría, capacidades, CTA a cotización) y solo cambian
/// los datos — así el contenido real pendiente se carga en un solo lugar
/// por servicio, sin duplicar layout.
class ServicioScreenBase extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color colorAcento;
  final List<CapacidadServicio> capacidades;

  /// Acción secundaria opcional en el hero (ej.: "Ver catálogo" en 3D).
  final Widget? accionSecundaria;

  const ServicioScreenBase({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.colorAcento,
    required this.capacidades,
    this.accionSecundaria,
  });

  @override
  Widget build(BuildContext context) {
    final columnas = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            PageHero(
              overline: 'Servicios',
              titulo: titulo,
              subtitulo: subtitulo,
              colorAcento: colorAcento,
              acciones: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                  child: const Text('SOLICITAR COTIZACIÓN'),
                ),
                if (accionSecundaria != null) accionSecundaria!,
              ],
            ),
            PageSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    overline: 'Capacidades',
                    titulo: 'Qué podemos hacer por vos',
                    accentColor: colorAcento,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnas,
                      crossAxisSpacing: AppSpacing.lg,
                      mainAxisSpacing: AppSpacing.lg,
                      mainAxisExtent: 190,
                    ),
                    itemCount: capacidades.length,
                    itemBuilder: (context, i) {
                      final c = capacidades[i];
                      return TechCard(
                        accentColor: colorAcento,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(c.icon, color: colorAcento, size: 28),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              c.titulo,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                c.descripcion,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            PageSection(
              alternada: true,
              verticalPadding: AppSpacing.sectionLg,
              child: TechCard(
                showCornerBrackets: true,
                accentColor: colorAcento,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contanos tu proyecto',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Cada proyecto se cotiza a medida. Escribinos y te respondemos '
                      'directamente por WhatsApp, sin costo ni compromiso.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                      child: const Text('COTIZAR AHORA'),
                    ),
                  ],
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
