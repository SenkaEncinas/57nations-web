import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../widgets/widgets.dart';

/// Vista de Fifi (permiso 'pedidos.ver_pintado').
/// A propósito NO muestra cliente, teléfono ni precio — solo lo que necesita
/// para pintar: la pieza, la foto, los colores pedidos y la fecha límite.
class PedidosPintadoScreen extends StatefulWidget {
  final Usuario usuario;

  const PedidosPintadoScreen({super.key, required this.usuario});

  @override
  State<PedidosPintadoScreen> createState() => _PedidosPintadoScreenState();
}

class _PedidosPintadoScreenState extends State<PedidosPintadoScreen> {
  final _firebaseService = FirebaseService();
  List<Pedido> _pedidos = [];
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
      final pedidos = await _firebaseService.obtenerPedidosParaPintado();
      setState(() {
        _pedidos = pedidos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar las piezas. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  Future<void> _marcarPintadoListo(Pedido pedido) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: 'Fecha en que termina el pintado',
    );
    if (fecha == null) return;

    await _firebaseService.actualizarPedido(pedido.id, {
      'estado': EstadoPedido.listo,
      'fechaPintadoCompletado': fecha,
    });
    _cargar();
  }

  Future<void> _ponerFechaEstimada(Pedido pedido) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      helpText: '¿Para cuándo estimás terminar el pintado?',
    );
    if (fecha == null) return;

    await _firebaseService.actualizarPedido(pedido.id, {
      'fechaEntregaPintado': fecha,
    });
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final pendientes = _pedidos.where((p) => p.estado == EstadoPedido.enPintado).toList();
    final terminados = _pedidos.where((p) => p.estado != EstadoPedido.enPintado).toList();

    return RefreshIndicator(
      onRefresh: _cargar,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pendientes de Pintar', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.categoriaArte,
                )),
            const SizedBox(height: 4),
            const Text(
              'Solo se muestra lo necesario: pieza, foto, colores y fecha límite.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            if (_cargando)
              const EstadoCargando(mensaje: 'Cargando piezas...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else if (pendientes.isEmpty)
              const EstadoVacio(
                icon: Icons.brush_outlined,
                mensaje: '🎉 No tenés piezas pendientes de pintar.',
              )
            else
              ...pendientes.map((p) => _PiezaPintadoCard(
                    pedido: p,
                    onPonerFecha: () => _ponerFechaEstimada(p),
                    onMarcarListo: () => _marcarPintadoListo(p),
                  )),
            if (terminados.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('Ya entregadas / terminadas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...terminados.map((p) => _PiezaPintadoCard(pedido: p, terminada: true)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PiezaPintadoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback? onPonerFecha;
  final VoidCallback? onMarcarListo;
  final bool terminada;

  const _PiezaPintadoCard({
    required this.pedido,
    this.onPonerFecha,
    this.onMarcarListo,
    this.terminada = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: terminada ? AppColors.border : AppColors.categoriaArte.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FOTO
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: AppColors.surface,
              child: pedido.fotos.isNotEmpty
                  ? Image.network(pedido.fotos.first, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, color: AppColors.textDim),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.descripcionPieza,
                  style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: pedido.coloresPedidos
                      .map((c) => Chip(
                            label: Text(c, style: const TextStyle(fontSize: 11)),
                            backgroundColor: AppColors.categoriaArte.withValues(alpha: 0.15),
                            side: BorderSide(color: AppColors.categoriaArte.withValues(alpha: 0.4)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                if (pedido.fechaEntregaPintado != null)
                  Text(
                    '📅 Fecha límite: ${_formatFecha(pedido.fechaEntregaPintado!)}',
                    style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
                  )
                else if (!terminada)
                  const Text(
                    'Sin fecha estimada todavía',
                    style: TextStyle(color: AppColors.textDim, fontSize: 12),
                  ),
                if (!terminada) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: onPonerFecha,
                        child: const Text('Poner fecha estimada'),
                      ),
                      ElevatedButton(
                        onPressed: onMarcarListo,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                        child: const Text('Marcar pintado ✓'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime f) => '${f.day}/${f.month}/${f.year}';
}
