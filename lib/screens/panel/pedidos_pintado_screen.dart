import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
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
    final pendientes = _pedidos.where((p) => p.estado == EstadoPedido.enPintado).toList();
    final terminados = _pedidos.where((p) => p.estado != EstadoPedido.enPintado).toList();

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
              titulo: 'Pendientes de Pintar',
              subtitulo: 'Solo se muestra lo necesario: pieza, foto, colores y fecha límite.',
              accentColor: AppColors.categoriaArte,
              compacto: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_cargando)
              const EstadoCargando(mensaje: 'Cargando piezas...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else if (pendientes.isEmpty)
              const EstadoVacio(
                icon: Icons.brush_outlined,
                mensaje: 'No tenés piezas pendientes de pintar. ¡Buen trabajo!',
              )
            else
              ...pendientes.map((p) => _PiezaPintadoCard(
                    pedido: p,
                    onPonerFecha: () => _ponerFechaEstimada(p),
                    onMarcarListo: () => _marcarPintadoListo(p),
                  )),
            if (terminados.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              Text('Ya entregadas / terminadas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        accentColor: AppColors.categoriaArte,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO en marco recortado
            Container(
              width: 80,
              height: 80,
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: AppTheme.cutCorner(
                  size: AppTheme.cutSizeSm,
                  side: BorderSide(
                    color: terminada
                        ? AppColors.border
                        : AppColors.categoriaArte.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: pedido.fotos.isNotEmpty
                  ? Image.network(pedido.fotos.first, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, color: AppColors.textDim),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          pedido.descripcionPieza,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (terminada)
                        StatusBadge.pedido(pedido.estado),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: pedido.coloresPedidos
                        .map((c) => StatusBadge(texto: c, color: AppColors.categoriaArte))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (pedido.fechaEntregaPintado != null)
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          'Fecha límite: ${_formatFecha(pedido.fechaEntregaPintado!)}',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  else if (!terminada)
                    const Text(
                      'Sin fecha estimada todavía',
                      style: TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                  if (!terminada) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onPonerFecha,
                          icon: const Icon(Icons.event_outlined, size: 16),
                          label: const Text('FECHA ESTIMADA'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: onMarcarListo,
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('MARCAR PINTADO'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.negroProfundo,
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime f) => '${f.day}/${f.month}/${f.year}';
}
