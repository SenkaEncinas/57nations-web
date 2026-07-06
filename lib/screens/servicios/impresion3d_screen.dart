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
          'Piezas decorativas y funcionales impresas bajo pedido, con diseño '
          'custom y acabado profesional — incluso pintado a mano.',
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
              'Todo el catálogo se imprime a pedido: elegís la pieza, el '
              'material y los colores, y la fabricamos para vos.',
        ),
        CapacidadServicio(
          icon: Icons.draw_outlined,
          titulo: 'Diseño custom',
          descripcion:
              'Diseñamos la pieza que necesitás desde cero, o adaptamos un '
              'modelo existente a tus medidas.',
        ),
        CapacidadServicio(
          icon: Icons.brush_outlined,
          titulo: 'Acabado y pintado',
          descripcion:
              'Piezas con acabado profesional y pintado artístico a mano para '
              'figuras y piezas decorativas.',
        ),
      ],
    );
  }
}
