import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/widgets.dart';

class ArduinoScreen extends StatelessWidget {
  const ArduinoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              titulo: 'ARDUINO & ESP32',
              subtitulo:
                  'IoT, automatización y control remoto de dispositivos inteligentes.',
              colorAcento: AppColors.arduinoColor,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 60,
                vertical: isMobile ? 50 : 80,
              ),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.memory, color: AppColors.arduinoColor, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    'Estamos terminando de armar el contenido detallado de este servicio.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mientras tanto, contanos tu proyecto y te asesoramos directamente.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                    child: const Text('SOLICITAR COTIZACIÓN'),
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
