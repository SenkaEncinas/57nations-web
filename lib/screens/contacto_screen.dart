import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../config/app_config.dart';
import '../routes/app_routes.dart';
import '../utils/whatsapp_helper.dart';
import '../widgets/widgets.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              titulo: 'CONTACTO',
              subtitulo: 'Contanos tu proyecto y te respondemos directamente por WhatsApp.',
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 60,
                vertical: isMobile ? 50 : 80,
              ),
              color: AppColors.background,
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile ? 1 : 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: isMobile ? 2.6 : 1.3,
                    children: [
                      _ContactoCard(
                        icon: Icons.chat_bubble_outline,
                        titulo: 'WhatsApp',
                        descripcion: 'Respuesta rápida para consultas y cotizaciones.',
                        accion: 'Escribir ahora',
                        onTap: () => WhatsAppHelper.abrirChat(telefono: AppConfig.whatsappAdminNumero),
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
                  SizedBox(height: isMobile ? 40 : 56),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '¿Ya tenés un proyecto en mente?',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Completá el formulario de cotización y te contactamos a la brevedad.',
                          style: TextStyle(color: AppColors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cianTech, size: 28),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(descripcion, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
          if (accion != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              child: Text(accion!),
            ),
          ],
        ],
      ),
    );
  }
}
