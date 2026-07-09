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
          'Te armamos una app para el celular que funciona igual de bien en '
          'iPhone y en Android — un solo desarrollo, fácil de usar desde el '
          'primer día.',
      colorAcento: AppColors.flutterColor,
      capacidades: [
        CapacidadServicio(
          icon: Icons.devices_outlined,
          titulo: 'iOS + Android + Web',
          descripcion:
              'La misma app funciona en tu celular, en una tablet y hasta en '
              'la computadora desde el navegador — no hay que pagar ni '
              'mantener versiones separadas.',
        ),
        CapacidadServicio(
          icon: Icons.design_services_outlined,
          titulo: 'Interfaces intuitivas',
          descripcion:
              'La diseñamos para que se entienda sola, sin instrucciones ni '
              'tutorial: botones claros, todo donde uno lo espera encontrar.',
        ),
        CapacidadServicio(
          icon: Icons.cloud_outlined,
          titulo: 'Datos en la nube',
          descripcion:
              'Todo lo que el usuario guarda —su cuenta, sus datos, sus '
              'mensajes— queda a salvo en internet y se actualiza al '
              'instante en todos sus dispositivos. También podemos '
              'mandarle avisos directo al celular.',
        ),
      ],
    );
  }
}
