import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

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
    final isCompact = Responsive.isCompact(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.panel(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Ender 3 V3 SE · PLA+',
            titulo: 'Calculadora de costos',
            subtitulo:
                'Cargá los datos de tu pieza y sacá el costo real y el precio de venta sugerido.',
            accentColor: AppColors.impresion3dColor,
            compacto: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
          isCompact
              ? Column(
                  children: [
                    _buildFormulario(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDesglose(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildFormulario()),
                    const SizedBox(width: AppSpacing.xxl),
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
        _seccion('MATERIAL', Icons.polymer_outlined, [
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
        _seccion('TIEMPO DE IMPRESIÓN', Icons.timer_outlined, [
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
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
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _campo(label: 'Minutos', controller: _minutosCtrl, unidad: 'min'),
              ),
            ],
          ),
        ]),
        _seccion('ELECTRICIDAD', Icons.bolt_outlined, [
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
        _seccion('EXTRAS', Icons.tune_outlined, [
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

  Widget _seccion(String titulo, IconData icon, List<Widget> hijos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.impresion3dColor),
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
            const SizedBox(height: AppSpacing.md),
            ...hijos,
          ],
        ),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppColors.textLight, fontSize: 14),
            decoration: InputDecoration(
              suffixText: unidad,
              suffixStyle: const TextStyle(color: AppColors.textDim, fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: resaltado
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide(
                        color: AppColors.impresion3dColor.withValues(alpha: 0.5),
                      ),
                    )
                  : null,
            ),
          ),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                hint,
                style: const TextStyle(color: AppColors.textDim, fontSize: 11, height: 1.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesglose() {
    return TechCard(
      showCornerBrackets: true,
      accentColor: AppColors.impresion3dColor,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.impresion3dColor),
              SizedBox(width: AppSpacing.sm),
              Text(
                'DESGLOSE',
                style: TextStyle(
                  color: AppColors.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
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
          const Divider(height: AppSpacing.xl),
          _filaDesglose('Costo total', _bs(_calculo.costoTotal), destacado: true),
          const Divider(height: AppSpacing.xl),
          _filaDesglose(
            'Ganancia (${_calculo.margenPorcentaje.toStringAsFixed(0)}%)',
            _bs(_calculo.ganancia),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Precio final destacado con glow sutil
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: ShapeDecoration(
              color: AppColors.impresion3dColor.withValues(alpha: 0.08),
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                side: BorderSide(color: AppColors.impresion3dColor),
              ),
              shadows: [
                BoxShadow(
                  color: AppColors.impresion3dColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRECIO DE VENTA SUGERIDO',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _bs(_calculo.precioVenta),
                  style: const TextStyle(
                    color: AppColors.impresion3dColor,
                    fontSize: 30,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
