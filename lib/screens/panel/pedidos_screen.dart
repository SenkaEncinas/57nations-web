import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/whatsapp_helper.dart';

/// Vista completa de pedidos: para Admin y Luchin (permiso 'pedidos.ver_todos').
/// Acá se ve todo: cliente, teléfono, costos, y se controla el avance de
/// estado de la etapa de IMPRESIÓN. La etapa de pintado la maneja Fifi desde
/// su propia pantalla ([PedidosPintadoScreen]).
class PedidosScreen extends StatefulWidget {
  final Usuario usuario;

  const PedidosScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final _firebaseService = FirebaseService();
  List<Pedido> _pedidos = [];
  bool _cargando = true;
  String _filtroEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final pedidos = await _firebaseService.obtenerPedidos();
    setState(() {
      _pedidos = pedidos;
      _cargando = false;
    });
  }

  List<Pedido> get _pedidosFiltrados {
    if (_filtroEstado == 'Todos') return _pedidos;
    return _pedidos.where((p) => p.estado == _filtroEstado).toList();
  }

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
    final isMobile = MediaQuery.of(context).size.width < 900;

    return RefreshIndicator(
      onRefresh: _cargar,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pedidos', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', ...[
                  EstadoPedido.pendiente,
                  EstadoPedido.imprimiendo,
                  EstadoPedido.enPintado,
                  EstadoPedido.listo,
                  EstadoPedido.entregado,
                ]]
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(e),
                            selected: _filtroEstado == e,
                            onSelected: (_) => setState(() => _filtroEstado = e),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            if (_cargando)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else if (_pedidosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text('No hay pedidos en este estado.', style: TextStyle(color: AppColors.textMuted)),
              )
            else
              ..._pedidosFiltrados.map((p) => _PedidoCard(
                    pedido: p,
                    onAvanzar: () => _avanzarEstado(p),
                    onEscribirCliente: () => WhatsAppHelper.abrirChat(telefono: p.clienteTelefono),
                  )),
          ],
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

  Color _colorEstado(String estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return AppColors.warning;
      case EstadoPedido.imprimiendo:
        return AppColors.cianTech;
      case EstadoPedido.enPintado:
        return AppColors.categoriaArte;
      case EstadoPedido.listo:
        return AppColors.success;
      case EstadoPedido.entregado:
        return AppColors.textDim;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final flujo = EstadoPedido.flujoPara(pedido.requierePintado);
    final esUltimoEstado = pedido.estado == flujo.last;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: Text(
                  pedido.descripcionPieza,
                  style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorEstado(pedido.estado).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _colorEstado(pedido.estado)),
                ),
                child: Text(
                  pedido.estado,
                  style: TextStyle(color: _colorEstado(pedido.estado), fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('👤 ${pedido.clienteNombre} · 📱 ${pedido.clienteTelefono}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          if (pedido.requierePintado)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '🎨 Requiere pintado · Colores: ${pedido.coloresPedidos.join(", ")}',
                style: const TextStyle(color: AppColors.categoriaArte, fontSize: 12),
              ),
            ),
          if (pedido.calculo != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Precio de venta: Bs ${pedido.calculo!.precioVenta.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.impresion3dColor, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          if (pedido.fechaEntregaImpresion != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '📅 Entrega estimada (impresión): ${_formatFecha(pedido.fechaEntregaImpresion!)}',
                style: const TextStyle(color: AppColors.textDim, fontSize: 12),
              ),
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEscribirCliente,
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('WhatsApp cliente'),
              ),
              if (!esUltimoEstado)
                ElevatedButton(
                  onPressed: onAvanzar,
                  child: Text('Avanzar a "${flujo[flujo.indexOf(pedido.estado) + 1]}"'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFecha(DateTime f) => '${f.day}/${f.month}/${f.year}';
}
