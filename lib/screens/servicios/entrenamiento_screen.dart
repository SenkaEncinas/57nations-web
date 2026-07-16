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
          'Entrenamiento personalizado, uno a uno, en el deporte que practiques: '
          'básquet, fútbol, funcional, boxeo y más. Elegís entrenador y trabajás '
          'tu nivel a tu ritmo.',
      colorAcento: AppColors.entrenamientoColor,
      accionSecundaria: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.catalogoEntrenadores),
        child: const Text('VER ENTRENADORES'),
      ),
      capacidades: const [
        CapacidadServicio(
          icon: Icons.sports_outlined,
          titulo: 'Cualquier deporte',
          descripcion:
              'Básquet, fútbol, funcional, boxeo y más — mirá el catálogo y '
              'elegí al entrenador que se adapte a lo que buscás.',
        ),
        CapacidadServicio(
          icon: Icons.psychology_outlined,
          titulo: 'Técnica y táctica',
          descripcion:
              'Trabajamos tu técnica individual y tu lectura del juego, uno a '
              'uno, corrigiendo lo que hace falta a tu ritmo.',
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
