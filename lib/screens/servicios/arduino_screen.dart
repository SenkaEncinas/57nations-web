import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'servicio_screen_base.dart';

class ArduinoScreen extends StatelessWidget {
  const ArduinoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicioScreenBase(
      titulo: 'Arduino & ESP32',
      subtitulo:
          'IoT, automatización y control remoto de dispositivos inteligentes: '
          'electrónica que conecta el mundo físico con tu teléfono.',
      colorAcento: AppColors.arduinoColor,
      capacidades: [
        CapacidadServicio(
          icon: Icons.sensors_outlined,
          titulo: 'IoT y sensores',
          descripcion:
              'Medición de temperatura, humedad, movimiento o consumo, con '
              'datos visibles desde cualquier lugar.',
        ),
        CapacidadServicio(
          icon: Icons.settings_remote_outlined,
          titulo: 'Control remoto',
          descripcion:
              'Encendé, apagá y programá dispositivos desde el celular: luces, '
              'riego, portones, lo que necesites.',
        ),
        CapacidadServicio(
          icon: Icons.precision_manufacturing_outlined,
          titulo: 'Automatización física',
          descripcion:
              'Procesos del mundo real automatizados con ESP32 y Arduino, '
              'integrados con tus sistemas.',
        ),
      ],
    );
  }
}
