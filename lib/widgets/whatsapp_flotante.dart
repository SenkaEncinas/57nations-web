import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/whatsapp_helper.dart';

/// Botón flotante de WhatsApp para TODAS las pantallas públicas (nunca en el
/// panel interno). Verde oficial de WhatsApp — excepción consciente a la
/// paleta de marca porque es el color que cualquier visitante reconoce al
/// instante como "chat directo".
///
/// Uso: `floatingActionButton: const WhatsAppFlotante()` en el Scaffold.
class WhatsAppFlotante extends StatefulWidget {
  const WhatsAppFlotante({super.key});

  static const Color _verdeWhatsApp = Color(0xFF25D366);

  @override
  State<WhatsAppFlotante> createState() => _WhatsAppFlotanteState();
}

class _WhatsAppFlotanteState extends State<WhatsAppFlotante> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Escribinos por WhatsApp',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => WhatsAppHelper.abrirChat(
            telefono: AppConfig.whatsappAdminNumero,
            mensaje: 'Hola! Tengo una consulta sobre 57 Nations.',
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: WhatsAppFlotante._verdeWhatsApp,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: WhatsAppFlotante._verdeWhatsApp
                      .withValues(alpha: _hovered ? 0.5 : 0.3),
                  blurRadius: _hovered ? 20 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: _hovered ? 1.1 : 1.0,
              child: const Icon(Icons.chat, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}
