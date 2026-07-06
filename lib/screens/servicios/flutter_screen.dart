import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'servicio_screen_base.dart';

class FlutterScreen extends StatelessWidget {
  const FlutterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicioScreenBase(
      titulo: 'Apps Flutter',
      subtitulo:
          'Desarrollo multiplataforma iOS + Android con interfaces intuitivas: '
          'una sola app, todos los dispositivos.',
      colorAcento: AppColors.flutterColor,
      capacidades: [
        CapacidadServicio(
          icon: Icons.devices_outlined,
          titulo: 'iOS + Android + Web',
          descripcion:
              'Un solo desarrollo que corre en teléfonos, tablets y navegador, '
              'con la misma calidad en todos.',
        ),
        CapacidadServicio(
          icon: Icons.design_services_outlined,
          titulo: 'Interfaces intuitivas',
          descripcion:
              'Diseño pensado para que cualquier usuario entienda la app sin '
              'manual: claro, rápido y consistente.',
        ),
        CapacidadServicio(
          icon: Icons.cloud_outlined,
          titulo: 'Backend y datos',
          descripcion:
              'Integración con Firebase y servicios en la nube: login, base de '
              'datos en tiempo real y notificaciones.',
        ),
      ],
    );
  }
}
