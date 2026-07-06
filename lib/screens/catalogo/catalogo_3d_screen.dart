import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
import '../../utils/whatsapp_helper.dart';
import '../../widgets/widgets.dart';

class Catalogo3dScreen extends StatefulWidget {
  const Catalogo3dScreen({super.key});

  @override
  State<Catalogo3dScreen> createState() => _Catalogo3dScreenState();
}

class _Catalogo3dScreenState extends State<Catalogo3dScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Impresion3D> _impresiones = [];
  String _filtroCategoria = 'Todas';
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarImpresiones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarImpresiones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final impresiones = await _firebaseService.obtenerImpresiones3D();
      setState(() {
        _impresiones = impresiones;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar el catálogo. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  List<Impresion3D> get _impresionesFiltradas {
    var lista = _impresiones;
    if (_filtroCategoria != 'Todas') {
      lista = lista.where((i) => i.categoria == _filtroCategoria).toList();
    }
    final busqueda = _searchController.text.trim().toLowerCase();
    if (busqueda.isNotEmpty) {
      lista = lista.where((i) => i.nombre.toLowerCase().contains(busqueda)).toList();
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              overline: 'Impresión 3D',
              titulo: 'Catálogo de Impresiones 3D',
              subtitulo:
                  'Todas las piezas se imprimen bajo pedido: elegís el modelo, el '
                  'material y los colores, y la fabricamos para vos.',
              colorAcento: AppColors.impresion3dColor,
            ),
            _buildFiltersSection(),
            _buildImpresionesGrid(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  void _abrirDetalle(Impresion3D impresion) {
    showDialog(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (context) => _DetalleImpresionDialog(impresion: impresion),
    );
  }

  Widget _buildFiltersSection() {
    return PageSection(
      verticalPadding: AppSpacing.xxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textLight),
            decoration: InputDecoration(
              hintText: 'Buscar piezas en el catálogo...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todas', 'Decorativa', 'Funcional', 'Accesorio']
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _FilterChip(
                          label: c == 'Todas' ? 'Todas' : '${c}s',
                          selected: _filtroCategoria == c,
                          onSelected: () => setState(() => _filtroCategoria = c),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpresionesGrid(BuildContext context) {
    final crossAxisCount = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);

    Widget contenido;
    if (_cargando) {
      contenido = const EstadoCargando(mensaje: 'Cargando catálogo...');
    } else if (_error != null) {
      contenido = EstadoError(mensaje: _error!, onReintentar: _cargarImpresiones);
    } else if (_impresionesFiltradas.isEmpty) {
      contenido = EstadoVacio(
        icon: Icons.view_in_ar_outlined,
        mensaje: _impresiones.isEmpty
            ? 'Todavía no hay piezas cargadas en el catálogo.'
            : 'No encontramos piezas con ese filtro o búsqueda.',
      );
    } else {
      contenido = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.xl,
          mainAxisSpacing: AppSpacing.xl,
          childAspectRatio: Responsive.isMobile(context) ? 1.05 : 0.75,
        ),
        itemCount: _impresionesFiltradas.length,
        itemBuilder: (context, index) => _Impresion3DCard(
          impresion: _impresionesFiltradas[index],
          onVer: () => _abrirDetalle(_impresionesFiltradas[index]),
        ),
      );
    }

    return PageSection(
      alternada: true,
      verticalPadding: AppSpacing.section,
      child: contenido,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppColors.surfaceElevated,
      selectedColor: AppColors.impresion3dColor.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: selected ? AppColors.impresion3dColor : AppColors.textMuted,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? AppColors.impresion3dColor : AppColors.border,
      ),
    );
  }
}

class _Impresion3DCard extends StatefulWidget {
  final Impresion3D impresion;
  final VoidCallback onVer;

  const _Impresion3DCard({required this.impresion, required this.onVer});

  @override
  State<_Impresion3DCard> createState() => _Impresion3DCardState();
}

class _Impresion3DCardState extends State<_Impresion3DCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final impresion = widget.impresion;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onVer,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        clipBehavior: Clip.hardEdge,
        decoration: ShapeDecoration(
          color: AppColors.surfaceElevated,
          shape: AppTheme.cutCorner(
            side: BorderSide(
              color: _isHovered ? AppColors.impresion3dColor : AppColors.border,
              width: _isHovered ? 1.4 : 1,
            ),
          ),
          shadows: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.impresion3dColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.surface,
                child: impresion.imagenes.isNotEmpty
                    ? Image.network(impresion.imagenes[0], fit: BoxFit.cover)
                    : const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textDim, size: 32),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    impresion.nombre,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  StatusBadge(
                    texto: impresion.categoria,
                    color: AppColors.impresion3dColor,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DESDE',
                            style: TextStyle(
                              color: AppColors.textDim,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'Bs ${impresion.precioBase.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.impresion3dColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: widget.onVer,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        ),
                        child: const Text('VER'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Modal de detalle de una pieza del catálogo: galería, especificaciones y
/// botón para cotizarla por WhatsApp con mensaje pre-armado.
class _DetalleImpresionDialog extends StatefulWidget {
  final Impresion3D impresion;

  const _DetalleImpresionDialog({required this.impresion});

  @override
  State<_DetalleImpresionDialog> createState() => _DetalleImpresionDialogState();
}

class _DetalleImpresionDialogState extends State<_DetalleImpresionDialog> {
  int _fotoSeleccionada = 0;

  String get _tiempoFormateado {
    final total = widget.impresion.tiempoImpresion;
    if (total <= 0) return 'A confirmar';
    final horas = total ~/ 60;
    final minutos = total % 60;
    if (horas == 0) return '$minutos min';
    if (minutos == 0) return '$horas h';
    return '$horas h $minutos min';
  }

  void _cotizarPorWhatsApp() {
    WhatsAppHelper.abrirChat(
      telefono: AppConfig.whatsappAdminNumero,
      mensaje: 'Hola 57 Nations! Vi la pieza "${widget.impresion.nombre}" en el '
          'Catálogo 3D y quiero cotizarla. ¿Me pasan precio y tiempos?',
    );
  }

  void _abrirLightbox() {
    if (widget.impresion.imagenes.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (context) => GaleriaLightbox(
        imagenes: widget.impresion.imagenes,
        indiceInicial: _fotoSeleccionada,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final impresion = widget.impresion;
    final isMobile = Responsive.isMobile(context);
    final imagenes = impresion.imagenes;
    final indice = imagenes.isEmpty ? 0 : _fotoSeleccionada.clamp(0, imagenes.length - 1);

    final galeria = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: imagenes.isEmpty ? MouseCursor.defer : SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: _abrirLightbox,
            child: Container(
              height: isMobile ? 200 : 260,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: AppTheme.cutCorner(side: const BorderSide(color: AppColors.border)),
              ),
              child: imagenes.isNotEmpty
                  ? Image.network(imagenes[indice], fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.image_not_supported_outlined,
                          color: AppColors.textDim, size: 40),
                    ),
            ),
          ),
        ),
        if (imagenes.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < imagenes.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(() => _fotoSeleccionada = i),
                        child: Container(
                          width: 52,
                          height: 52,
                          clipBehavior: Clip.hardEdge,
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: AppTheme.cutCorner(
                              size: AppTheme.cutSizeSm,
                              side: BorderSide(
                                color: i == indice
                                    ? AppColors.impresion3dColor
                                    : AppColors.border,
                                width: i == indice ? 1.5 : 1,
                              ),
                            ),
                          ),
                          child: Image.network(imagenes[i], fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusBadge(texto: impresion.categoria, color: AppColors.impresion3dColor),
        const SizedBox(height: AppSpacing.md),
        Text(impresion.nombre, style: Theme.of(context).textTheme.titleLarge),
        if (impresion.descripcion.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            impresion.descripcion,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.6),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _SpecFila(icon: Icons.polymer_outlined, label: 'Material', valor: impresion.material),
        _SpecFila(
            icon: Icons.scale_outlined,
            label: 'Peso aprox.',
            valor: '${impresion.peso.toStringAsFixed(0)} g'),
        _SpecFila(icon: Icons.timer_outlined, label: 'Tiempo de impresión', valor: _tiempoFormateado),
        if (impresion.coloresDisponibles.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'COLORES DISPONIBLES',
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: impresion.coloresDisponibles
                .map((c) => StatusBadge(texto: c, color: AppColors.impresion3dColor))
                .toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'DESDE',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Bs ${impresion.precioBase.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.impresion3dColor,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'El precio final depende del tamaño, material y colores que elijas.',
          style: TextStyle(color: AppColors.textDim, fontSize: 11),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _cotizarPorWhatsApp,
            icon: const Icon(Icons.chat_bubble_outline, size: 16),
            label: const Text('COTIZAR ESTA PIEZA'),
          ),
        ),
      ],
    );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.sectionLg,
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 640),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        galeria,
                        const SizedBox(height: AppSpacing.xl),
                        info,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: galeria),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(child: info),
                      ],
                    ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted),
                tooltip: 'Cerrar',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecFila extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;

  const _SpecFila({required this.icon, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.impresion3dColor),
          const SizedBox(width: AppSpacing.sm),
          Text('$label: ', style: const TextStyle(color: AppColors.textDim, fontSize: 13)),
          Expanded(
            child: Text(
              valor.isEmpty ? 'A confirmar' : valor,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
