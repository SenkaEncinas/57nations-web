import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import 'servicio_screen_base.dart';

class Impresion3dScreen extends StatelessWidget {
  const Impresion3dScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ServicioScreenBase(
      titulo: 'Impresión 3D',
      subtitulo:
          'Imprimimos en 3D la pieza que necesités, a pedido: decorativa o '
          'funcional, con el diseño que quieras y buen acabado — hasta '
          'pintada a mano si hace falta.',
      colorAcento: AppColors.impresion3dColor,
      accionSecundaria: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.catalogo3d),
        child: const Text('VER CATÁLOGO 3D'),
      ),
      capacidades: const [
        CapacidadServicio(
          icon: Icons.view_in_ar_outlined,
          titulo: 'Impresión bajo pedido',
          descripcion:
              'Elegís la pieza del catálogo, el material y los colores, y la '
              'fabricamos especialmente para vos — no hay stock guardado, se '
              'imprime cuando la pedís.',
        ),
        CapacidadServicio(
          icon: Icons.draw_outlined,
          titulo: 'Diseño a medida',
          descripcion:
              'Si no existe la pieza que buscás, la diseñamos desde cero. Y '
              'si ya tenés una idea o un modelo parecido, lo adaptamos a tus '
              'medidas.',
        ),
        CapacidadServicio(
          icon: Icons.brush_outlined,
          titulo: 'Acabado y pintado',
          descripcion:
              'Las piezas salen prolijas y bien terminadas. Para figuras y '
              'piezas decorativas, también las pintamos a mano.',
        ),
      ],
    );
  }
}
