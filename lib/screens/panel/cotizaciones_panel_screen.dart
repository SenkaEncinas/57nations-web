import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/whatsapp_helper.dart';
import '../../widgets/widgets.dart';

/// Lista de cotizaciones que llegaron desde el formulario público de la web.
/// Acá Admin revisa, contacta al cliente y decide si conviene convertirla
/// en un Pedido real (desde la pantalla "Nuevo Pedido").
class CotizacionesPanelScreen extends StatefulWidget {
  const CotizacionesPanelScreen({super.key});

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
        _error = 'No pudimos cargar las cotizaciones. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return RefreshIndicator(
      onRefresh: _cargar,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cotizaciones desde la web', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            const Text(
              'Estos son formularios que llenaron clientes en la web. Contactalos y, si conviene, cargá el pedido en "Nuevo Pedido".',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
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

  const _CotizacionCard({required this.cotizacion, required this.onEscribir});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cotizacion.nombreCliente,
                  style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16)),
              Chip(
                label: Text(cotizacion.servicio, style: const TextStyle(fontSize: 11)),
                backgroundColor: AppColors.violetaPrincipal.withValues(alpha: 0.15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('📱 ${cotizacion.telefono}  ·  📧 ${cotizacion.email}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          Text(cotizacion.descripcion, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(height: 8),
          Text('💰 Presupuesto: ${cotizacion.presupuesto}',
              style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onEscribir,
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('Escribirle por WhatsApp'),
          ),
        ],
      ),
    );
  }
}
