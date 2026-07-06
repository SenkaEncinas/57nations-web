import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'servicio_screen_base.dart';

class EntrenamientoScreen extends StatelessWidget {
  const EntrenamientoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServicioScreenBase(
      titulo: 'Entrenamiento',
      subtitulo:
          'Coaching profesional de basketball: técnica, táctica y desarrollo '
          'individual para llevar tu juego al siguiente nivel.',
      colorAcento: AppColors.entrenamientoColor,
      capacidades: [
        CapacidadServicio(
          icon: Icons.sports_basketball_outlined,
          titulo: 'Técnica individual',
          descripcion:
              'Fundamentos, tiro, manejo de balón y mecánica corregida uno a '
              'uno, a tu ritmo.',
        ),
        CapacidadServicio(
          icon: Icons.psychology_outlined,
          titulo: 'Táctica y lectura de juego',
          descripcion:
              'Entender el juego: espacios, decisiones y roles para rendir '
              'mejor en cancha.',
        ),
        CapacidadServicio(
          icon: Icons.trending_up_outlined,
          titulo: 'Plan de desarrollo',
          descripcion:
              'Seguimiento de progreso con objetivos claros por etapa, para '
              'jugadores en formación y competitivos.',
        ),
      ],
    );
  }
}
