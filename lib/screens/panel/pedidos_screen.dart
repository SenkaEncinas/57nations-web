import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/whatsapp_helper.dart';
import '../../widgets/widgets.dart';

/// Vista completa de pedidos: para Admin y Luchin (permiso 'pedidos.ver_todos').
/// Acá se ve todo: cliente, teléfono, costos, y se controla el avance de
/// estado de la etapa de IMPRESIÓN. La etapa de pintado la maneja Fifi desde
/// su propia pantalla ([PedidosPintadoScreen]).
class PedidosScreen extends StatefulWidget {
  final Usuario usuario;

  const PedidosScreen({super.key, required this.usuario});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final _firebaseService = FirebaseService();
  List<Pedido> _pedidos = [];
  bool _cargando = true;
  String? _error;
  String _filtroEstado = 'Todos';

  static const _estados = [
    EstadoPedido.pendiente,
    EstadoPedido.imprimiendo,
    EstadoPedido.enPintado,
    EstadoPedido.listo,
    EstadoPedido.entregado,
  ];

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
      final pedidos = await _firebaseService.obtenerPedidos();
      setState(() {
        _pedidos = pedidos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar los pedidos. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  List<Pedido> get _pedidosFiltrados {
    if (_filtroEstado == 'Todos') return _pedidos;
    return _pedidos.where((p) => p.estado == _filtroEstado).toList();
  }

  int _cuenta(String estado) => _pedidos.where((p) => p.estado == estado).length;

  Future<void> _avanzarEstado(Pedido pedido) async {
    final flujo = EstadoPedido.flujoPara(pedido.requierePintado);
    final indiceActual = flujo.indexOf(pedido.estado);
    if (indiceActual == -1 || indiceActual >= flujo.length - 1) return;

    final siguienteEstado = flujo[indiceActual + 1];

    // Si el siguiente estado es "Imprimiendo -> Listo/EnPintado" pedir fecha estimada
    DateTime? fechaEntrega;
    if (siguienteEstado == EstadoPedido.imprimiendo) {
      fechaEntrega = await _pedirFecha('¿Para cuándo estimás terminar la impresión?');
      if (fechaEntrega == null) return;
    }

    final marcaImpresionCompletada = siguienteEstado == EstadoPedido.enPintado ||
        (siguienteEstado == EstadoPedido.listo && !pedido.requierePintado);

    await _firebaseService.actualizarPedido(pedido.id, {
      'estado': siguienteEstado,
      if (fechaEntrega != null) 'fechaEntregaImpresion': fechaEntrega,
      if (marcaImpresionCompletada) 'fechaImpresionCompletada': DateTime.now(),
    });

    _cargar();
  }

  Future<DateTime?> _pedirFecha(String titulo) async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: titulo,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              titulo: 'Pedidos',
              subtitulo: 'Controlá el avance de cada pieza, de Pendiente a Entregado.',
              compacto: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Resumen por estado (solo UI, cuenta sobre los pedidos ya cargados)
            if (!_cargando && _error == null) ...[
              _ResumenEstados(
                total: _pedidos.length,
                cuentas: {for (final e in _estados) e: _cuenta(e)},
                seleccionado: _filtroEstado,
                onSeleccionar: (e) => setState(() => _filtroEstado = e),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            if (_cargando)
              const EstadoCargando(mensaje: 'Cargando pedidos...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else if (_pedidosFiltrados.isEmpty)
              const EstadoVacio(
                  icon: Icons.inventory_2_outlined, mensaje: 'No hay pedidos en este estado.')
            else
              ..._pedidosFiltrados.map((p) => _PedidoCard(
                    pedido: p,
                    onAvanzar: () => _avanzarEstado(p),
                    onEscribirCliente: () =>
                        WhatsAppHelper.abrirChat(telefono: p.clienteTelefono),
                  )),
          ],
        ),
      ),
    );
  }
}

/// Tarjetas-resumen clickeables que además funcionan como filtro.
class _ResumenEstados extends StatelessWidget {
  final int total;
  final Map<String, int> cuentas;
  final String seleccionado;
  final ValueChanged<String> onSeleccionar;

  const _ResumenEstados({
    required this.total,
    required this.cuentas,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatChip(
            label: 'Todos',
            cuenta: total,
            color: AppColors.violetaPrincipal,
            seleccionado: seleccionado == 'Todos',
            onTap: () => onSeleccionar('Todos'),
          ),
          ...cuentas.entries.map(
            (e) => _StatChip(
              label: e.key,
              cuenta: e.value,
              color: colorEstadoPedido(e.key),
              seleccionado: seleccionado == e.key,
              onTap: () => onSeleccionar(e.key),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int cuenta;
  final Color color;
  final bool seleccionado;
  final VoidCallback onTap;

  const _StatChip({
    required this.label,
    required this.cuenta,
    required this.color,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: ShapeDecoration(
              color: seleccionado ? color.withValues(alpha: 0.14) : AppColors.surfaceElevated,
              shape: BeveledRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                side: BorderSide(color: seleccionado ? color : AppColors.border),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$cuenta',
                  style: TextStyle(
                    color: seleccionado ? color : AppColors.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: seleccionado ? color : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onAvanzar;
  final VoidCallback onEscribirCliente;

  const _PedidoCard({
    required this.pedido,
    required this.onAvanzar,
    required this.onEscribirCliente,
  });

  @override
  Widget build(BuildContext context) {
    final flujo = EstadoPedido.flujoPara(pedido.requierePintado);
    final esUltimoEstado = pedido.estado == flujo.last;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        accentColor: colorEstadoPedido(pedido.estado),
        padding: const EdgeInsets.all(AppSpacing.xl),
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
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                StatusBadge.pedido(pedido.estado),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Stepper visual del flujo del pedido
            SizedBox(
              width: 220,
              child: FlujoPedidoStepper(pedido: pedido),
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoFila(
              icon: Icons.person_outline,
              texto: '${pedido.clienteNombre} · ${pedido.clienteTelefono}',
            ),
            if (pedido.origenPedido == OrigenPedido.luchin)
              _InfoFila(
                icon: Icons.handshake_outlined,
                color: AppColors.flutterColor,
                texto: pedido.comisionLuchin?.aplica == true
                    ? 'Origen: Luchin · Comisión ${pedido.comisionLuchin!.porcentaje.toStringAsFixed(0)}% = Bs ${pedido.comisionLuchin!.monto.toStringAsFixed(2)}'
                    : 'Origen: Luchin · Sin comisión',
              ),
            if (pedido.requierePintado)
              _InfoFila(
                icon: Icons.brush_outlined,
                color: AppColors.categoriaArte,
                texto: 'Requiere pintado · Colores: ${pedido.coloresPedidos.join(", ")}',
              ),
            if (pedido.calculo != null)
              _InfoFila(
                icon: Icons.sell_outlined,
                color: AppColors.impresion3dColor,
                texto: 'Precio de venta: Bs ${pedido.calculo!.precioVenta.toStringAsFixed(2)}',
                destacado: true,
              ),
            if (pedido.fechaEntregaImpresion != null)
              _InfoFila(
                icon: Icons.event_outlined,
                texto:
                    'Entrega estimada (impresión): ${_formatFecha(pedido.fechaEntregaImpresion!)}',
              ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: onEscribirCliente,
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('WHATSAPP CLIENTE'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                ),
                if (!esUltimoEstado)
                  ElevatedButton.icon(
                    onPressed: onAvanzar,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(
                        'AVANZAR A "${flujo[flujo.indexOf(pedido.estado) + 1].toUpperCase()}"'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime f) => '${f.day}/${f.month}/${f.year}';
}

/// Fila de dato con ícono, reemplaza los emojis sueltos de la versión anterior.
class _InfoFila extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color? color;
  final bool destacado;

  const _InfoFila({
    required this.icon,
    required this.texto,
    this.color,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: c),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: destacado ? c : AppColors.textMuted,
                fontSize: 13,
                height: 1.5,
                fontWeight: destacado ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
