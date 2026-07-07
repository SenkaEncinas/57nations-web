import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../config/app_config.dart';
import '../routes/app_routes.dart';
import '../utils/responsive.dart';
import '../utils/whatsapp_helper.dart';
import '../widgets/widgets.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final columnas = Responsive.valor(context, mobile: 1, tablet: 3, desktop: 3);

    return Scaffold(
      floatingActionButton: const WhatsAppFlotante(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              overline: 'Contacto',
              titulo: 'Hablemos de tu proyecto',
              subtitulo:
                  'Contanos tu idea y te respondemos directamente por WhatsApp, '
                  'sin formularios eternos ni respuestas automáticas.',
            ),
            PageSection(
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columnas,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: Responsive.valor(
                      context,
                      mobile: 2.4,
                      tablet: 1.15,
                      desktop: 1.5,
                    ),
                    children: [
                      _ContactoCard(
                        icon: Icons.chat_bubble_outline,
                        titulo: 'WhatsApp',
                        descripcion: 'Respuesta rápida para consultas y cotizaciones.',
                        accion: 'Escribir ahora',
                        onTap: () =>
                            WhatsAppHelper.abrirChat(telefono: AppConfig.whatsappAdminNumero),
                      ),
                      const _ContactoCard(
                        icon: Icons.schedule_outlined,
                        titulo: 'Horario de atención',
                        descripcion: 'Lunes a Viernes, 9:00 - 18:00.',
                      ),
                      const _ContactoCard(
                        icon: Icons.location_on_outlined,
                        titulo: 'Ubicación',
                        descripcion: 'Santa Cruz de la Sierra, Bolivia.',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.section),
                  TechCard(
                    showCornerBrackets: true,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      children: [
                        Text(
                          '¿Ya tenés un proyecto en mente?',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Completá el formulario de cotización y te contactamos a la brevedad.',
                          style: TextStyle(color: AppColors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                          child: const Text('SOLICITAR COTIZACIÓN'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _ContactoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;
  final String? accion;
  final VoidCallback? onTap;

  const _ContactoCard({
    required this.icon,
    required this.titulo,
    required this.descripcion,
    this.accion,
    this.onTap,
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
          if (accion != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  accion!.toUpperCase(),
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
        ],
      ),
    );
  }
}
