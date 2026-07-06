import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'servicio_screen_base.dart';

class BotsScreen extends StatelessWidget {
  const BotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicioScreenBase(
      titulo: 'Bots & Sistemas',
      subtitulo:
          'Automatización vía WhatsApp, sistemas con base de datos y control '
          'inteligente para que tu negocio trabaje solo.',
      colorAcento: AppColors.botColor,
      capacidades: [
        CapacidadServicio(
          icon: Icons.chat_outlined,
          titulo: 'Bots de WhatsApp',
          descripcion:
              'Atención automática, respuestas inteligentes y flujos de venta '
              'directamente en el chat que tus clientes ya usan.',
        ),
        CapacidadServicio(
          icon: Icons.storage_outlined,
          titulo: 'Sistemas a medida',
          descripcion:
              'Sistemas con base de datos para inventario, pedidos, clientes o '
              'lo que tu operación necesite registrar.',
        ),
        CapacidadServicio(
          icon: Icons.auto_mode_outlined,
          titulo: 'Automatización',
          descripcion:
              'Procesos repetitivos convertidos en flujos automáticos: menos '
              'errores manuales, más tiempo para tu negocio.',
        ),
      ],
    );
  }
}
