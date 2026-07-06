import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../widgets/widgets.dart';

/// Formulario para crear un pedido real en el sistema.
/// Solo lo usan Admin y Luchin (permiso 'pedidos.crear'), después de que el
/// cliente ya escribió por WhatsApp (a partir de una cotización o directo).
/// Los clientes NUNCA crean pedidos ellos mismos.
class CrearPedidoScreen extends StatefulWidget {
  final Usuario usuario;

  const CrearPedidoScreen({super.key, required this.usuario});

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

  String _origenPedido = OrigenPedido.senka;
  bool _aplicaComisionLuchin = true;
  final _comisionPorcentajeCtrl =
      TextEditingController(text: ComisionLuchin.porcentajeDefault.toString());

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

  List<Listenable> get _controlesCalculo => [
        _precioFilamentoCtrl,
        _pesoCtrl,
        _horasCtrl,
        _minutosCtrl,
        _potenciaCtrl,
        _precioKwhCtrl,
        _desgasteCtrl,
        _fallosCtrl,
        _margenCtrl,
      ];

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
        origenPedido: _origenPedido,
        comisionLuchin: _origenPedido == OrigenPedido.luchin
            ? ComisionLuchin.calcular(
                aplica: _aplicaComisionLuchin,
                porcentaje: double.tryParse(_comisionPorcentajeCtrl.text) ??
                    ComisionLuchin.porcentajeDefault,
                ganancia: _calculo.ganancia,
              )
            : null,
      );

      await _firebaseService.crearPedido(pedido);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Pedido creado correctamente'),
              backgroundColor: AppColors.success),
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
      _origenPedido = OrigenPedido.senka;
      _aplicaComisionLuchin = true;
      _comisionPorcentajeCtrl.text = ComisionLuchin.porcentajeDefault.toString();
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
      _comisionPorcentajeCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.panel(context)),
      child: Form(
        key: _formKey,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxFormWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                overline: 'Panel',
                titulo: 'Nuevo Pedido',
                subtitulo:
                    'Cargá el pedido después de confirmar todo con el cliente por WhatsApp.',
                compacto: true,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ===== CLIENTE Y PIEZA =====
              _SeccionFormulario(
                titulo: 'CLIENTE Y PIEZA',
                icon: Icons.person_outline,
                children: [
                  _campo('Nombre del cliente', _clienteNombreCtrl, requerido: true),
                  _campo('Teléfono (WhatsApp)', _clienteTelefonoCtrl, requerido: true),
                  _campo('Descripción de la pieza', _descripcionCtrl, lineas: 3, requerido: true),
                  _campo('URL de foto de referencia (opcional)', _fotoUrlCtrl),
                ],
              ),

              // ===== PINTADO =====
              _SeccionFormulario(
                titulo: 'PINTADO',
                icon: Icons.brush_outlined,
                accentColor: AppColors.categoriaArte,
                children: [
                  SwitchListTile(
                    value: _requierePintado,
                    onChanged: (v) => setState(() => _requierePintado = v),
                    title: const Text('¿Requiere pintado?',
                        style: TextStyle(color: AppColors.textLight)),
                    subtitle: const Text(
                      'Si se activa, el pedido pasará por la etapa "En Pintado" con Fifi.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    activeThumbColor: AppColors.categoriaArte,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_requierePintado)
                    _campo('Colores pedidos (separados por coma)', _coloresCtrl),
                ],
              ),

              // ===== ORIGEN Y COMISIÓN =====
              _SeccionFormulario(
                titulo: 'ORIGEN DEL PEDIDO',
                icon: Icons.handshake_outlined,
                accentColor: AppColors.flutterColor,
                children: [
                  Wrap(
                    spacing: AppSpacing.md,
                    children: [
                      ChoiceChip(
                        label: const Text('Senka'),
                        selected: _origenPedido == OrigenPedido.senka,
                        onSelected: (_) =>
                            setState(() => _origenPedido = OrigenPedido.senka),
                      ),
                      ChoiceChip(
                        label: const Text('Luchin'),
                        selected: _origenPedido == OrigenPedido.luchin,
                        onSelected: (_) =>
                            setState(() => _origenPedido = OrigenPedido.luchin),
                      ),
                    ],
                  ),
                  if (_origenPedido == OrigenPedido.luchin) ...[
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile(
                      value: _aplicaComisionLuchin,
                      onChanged: (v) => setState(() => _aplicaComisionLuchin = v),
                      title: const Text('¿Aplica comisión?',
                          style: TextStyle(color: AppColors.textLight)),
                      activeThumbColor: AppColors.flutterColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_aplicaComisionLuchin) ...[
                      _campoNumero('Comisión Luchin (%)', _comisionPorcentajeCtrl),
                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [_comisionPorcentajeCtrl, ..._controlesCalculo]),
                        builder: (context, _) {
                          final porcentaje =
                              double.tryParse(_comisionPorcentajeCtrl.text) ??
                                  ComisionLuchin.porcentajeDefault;
                          final monto = _calculo.ganancia * (porcentaje / 100);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Comisión estimada',
                                  style: TextStyle(color: AppColors.textLight)),
                              Text(
                                'Bs ${monto.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppColors.flutterColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ],
              ),

              // ===== FECHA ESTIMADA =====
              _SeccionFormulario(
                titulo: 'ENTREGA',
                icon: Icons.event_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fecha estimada de entrega (impresión)',
                                style: TextStyle(color: AppColors.textLight)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _fechaEntregaImpresion != null
                                  ? '${_fechaEntregaImpresion!.day}/${_fechaEntregaImpresion!.month}/${_fechaEntregaImpresion!.year}'
                                  : 'Sin definir',
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _seleccionarFecha,
                        icon: const Icon(Icons.calendar_month_outlined, size: 16),
                        label: const Text('ELEGIR FECHA'),
                      ),
                    ],
                  ),
                ],
              ),

              // ===== COSTOS =====
              _SeccionFormulario(
                titulo: 'COSTOS (CALCULADORA 3D)',
                icon: Icons.calculate_outlined,
                accentColor: AppColors.impresion3dColor,
                children: [
                  Row(children: [
                    Expanded(child: _campoNumero('Filamento (Bs/kg)', _precioFilamentoCtrl)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _campoNumero('Peso (g)', _pesoCtrl)),
                  ]),
                  Row(children: [
                    Expanded(child: _campoNumero('Horas', _horasCtrl)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _campoNumero('Minutos', _minutosCtrl)),
                  ]),
                  Row(children: [
                    Expanded(child: _campoNumero('Potencia (W)', _potenciaCtrl)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _campoNumero('Bs/kWh', _precioKwhCtrl)),
                  ]),
                  Row(children: [
                    Expanded(child: _campoNumero('Desgaste %', _desgasteCtrl)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _campoNumero('Fallos %', _fallosCtrl)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _campoNumero('Margen %', _margenCtrl)),
                  ]),
                  const Divider(height: AppSpacing.xl),
                  AnimatedBuilder(
                    animation: Listenable.merge(_controlesCalculo),
                    builder: (context, _) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Precio de venta sugerido',
                            style: TextStyle(color: AppColors.textLight)),
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

              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardarPedido,
                  icon: _guardando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.textLight)),
                        )
                      : const Icon(Icons.add_circle_outline, size: 18),
                  label: Text(_guardando ? 'GUARDANDO...' : 'CREAR PEDIDO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {int lineas = 1, bool requerido = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextFormField(
        controller: ctrl,
        maxLines: lineas,
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(labelText: label),
        validator:
            requerido ? (v) => (v?.isEmpty ?? true) ? 'Campo requerido' : null : null,
      ),
    );
  }

  Widget _campoNumero(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textLight, fontSize: 13),
        decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
      ),
    );
  }
}

/// Bloque visual del formulario: título con ícono + campos dentro de TechCard.
class _SeccionFormulario extends StatelessWidget {
  final String titulo;
  final IconData icon;
  final Color? accentColor;
  final List<Widget> children;

  const _SeccionFormulario({
    required this.titulo,
    required this.icon,
    this.accentColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final acento = accentColor ?? AppColors.violetaPrincipal;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: acento),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ...children,
          ],
        ),
      ),
    );
  }
}
