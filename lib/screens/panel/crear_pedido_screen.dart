import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';

/// Formulario para crear un pedido real en el sistema.
/// Solo lo usan Admin y Luchin (permiso 'pedidos.crear'), después de que el
/// cliente ya escribió por WhatsApp (a partir de una cotización o directo).
/// Los clientes NUNCA crean pedidos ellos mismos.
class CrearPedidoScreen extends StatefulWidget {
  final Usuario usuario;

  const CrearPedidoScreen({Key? key, required this.usuario}) : super(key: key);

  @override
  State<CrearPedidoScreen> createState() => _CrearPedidoScreenState();
}

class _CrearPedidoScreenState extends State<CrearPedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final _clienteNombreCtrl = TextEditingController();
  final _clienteTelefonoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _fotoUrlCtrl = TextEditingController();
  final _coloresCtrl = TextEditingController();

  // Campos de la calculadora (mismos que Calculadora3DScreen)
  final _precioFilamentoCtrl = TextEditingController(text: '90');
  final _pesoCtrl = TextEditingController(text: '25');
  final _horasCtrl = TextEditingController(text: '3');
  final _minutosCtrl = TextEditingController(text: '0');
  final _potenciaCtrl = TextEditingController(text: '120');
  final _precioKwhCtrl = TextEditingController(text: '1.23');
  final _desgasteCtrl = TextEditingController(text: '10');
  final _fallosCtrl = TextEditingController(text: '10');
  final _margenCtrl = TextEditingController(text: '40');

  bool _requierePintado = false;
  DateTime? _fechaEntregaImpresion;
  bool _guardando = false;

  double _num(TextEditingController c) => double.tryParse(c.text) ?? 0;

  CalculoCostos3D get _calculo => CalculoCostos3D(
        precioFilamento: _num(_precioFilamentoCtrl),
        peso: _num(_pesoCtrl),
        horas: _num(_horasCtrl).toInt(),
        minutos: _num(_minutosCtrl).toInt(),
        potencia: _num(_potenciaCtrl),
        precioKwh: _num(_precioKwhCtrl),
        desgastePorcentaje: _num(_desgasteCtrl),
        fallosPorcentaje: _num(_fallosCtrl),
        margenPorcentaje: _num(_margenCtrl),
      );

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: '¿Para cuándo estimás la entrega de impresión?',
    );
    if (fecha != null) setState(() => _fechaEntregaImpresion = fecha);
  }

  Future<void> _guardarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      final pedido = Pedido(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clienteNombre: _clienteNombreCtrl.text.trim(),
        clienteTelefono: _clienteTelefonoCtrl.text.trim(),
        descripcionPieza: _descripcionCtrl.text.trim(),
        fotos: _fotoUrlCtrl.text.trim().isEmpty ? [] : [_fotoUrlCtrl.text.trim()],
        requierePintado: _requierePintado,
        coloresPedidos: _requierePintado
            ? _coloresCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
            : [],
        estado: EstadoPedido.pendiente,
        calculo: _calculo,
        fechaEntregaImpresion: _fechaEntregaImpresion,
        creadoPorUsername: widget.usuario.username,
        fechaCreacion: DateTime.now(),
      );

      await _firebaseService.crearPedido(pedido);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido creado correctamente'), backgroundColor: AppColors.success),
        );
        _limpiarFormulario();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _limpiarFormulario() {
    _clienteNombreCtrl.clear();
    _clienteTelefonoCtrl.clear();
    _descripcionCtrl.clear();
    _fotoUrlCtrl.clear();
    _coloresCtrl.clear();
    setState(() {
      _requierePintado = false;
      _fechaEntregaImpresion = null;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _clienteNombreCtrl,
      _clienteTelefonoCtrl,
      _descripcionCtrl,
      _fotoUrlCtrl,
      _coloresCtrl,
      _precioFilamentoCtrl,
      _pesoCtrl,
      _horasCtrl,
      _minutosCtrl,
      _potenciaCtrl,
      _precioKwhCtrl,
      _desgasteCtrl,
      _fallosCtrl,
      _margenCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuevo Pedido', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              const Text(
                'Cargá el pedido después de confirmar todo con el cliente por WhatsApp.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              _campo('Nombre del cliente', _clienteNombreCtrl, requerido: true),
              _campo('Teléfono (WhatsApp)', _clienteTelefonoCtrl, requerido: true),
              _campo('Descripción de la pieza', _descripcionCtrl, lineas: 3, requerido: true),
              _campo('URL de foto de referencia (opcional)', _fotoUrlCtrl),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _requierePintado,
                onChanged: (v) => setState(() => _requierePintado = v),
                title: const Text('¿Requiere pintado?', style: TextStyle(color: AppColors.textLight)),
                subtitle: const Text(
                  'Si se activa, el pedido pasará por la etapa "En Pintado" con Fifi.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                activeColor: AppColors.categoriaArte,
                contentPadding: EdgeInsets.zero,
              ),
              if (_requierePintado)
                _campo('Colores pedidos (separados por coma)', _coloresCtrl),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha estimada de entrega (impresión)', style: TextStyle(color: AppColors.textLight)),
                subtitle: Text(
                  _fechaEntregaImpresion != null
                      ? '${_fechaEntregaImpresion!.day}/${_fechaEntregaImpresion!.month}/${_fechaEntregaImpresion!.year}'
                      : 'Sin definir',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: OutlinedButton(
                  onPressed: _seleccionarFecha,
                  child: const Text('Elegir fecha'),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COSTOS (calculadora 3D)',
                      style: TextStyle(color: AppColors.textDim, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _campoNumero('Filamento (Bs/kg)', _precioFilamentoCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _campoNumero('Peso (g)', _pesoCtrl)),
                    ]),
                    Row(children: [
                      Expanded(child: _campoNumero('Horas', _horasCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _campoNumero('Minutos', _minutosCtrl)),
                    ]),
                    Row(children: [
                      Expanded(child: _campoNumero('Potencia (W)', _potenciaCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _campoNumero('Bs/kWh', _precioKwhCtrl)),
                    ]),
                    Row(children: [
                      Expanded(child: _campoNumero('Desgaste %', _desgasteCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _campoNumero('Fallos %', _fallosCtrl)),
                      const SizedBox(width: 12),
                      Expanded(child: _campoNumero('Margen %', _margenCtrl)),
                    ]),
                    const Divider(color: AppColors.border, height: 24),
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _precioFilamentoCtrl,
                        _pesoCtrl,
                        _horasCtrl,
                        _minutosCtrl,
                        _potenciaCtrl,
                        _precioKwhCtrl,
                        _desgasteCtrl,
                        _fallosCtrl,
                        _margenCtrl,
                      ]),
                      builder: (context, _) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Precio de venta sugerido', style: TextStyle(color: AppColors.textLight)),
                          Text(
                            'Bs ${_calculo.precioVenta.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.impresion3dColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _guardando ? null : _guardarPedido,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                      )
                    : const Text('CREAR PEDIDO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl, {int lineas = 1, bool requerido = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: lineas,
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(labelText: label),
        validator: requerido ? (v) => (v?.isEmpty ?? true) ? 'Campo requerido' : null : null,
      ),
    );
  }

  Widget _campoNumero(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textLight, fontSize: 13),
        decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
      ),
    );
  }
}
