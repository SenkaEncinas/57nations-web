import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/whatsapp_helper.dart';
import '../../widgets/widgets.dart';

/// Lista de cotizaciones que llegaron desde el formulario público de la web.
/// Acá Admin revisa, contacta al cliente y decide si conviene convertirla
/// en un Pedido real (desde la pantalla "Nuevo Pedido"). Borrar cotizaciones
/// requiere el permiso 'cotizaciones.eliminar' (implícito en admin.total).
class CotizacionesPanelScreen extends StatefulWidget {
  final Usuario usuario;

  const CotizacionesPanelScreen({super.key, required this.usuario});

  @override
  State<CotizacionesPanelScreen> createState() => _CotizacionesPanelScreenState();
}

class _CotizacionesPanelScreenState extends State<CotizacionesPanelScreen> {
  final _firebaseService = FirebaseService();
  List<Cotizacion> _cotizaciones = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final cotizaciones = await _firebaseService.obtenerCotizaciones();
      setState(() {
        _cotizaciones = cotizaciones;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = mensajeErrorCarga(e, queCargaba: 'las cotizaciones');
        _cargando = false;
      });
    }
  }

  Future<void> _confirmarEliminar(Cotizacion cotizacion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cotización?',
            style: TextStyle(color: AppColors.textLight)),
        content: Text(
          'Esto borra la cotización de "${cotizacion.nombreCliente}" para siempre. '
          'No se puede deshacer.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _firebaseService.eliminarCotizacion(cotizacion.id);
      _cargar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No se pudo eliminar: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final puedeEliminar = widget.usuario.tienePermiso('cotizaciones.eliminar');

    return RefreshIndicator(
      onRefresh: _cargar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.panel(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              overline: 'Panel',
              titulo: 'Cotizaciones desde la web',
              subtitulo:
                  'Formularios que llenaron clientes en la web. Contactalos y, si conviene, '
                  'cargá el pedido en "Nuevo Pedido".',
              compacto: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_cargando)
              const EstadoCargando(mensaje: 'Cargando cotizaciones...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else if (_cotizaciones.isEmpty)
              const EstadoVacio(icon: Icons.mail_outline, mensaje: 'No hay cotizaciones todavía.')
            else
              ..._cotizaciones.map((c) => _CotizacionCard(
                    cotizacion: c,
                    onEscribir: () => WhatsAppHelper.abrirChat(telefono: c.telefono),
                    onEliminar: puedeEliminar ? () => _confirmarEliminar(c) : null,
                  )),
          ],
        ),
      ),
    );
  }
}

class _CotizacionCard extends StatelessWidget {
  final Cotizacion cotizacion;
  final VoidCallback onEscribir;

  /// null = quien mira no tiene permiso para eliminar (no se muestra el botón).
  final VoidCallback? onEliminar;

  const _CotizacionCard({
    required this.cotizacion,
    required this.onEscribir,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    cotizacion.nombreCliente,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                StatusBadge(texto: cotizacion.servicio, color: AppColors.violetaPrincipal),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _dato(Icons.phone_outlined, cotizacion.telefono),
            _dato(Icons.email_outlined, cotizacion.email),
            _dato(Icons.payments_outlined, 'Presupuesto: ${cotizacion.presupuesto}'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              cotizacion.descripcion,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onEscribir,
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('ESCRIBIRLE POR WHATSAPP'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                ),
                const Spacer(),
                if (onEliminar != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error, size: 20),
                    tooltip: 'Eliminar cotización',
                    onPressed: onEliminar,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(IconData icon, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textDim),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
