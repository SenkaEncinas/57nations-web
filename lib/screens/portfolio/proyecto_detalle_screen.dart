import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/widgets.dart';

/// Detalle de proyecto — la carga de contenido real sigue pendiente
/// (ver CLAUDE.md), pero la pantalla ya respeta el sistema de marca en vez
/// de mostrar un texto suelto "EN CONSTRUCCIÓN".
class ProyectoDetalleScreen extends StatelessWidget {
  final String proyectoId;

  const ProyectoDetalleScreen({
    super.key,
    required this.proyectoId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              overline: 'Portfolio',
              titulo: 'Detalle del proyecto',
              subtitulo:
                  'Estamos preparando la vista detallada de cada proyecto, con '
                  'galería de imágenes, tecnologías y el proceso completo.',
            ),
            PageSection(
              child: TechCard(
                showCornerBrackets: true,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.construction_outlined,
                        color: AppColors.violetaPrincipal, size: 36),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Muy pronto vas a poder ver este proyecto en detalle',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Mientras tanto, podés volver al portfolio o contarnos tu '
                      'propio proyecto.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.6),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.md,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('VOLVER AL PORTFOLIO'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.cotizacion),
                          child: const Text('COTIZAR MI PROYECTO'),
                        ),
                      ],
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
