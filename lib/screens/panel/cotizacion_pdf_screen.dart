import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../models/models.dart';
import '../../services/pdf_cotizacion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

/// Generador de cotizaciones en PDF, disponible para todo el equipo interno
/// (permiso 'cotizaciones.generar') — cada uno cotiza el trabajo de su área
/// (bots, apps, Arduino, impresión 3D, entrenamiento, pintado).
///
/// A PROPÓSITO no se guarda nada de esto en Firestore: el PDF descargado ES
/// el registro de la cotización. Así el precio que ve el cliente nunca
/// cambia por accidente después — si hay que corregir algo, se genera un
/// PDF nuevo. Al salir de esta pantalla (cambiar de sección en el panel) el
/// formulario se descarta solo, sin dejar datos sueltos.
class CotizacionPdfScreen extends StatefulWidget {
  final Usuario usuario;

  const CotizacionPdfScreen({super.key, required this.usuario});

  @override
  State<CotizacionPdfScreen> createState() => _CotizacionPdfScreenState();
}

/// Controladores de un ítem (línea) de la cotización en edición.
class _ItemCotizacionCampos {
  final TextEditingController descripcionCtrl;
  final TextEditingController cantidadCtrl;
  final TextEditingController precioCtrl;

  _ItemCotizacionCampos({
    String descripcion = '',
    String cantidad = '1',
    String precio = '',
  })  : descripcionCtrl = TextEditingController(text: descripcion),
        cantidadCtrl = TextEditingController(text: cantidad),
        precioCtrl = TextEditingController(text: precio);

  double get _cantidadNum => double.tryParse(cantidadCtrl.text.replaceAll(',', '.')) ?? 0;
  double get _precioNum => double.tryParse(precioCtrl.text.replaceAll(',', '.')) ?? 0;
  double get subtotal => _cantidadNum * _precioNum;
  bool get estaVacio => descripcionCtrl.text.trim().isEmpty && _precioNum == 0;

  ItemCotizacionPdf toPdfItem() => ItemCotizacionPdf(
        descripcion:
            descripcionCtrl.text.trim().isEmpty ? 'Ítem sin descripción' : descripcionCtrl.text.trim(),
        cantidad: _cantidadNum,
        precioUnitario: _precioNum,
      );

  void dispose() {
    descripcionCtrl.dispose();
    cantidadCtrl.dispose();
    precioCtrl.dispose();
  }
}

class _CotizacionPdfScreenState extends State<CotizacionPdfScreen> {
  final _clienteNombreCtrl = TextEditingController();
  final _clienteContactoCtrl = TextEditingController();
  final _condicionesCtrl = TextEditingController(
    text: 'Cotización válida por 15 días desde la fecha de emisión. '
        'Precios expresados en bolivianos (Bs). No incluye envío salvo que se indique lo contrario.',
  );

  final List<_ItemCotizacionCampos> _items = [];

  // ===== Calculadora 3D embebida (mismos campos que Calculadora3DScreen) =====
  bool _calculadoraAbierta = false;
  final _cNombrePiezaCtrl = TextEditingController();
  final _cPrecioFilamentoCtrl = TextEditingController(text: '90');
  final _cPesoCtrl = TextEditingController(text: '25');
  final _cHorasCtrl = TextEditingController(text: '3');
  final _cMinutosCtrl = TextEditingController(text: '0');
  final _cPotenciaCtrl = TextEditingController(text: '120');
  final _cPrecioKwhCtrl = TextEditingController(text: '1.23');
  final _cDesgasteCtrl = TextEditingController(text: '10');
  final _cFallosCtrl = TextEditingController(text: '10');
  final _cMargenCtrl = TextEditingController(text: '40');

  @override
  void initState() {
    super.initState();
    _agregarItem();
    for (final c in [_clienteNombreCtrl, _clienteContactoCtrl, _condicionesCtrl]) {
      c.addListener(_refrescar);
    }
    for (final c in [
      _cNombrePiezaCtrl,
      _cPrecioFilamentoCtrl,
      _cPesoCtrl,
      _cHorasCtrl,
      _cMinutosCtrl,
      _cPotenciaCtrl,
      _cPrecioKwhCtrl,
      _cDesgasteCtrl,
      _cFallosCtrl,
      _cMargenCtrl,
    ]) {
      c.addListener(_refrescar);
    }
  }

  @override
  void dispose() {
    _clienteNombreCtrl.dispose();
    _clienteContactoCtrl.dispose();
    _condicionesCtrl.dispose();
    for (final i in _items) {
      i.dispose();
    }
    _cNombrePiezaCtrl.dispose();
    _cPrecioFilamentoCtrl.dispose();
    _cPesoCtrl.dispose();
    _cHorasCtrl.dispose();
    _cMinutosCtrl.dispose();
    _cPotenciaCtrl.dispose();
    _cPrecioKwhCtrl.dispose();
    _cDesgasteCtrl.dispose();
    _cFallosCtrl.dispose();
    _cMargenCtrl.dispose();
    super.dispose();
  }

  /// Redibuja la pantalla (y con eso, la vista previa del PDF).
  void _refrescar() => setState(() {});

  void _agregarItem() {
    final item = _ItemCotizacionCampos();
    for (final c in [item.descripcionCtrl, item.cantidadCtrl, item.precioCtrl]) {
      c.addListener(_refrescar);
    }
    setState(() => _items.add(item));
  }

  void _eliminarItem(_ItemCotizacionCampos item) {
    setState(() => _items.remove(item));
    WidgetsBinding.instance.addPostFrameCallback((_) => item.dispose());
  }

  double _numCalc(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;

  CalculoCostos3D get _calculo => CalculoCostos3D(
        precioFilamento: _numCalc(_cPrecioFilamentoCtrl),
        peso: _numCalc(_cPesoCtrl),
        horas: _numCalc(_cHorasCtrl).toInt(),
        minutos: _numCalc(_cMinutosCtrl).toInt(),
        potencia: _numCalc(_cPotenciaCtrl),
        precioKwh: _numCalc(_cPrecioKwhCtrl),
        desgastePorcentaje: _numCalc(_cDesgasteCtrl),
        fallosPorcentaje: _numCalc(_cFallosCtrl),
        margenPorcentaje: _numCalc(_cMargenCtrl),
      );

  /// Agrega (o completa, si el único ítem está vacío) una línea con el
  /// resultado de la calculadora. El precio queda como texto editable en la
  /// tabla de ítems — si Luchin se equivoca o quiere ajustar, lo cambia ahí
  /// mismo antes de descargar, sin tener que volver a tocar la calculadora.
  void _agregarPiezaDesdeCalculadora() {
    final calculo = _calculo;
    final descripcion = _cNombrePiezaCtrl.text.trim().isEmpty
        ? 'Impresión 3D (${_cPesoCtrl.text}g, ${_cHorasCtrl.text}h ${_cMinutosCtrl.text}min)'
        : _cNombrePiezaCtrl.text.trim();

    setState(() {
      if (_items.length == 1 && _items.first.estaVacio) {
        _items.first.descripcionCtrl.text = descripcion;
        _items.first.precioCtrl.text = calculo.precioVenta.toStringAsFixed(2);
      } else {
        final item = _ItemCotizacionCampos(
          descripcion: descripcion,
          precio: calculo.precioVenta.toStringAsFixed(2),
        );
        for (final c in [item.descripcionCtrl, item.cantidadCtrl, item.precioCtrl]) {
          c.addListener(_refrescar);
        }
        _items.add(item);
      }
      _cNombrePiezaCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pieza agregada a la cotización — revisá el precio antes de descargar.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  double get _total => _items.fold(0.0, (suma, i) => suma + i.subtotal);

  Future<Uint8List> _construirPdf(PdfPageFormat formato) async {
    final validos = _items.where((i) => !i.estaVacio).map((i) => i.toPdfItem()).toList();
    final datos = DatosCotizacionPdf(
      clienteNombre: _clienteNombreCtrl.text.trim(),
      clienteContacto: _clienteContactoCtrl.text.trim(),
      generadoPor: widget.usuario.nombre,
      items: validos.isEmpty
          ? const [ItemCotizacionPdf(descripcion: 'Agregá al menos un ítem', cantidad: 1, precioUnitario: 0)]
          : validos,
      condiciones: _condicionesCtrl.text.trim(),
    );
    return PdfCotizacionService.generar(datos);
  }

  String _bs(double n) => 'Bs ${n.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isCompact(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.panel(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Panel',
            titulo: 'Generar Cotización',
            subtitulo:
                'Armá el PDF con los ítems de tu trabajo — de la Calculadora 3D o '
                'a mano. No se guarda en el sistema: el PDF que descargás es el '
                'registro, así el precio no cambia por accidente después.',
            compacto: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
          isCompact
              ? Column(
                  children: [
                    _buildFormulario(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildPreview(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFormulario()),
                    const SizedBox(width: AppSpacing.xxl),
                    Expanded(flex: 2, child: _buildPreview()),
                  ],
                ),
        ],
      ),
    );
  }

  // ==================== FORMULARIO ====================

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _seccion('CLIENTE', Icons.person_outline, AppColors.violetaPrincipal, [
          _campoTexto(label: 'Nombre del cliente', controller: _clienteNombreCtrl),
          _campoTexto(
            label: 'Teléfono o email (opcional)',
            controller: _clienteContactoCtrl,
          ),
        ]),
        _buildCalculadora3D(),
        _seccion('ÍTEMS DE LA COTIZACIÓN', Icons.receipt_long_outlined, AppColors.violetaPrincipal, [
          ..._items.map((item) => _filaItem(item)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _agregarItem,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('AGREGAR ÍTEM MANUAL'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            ),
          ),
          const Divider(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w700)),
              Text(
                _bs(_total),
                style: const TextStyle(
                    color: AppColors.violetaPrincipal, fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ]),
        _seccion('CONDICIONES', Icons.description_outlined, AppColors.violetaPrincipal, [
          const Text(
            'Se muestra al pie del PDF. Editalo o borralo si no aplica.',
            style: TextStyle(color: AppColors.textDim, fontSize: 11, height: 1.3),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _condicionesCtrl,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            decoration: const InputDecoration(),
          ),
        ]),
      ],
    );
  }

  Widget _buildCalculadora3D() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _calculadoraAbierta = !_calculadoraAbierta),
              child: Row(
                children: [
                  const Icon(Icons.calculate_outlined, size: 16, color: AppColors.impresion3dColor),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'USAR CALCULADORA 3D',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Icon(
                    _calculadoraAbierta ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
            if (_calculadoraAbierta) ...[
              const SizedBox(height: AppSpacing.lg),
              _campoTexto(
                label: 'Nombre de la pieza (opcional)',
                controller: _cNombrePiezaCtrl,
                hint: 'Si lo dejás vacío, se arma un nombre con el peso y el tiempo.',
              ),
              Row(children: [
                Expanded(
                  child: _campoNumero(
                      label: 'Filamento', controller: _cPrecioFilamentoCtrl, unidad: 'Bs/kg'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _campoNumero(label: 'Peso', controller: _cPesoCtrl, unidad: 'g'),
                ),
              ]),
              Row(children: [
                Expanded(
                  child: _campoNumero(label: 'Horas', controller: _cHorasCtrl, unidad: 'h'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _campoNumero(label: 'Minutos', controller: _cMinutosCtrl, unidad: 'min'),
                ),
              ]),
              Row(children: [
                Expanded(
                  child: _campoNumero(label: 'Potencia', controller: _cPotenciaCtrl, unidad: 'W'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _campoNumero(label: 'Precio luz', controller: _cPrecioKwhCtrl, unidad: 'Bs/kWh'),
                ),
              ]),
              Row(children: [
                Expanded(
                  child: _campoNumero(label: 'Desgaste', controller: _cDesgasteCtrl, unidad: '%'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _campoNumero(label: 'Fallos', controller: _cFallosCtrl, unidad: '%'),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _campoNumero(label: 'Margen', controller: _cMargenCtrl, unidad: '%'),
                ),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: ShapeDecoration(
                  color: AppColors.impresion3dColor.withValues(alpha: 0.08),
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    side: BorderSide(color: AppColors.impresion3dColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Precio de venta sugerido',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    Text(
                      _bs(_calculo.precioVenta),
                      style: const TextStyle(
                          color: AppColors.impresion3dColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _agregarPiezaDesdeCalculadora,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('AGREGAR ESTA PIEZA A LA COTIZACIÓN'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _filaItem(_ItemCotizacionCampos item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const ShapeDecoration(
          color: AppColors.surface,
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            side: BorderSide(color: AppColors.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: item.descripcionCtrl,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  tooltip: 'Eliminar ítem',
                  onPressed: () => _eliminarItem(item),
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: item.cantidadCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Cant.'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: item.precioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Precio unitario (Bs)'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Subtotal',
                          style: TextStyle(color: AppColors.textDim, fontSize: 10)),
                      Text(
                        _bs(item.subtotal),
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, IconData icon, Color color, List<Widget> hijos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
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
            ...hijos,
          ],
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textLight),
            decoration: InputDecoration(labelText: label),
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(hint,
                  style: const TextStyle(color: AppColors.textDim, fontSize: 11, height: 1.3)),
            ),
        ],
      ),
    );
  }

  Widget _campoNumero({
    required String label,
    required TextEditingController controller,
    required String unidad,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textLight, fontSize: 13),
        decoration: InputDecoration(labelText: label, suffixText: unidad),
      ),
    );
  }

  // ==================== PREVIEW ====================

  Widget _buildPreview() {
    return TechCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.violetaPrincipal),
              SizedBox(width: AppSpacing.sm),
              Text(
                'VISTA PREVIA DEL PDF',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 780,
            child: PdfPreview(
              build: _construirPdf,
              initialPageFormat: PdfPageFormat.a4,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              allowPrinting: true,
              allowSharing: true,
              pdfFileName:
                  'cotizacion_57nations_${DateTime.now().millisecondsSinceEpoch}.pdf',
              loadingWidget: const Center(
                child: EstadoCargando(mensaje: 'Armando el PDF...'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
