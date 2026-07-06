import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';

/// Calculadora de costos de impresión 3D.
/// Réplica 1:1 de la lógica de `calculadora-3d.html`:
///   costoMaterial   = (peso/1000) * precioFilamento
///   costoElectrico  = (potencia/1000) * tiempoHoras * precioKwh
///   subtotal        = costoMaterial + costoElectrico
///   costoDesgaste   = subtotal * (desgaste/100)
///   conDesgaste     = subtotal + costoDesgaste
///   costoFallos     = conDesgaste * (fallos/100)
///   costoTotal      = conDesgaste + costoFallos
///   precioVenta     = costoTotal * (1 + margen/100)
///   ganancia        = precioVenta - costoTotal
/// Moneda: Bolivianos (Bs).
class Calculadora3DScreen extends StatefulWidget {
  const Calculadora3DScreen({super.key});

  @override
  State<Calculadora3DScreen> createState() => _Calculadora3DScreenState();
}

class _Calculadora3DScreenState extends State<Calculadora3DScreen> {
  final _precioFilamentoCtrl = TextEditingController(text: '90');
  final _pesoCtrl = TextEditingController(text: '25');
  final _horasCtrl = TextEditingController(text: '3');
  final _minutosCtrl = TextEditingController(text: '30');
  final _potenciaCtrl = TextEditingController(text: '120');
  final _precioKwhCtrl = TextEditingController(text: '1.23');
  final _desgasteCtrl = TextEditingController(text: '10');
  final _fallosCtrl = TextEditingController(text: '10');
  final _margenCtrl = TextEditingController(text: '40');

  late CalculoCostos3D _calculo;

  @override
  void initState() {
    super.initState();
    _recalcular();
    for (final ctrl in [
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
      ctrl.addListener(_recalcular);
    }
  }

  @override
  void dispose() {
    _precioFilamentoCtrl.dispose();
    _pesoCtrl.dispose();
    _horasCtrl.dispose();
    _minutosCtrl.dispose();
    _potenciaCtrl.dispose();
    _precioKwhCtrl.dispose();
    _desgasteCtrl.dispose();
    _fallosCtrl.dispose();
    _margenCtrl.dispose();
    super.dispose();
  }

  double _num(TextEditingController ctrl) => double.tryParse(ctrl.text) ?? 0;

  void _recalcular() {
    setState(() {
      _calculo = CalculoCostos3D(
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
    });
  }

  String _bs(double n) => 'Bs ${n.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Calculadora de costos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.impresion3dColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Ender 3 V3 SE · PLA+',
            style: TextStyle(color: AppColors.textDim, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cargá los datos de tu pieza y sacá el costo real y el precio de venta sugerido.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 32),
          isMobile
              ? Column(
                  children: [
                    _buildFormulario(),
                    const SizedBox(height: 24),
                    _buildDesglose(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFormulario()),
                    const SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildDesglose()),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _seccion('MATERIAL', [
          _campo(
            label: 'Precio del filamento',
            hint: 'Lo que pagaste por el rollo, dividido entre 1 kg. Si el rollo de 1kg te costó 90 Bs, poné 90.',
            controller: _precioFilamentoCtrl,
            unidad: 'Bs/kg',
          ),
          _campo(
            label: 'Peso de la pieza',
            hint: 'Cuánto filamento gasta la pieza. Lo ves en el slicer (Creality Print) antes de imprimir.',
            controller: _pesoCtrl,
            unidad: 'g',
          ),
        ]),
        _seccion('TIEMPO DE IMPRESIÓN', [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'También lo ves en el slicer, como tiempo estimado de impresión.',
              style: TextStyle(color: AppColors.textDim, fontSize: 12),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _campo(label: 'Horas', controller: _horasCtrl, unidad: 'h'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(label: 'Minutos', controller: _minutosCtrl, unidad: 'min'),
              ),
            ],
          ),
        ]),
        _seccion('ELECTRICIDAD', [
          _campo(
            label: 'Consumo de la impresora',
            hint: 'Cuánta energía usa tu impresora mientras imprime. La Ender 3 V3 SE ronda 120-150W.',
            controller: _potenciaCtrl,
            unidad: 'W',
          ),
          _campo(
            label: 'Precio de la luz',
            hint: 'Lo que cobra tu proveedor eléctrico por cada kWh. Está en tu factura de luz.',
            controller: _precioKwhCtrl,
            unidad: 'Bs/kWh',
          ),
        ]),
        _seccion('EXTRAS', [
          _campo(
            label: 'Desgaste / mantenimiento',
            hint: 'Un % extra sobre material + luz para cubrir boquillas, correas, cama, etc.',
            controller: _desgasteCtrl,
            unidad: '%',
          ),
          _campo(
            label: 'Colchón por fallos',
            hint: 'Un % extra por si una impresión falla y hay que reimprimir.',
            controller: _fallosCtrl,
            unidad: '%',
          ),
          _campo(
            label: 'Margen de ganancia',
            hint: 'Cuánto querés ganar arriba del costo real. 0% = solo recuperás lo gastado.',
            controller: _margenCtrl,
            unidad: '%',
            resaltado: true,
          ),
        ]),
      ],
    );
  }

  Widget _seccion(String titulo, List<Widget> hijos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }

  Widget _campo({
    required String label,
    String? hint,
    required TextEditingController controller,
    required String unidad,
    bool resaltado = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: resaltado ? AppColors.impresion3dColor.withValues(alpha: 0.5) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      filled: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(unidad, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
                ),
              ],
            ),
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(hint, style: const TextStyle(color: AppColors.textDim, fontSize: 11, height: 1.3)),
            ),
        ],
      ),
    );
  }

  Widget _buildDesglose() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESGLOSE',
            style: TextStyle(color: AppColors.textDim, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
          const SizedBox(height: 14),
          _filaDesglose('Material', _bs(_calculo.costoMaterial)),
          _filaDesglose(
            'Electricidad (${_calculo.tiempoHoras.toStringAsFixed(2)} h)',
            _bs(_calculo.costoElectrico),
          ),
          _filaDesglose(
            'Desgaste (${_calculo.desgastePorcentaje.toStringAsFixed(0)}%)',
            _bs(_calculo.costoDesgaste),
          ),
          _filaDesglose(
            'Colchón fallos (${_calculo.fallosPorcentaje.toStringAsFixed(0)}%)',
            _bs(_calculo.costoFallos),
          ),
          const Divider(height: 24),
          _filaDesglose('Costo total', _bs(_calculo.costoTotal), destacado: true),
          const Divider(height: 24),
          _filaDesglose(
            'Ganancia (${_calculo.margenPorcentaje.toStringAsFixed(0)}%)',
            _bs(_calculo.ganancia),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Precio de venta sugerido', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                Text(
                  _bs(_calculo.precioVenta),
                  style: const TextStyle(
                    color: AppColors.impresion3dColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaDesglose(String label, String valor, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: destacado ? AppColors.textLight : AppColors.textMuted,
              fontSize: 14,
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            valor,
            style: TextStyle(
              color: destacado ? AppColors.textLight : AppColors.grisSecundario,
              fontSize: 14,
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
