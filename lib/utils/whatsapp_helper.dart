import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../config/app_config.dart';

/// Genera y abre un enlace de WhatsApp con un mensaje ya redactado y
/// estructurado, dirigido siempre al número de Senka (Admin) — nunca al
/// cliente. La idea: la cotización se guarda en Firestore para que quede
/// registro, y ADEMÁS se le manda un WhatsApp perfectamente ordenado para
/// que Senka entienda de un vistazo qué quiere el cliente y pueda
/// contactarlo para cerrar el pedido manualmente.
class WhatsAppHelper {
  static String _mensajeCotizacion(Cotizacion cotizacion) {
    final buffer = StringBuffer();
    buffer.writeln('🔔 *NUEVA COTIZACIÓN - 57 NATIONS*');
    buffer.writeln('');
    buffer.writeln('👤 *Cliente:* ${cotizacion.nombreCliente}');
    buffer.writeln('📧 *Email:* ${cotizacion.email}');
    buffer.writeln('📱 *Teléfono:* ${cotizacion.telefono}');
    buffer.writeln('');
    buffer.writeln('🛠️ *Servicio:* ${cotizacion.servicio}');
    buffer.writeln('💰 *Presupuesto aprox:* ${cotizacion.presupuesto}');
    buffer.writeln('');
    buffer.writeln('📝 *Descripción del proyecto:*');
    buffer.writeln(cotizacion.descripcion);
    buffer.writeln('');
    buffer.writeln('—');
    buffer.writeln('Enviado automáticamente desde la web de 57 Nations');
    return buffer.toString();
  }

  /// Abre WhatsApp (app o web) con el mensaje de la cotización ya escrito,
  /// dirigido al número de Admin configurado en [AppConfig.whatsappAdminNumero].
  static Future<bool> enviarCotizacionPorWhatsApp(Cotizacion cotizacion) async {
    final mensaje = _mensajeCotizacion(cotizacion);
    final url = Uri.parse(
      'https://wa.me/${AppConfig.whatsappAdminNumero}?text=${Uri.encodeComponent(mensaje)}',
    );

    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Genérico: abre WhatsApp con cualquier número + mensaje ya armado.
  /// Útil, por ejemplo, para que Admin/Luchin le escriban al cliente de un
  /// pedido directamente desde el panel.
  static Future<bool> abrirChat({required String telefono, String mensaje = ''}) async {
    final telefonoLimpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse(
      'https://wa.me/$telefonoLimpio${mensaje.isNotEmpty ? '?text=${Uri.encodeComponent(mensaje)}' : ''}',
    );
    if (await canLaunchUrl(url)) {
      return launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
