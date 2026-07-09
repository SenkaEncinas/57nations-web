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
          'Conectamos objetos de tu casa o negocio a internet para que los '
          'controles y los mires desde el celular, estés donde estés.',
      colorAcento: AppColors.arduinoColor,
      capacidades: [
        CapacidadServicio(
          icon: Icons.sensors_outlined,
          titulo: 'Sensores conectados',
          descripcion:
              'Medimos temperatura, humedad, movimiento o consumo de luz con '
              'sensores chicos, y vos ves esos datos en tu celular desde '
              'donde estés.',
        ),
        CapacidadServicio(
          icon: Icons.settings_remote_outlined,
          titulo: 'Control remoto',
          descripcion:
              'Prendé, apagá o programá horarios para luces, riego, portones '
              'o lo que necesites — todo desde una app en tu celular.',
        ),
        CapacidadServicio(
          icon: Icons.precision_manufacturing_outlined,
          titulo: 'Tareas automáticas',
          descripcion:
              'Tareas que hoy hacés a mano —como regar una planta o '
              'controlar una máquina— las armamos para que pasen solas, en '
              'el momento justo.',
        ),
      ],
    );
  }
}
