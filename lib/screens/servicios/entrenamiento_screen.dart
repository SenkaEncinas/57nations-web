import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import 'servicio_screen_base.dart';

class EntrenamientoScreen extends StatelessWidget {
  const EntrenamientoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ServicioScreenBase(
      titulo: 'Entrenamiento',
      subtitulo:
          'Entrenamiento personalizado de básquet, uno a uno: trabajamos tu '
          'técnica y tu forma de jugar para que subas de nivel de verdad.',
      colorAcento: AppColors.entrenamientoColor,
      accionSecundaria: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.catalogoEntrenadores),
        child: const Text('VER ENTRENADORES'),
      ),
      capacidades: const [
        CapacidadServicio(
          icon: Icons.sports_basketball_outlined,
          titulo: 'Técnica individual',
          descripcion:
              'Trabajamos lo básico —tiro, manejo de balón, movimientos— '
              'corrigiendo tu técnica uno a uno, a tu ritmo.',
        ),
        CapacidadServicio(
          icon: Icons.psychology_outlined,
          titulo: 'Táctica y lectura de juego',
          descripcion:
              'Te ayudamos a entender el juego: cuándo pasar, cuándo tirar, '
              'dónde ubicarte — para que rindas mejor en la cancha, no solo '
              'en los ejercicios.',
        ),
        CapacidadServicio(
          icon: Icons.trending_up_outlined,
          titulo: 'Plan de desarrollo',
          descripcion:
              'Armamos un plan con objetivos claros y hacemos seguimiento de '
              'tu progreso, sea que estés empezando o ya compitas.',
        ),
      ],
    );
  }
}
