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
          'Un asistente que contesta tu WhatsApp, guarda los pedidos y te '
          'avisa lo importante — para que tu negocio siga funcionando '
          'aunque no estés mirando el celular.',
      colorAcento: AppColors.botColor,
      capacidades: [
        CapacidadServicio(
          icon: Icons.chat_outlined,
          titulo: 'Bots de WhatsApp',
          descripcion:
              'Tu WhatsApp responde las preguntas frecuentes, toma pedidos y '
              'hasta vende solo — sin que nadie tenga que estar pendiente '
              'del celular todo el día.',
        ),
        CapacidadServicio(
          icon: Icons.storage_outlined,
          titulo: 'Sistemas a medida',
          descripcion:
              'Un lugar único y ordenado para anotar tu inventario, tus '
              'pedidos o tus clientes — como una planilla, pero hecha a tu '
              'medida y mucho más fácil de usar.',
        ),
        CapacidadServicio(
          icon: Icons.auto_mode_outlined,
          titulo: 'Automatización',
          descripcion:
              'Esas tareas que hacés siempre igual — anotar, avisar, '
              'ordenar — las armamos para que se hagan solas. Menos '
              'errores, más tiempo libre para vos.',
        ),
      ],
    );
  }
}
