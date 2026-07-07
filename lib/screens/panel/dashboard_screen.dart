import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

/// Dashboard del negocio — SOLO Admin (admin.total). Primera sección del
/// panel. Todo se calcula en tiempo real desde Firestore al cargar:
/// qué servicio pide más la gente (cotizaciones agrupadas), pedidos
/// pendientes, cotizaciones sin responder, facturación estimada del mes y
/// comisión acumulada de Luchin (este mes / histórico).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firebaseService = FirebaseService();

  List<Pedido> _pedidos = [];
  List<Cotizacion> _cotizaciones = [];
  bool _cargando = true;
  String? _error;
  bool _comisionSoloEsteMes = true;

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
      final resultados = await Future.wait([
        _firebaseService.obtenerPedidos(),
        _firebaseService.obtenerCotizaciones(),
      ]);
      setState(() {
        _pedidos = resultados[0] as List<Pedido>;
        _cotizaciones = resultados[1] as List<Cotizacion>;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar los datos del negocio. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  // ==================== MÉTRICAS ====================

  bool _esDelMesActual(DateTime fecha) {
    final ahora = DateTime.now();
    return fecha.year == ahora.year && fecha.month == ahora.month;
  }

  int get _pedidosPendientes =>
      _pedidos.where((p) => p.estado != EstadoPedido.entregado).length;

  int get _cotizacionesSinResponder =>
      _cotizaciones.where((c) => c.estado == 'Pendiente').length;

  double get _facturacionMes => _pedidos
      .where((p) => _esDelMesActual(p.fechaCreacion) && p.calculo != null)
      .fold(0.0, (suma, p) => suma + p.calculo!.precioVenta);

  double get _comisionLuchin => _pedidos
      .where((p) =>
          p.origenPedido == OrigenPedido.luchin &&
          p.comisionLuchin?.aplica == true &&
          (!_comisionSoloEsteMes || _esDelMesActual(p.fechaCreacion)))
      .fold(0.0, (suma, p) => suma + p.comisionLuchin!.monto);

  /// Ranking de servicios por cantidad de cotizaciones, de más a menos.
  List<MapEntry<String, int>> get _rankingServicios {
    final cuentas = <String, int>{};
    for (final c in _cotizaciones) {
      final servicio = c.servicio.isEmpty ? 'Sin especificar' : c.servicio;
      cuentas[servicio] = (cuentas[servicio] ?? 0) + 1;
    }
    final ranking = cuentas.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranking;
  }

  Color _colorServicio(String servicio) {
    switch (servicio) {
      case 'Bots & Sistemas':
        return AppColors.botColor;
      case 'Apps Flutter':
        return AppColors.flutterColor;
      case 'Arduino & ESP32':
        return AppColors.arduinoColor;
      case 'Impresión 3D':
        return AppColors.impresion3dColor;
      case 'Entrenamiento':
        return AppColors.entrenamientoColor;
      default:
        return AppColors.grisSecundario;
    }
  }

  String _bs(double n) => 'Bs ${n.toStringAsFixed(2)}';

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
              titulo: 'Dashboard',
              subtitulo: 'El pulso del negocio, calculado en tiempo real.',
              compacto: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_cargando)
              const EstadoCargando(mensaje: 'Calculando métricas...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else ...[
              // ===== NÚMEROS GENERALES =====
              LayoutBuilder(
                builder: (context, constraints) {
                  final columnas =
                      Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);
                  final ancho = (constraints.maxWidth -
                          AppSpacing.lg * (columnas - 1)) /
                      columnas;
                  return Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: [
                      SizedBox(
                        width: ancho,
                        child: _StatCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Pedidos pendientes',
                          valor: '$_pedidosPendientes',
                          color: AppColors.warning,
                          nota: 'Todo lo que aún no se entregó',
                        ),
                      ),
                      SizedBox(
                        width: ancho,
                        child: _StatCard(
                          icon: Icons.mail_outline,
                          label: 'Cotizaciones sin responder',
                          valor: '$_cotizacionesSinResponder',
                          color: AppColors.cianTech,
                          nota: 'Clientes esperando respuesta',
                        ),
                      ),
                      SizedBox(
                        width: ancho,
                        child: _StatCard(
                          icon: Icons.payments_outlined,
                          label: 'Facturación estimada del mes',
                          valor: _bs(_facturacionMes),
                          color: AppColors.success,
                          nota: 'Precio de venta de pedidos creados este mes',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              // ===== QUÉ PIDE MÁS LA GENTE =====
              TechCard(
                showCornerBrackets: true,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up_outlined,
                            size: 16, color: AppColors.violetaPrincipal),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'QUÉ PIDE MÁS LA GENTE',
                          style: TextStyle(
                            color: AppColors.textDim,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Según las ${_cotizaciones.length} cotizaciones recibidas por la web.',
                      style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_rankingServicios.isEmpty)
                      const Text(
                        'Todavía no llegaron cotizaciones — acá va a aparecer el ranking de servicios.',
                        style: TextStyle(color: AppColors.textMuted),
                      )
                    else
                      ..._rankingServicios.map((e) => _FilaRanking(
                            servicio: e.key,
                            cantidad: e.value,
                            maximo: _rankingServicios.first.value,
                            color: _colorServicio(e.key),
                          )),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // ===== COMISIÓN LUCHIN =====
              TechCard(
                accentColor: AppColors.flutterColor,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.handshake_outlined,
                            size: 16, color: AppColors.flutterColor),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'COMISIÓN ACUMULADA DE LUCHIN',
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
                    Wrap(
                      spacing: AppSpacing.md,
                      children: [
                        ChoiceChip(
                          label: const Text('Este mes'),
                          selected: _comisionSoloEsteMes,
                          onSelected: (_) =>
                              setState(() => _comisionSoloEsteMes = true),
                        ),
                        ChoiceChip(
                          label: const Text('Total histórico'),
                          selected: !_comisionSoloEsteMes,
                          onSelected: (_) =>
                              setState(() => _comisionSoloEsteMes = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _bs(_comisionLuchin),
                      style: const TextStyle(
                        color: AppColors.flutterColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Suma de comisiones de pedidos con origen Luchin donde aplica comisión.',
                      style: TextStyle(color: AppColors.textDim, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de métrica con el número grande y destacado.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color color;
  final String nota;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.valor,
    required this.color,
    required this.nota,
  });

  @override
  Widget build(BuildContext context) {
    return TechCard(
      accentColor: color,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(nota, style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Fila del ranking de servicios con barra proporcional al más pedido.
class _FilaRanking extends StatelessWidget {
  final String servicio;
  final int cantidad;
  final int maximo;
  final Color color;

  const _FilaRanking({
    required this.servicio,
    required this.cantidad,
    required this.maximo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final proporcion = maximo == 0 ? 0.0 : cantidad / maximo;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                servicio,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$cantidad',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Barra proporcional con esquinas recortadas
          LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Container(
                  height: 6,
                  width: constraints.maxWidth,
                  decoration: ShapeDecoration(
                    color: AppColors.surface,
                    shape: AppTheme.cutCorner(size: 3),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  height: 6,
                  width: constraints.maxWidth * proporcion,
                  decoration: ShapeDecoration(
                    color: color.withValues(alpha: 0.8),
                    shape: AppTheme.cutCorner(size: 3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
