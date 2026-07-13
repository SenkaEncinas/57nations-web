import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../services/cloudinary_service.dart';
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
  List<String> _coloresDisponibles = [];
  final List<_ItemCarrito> _carrito = [];
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
      final resultados = await Future.wait([
        _firebaseService.obtenerImpresiones3D(),
        _firebaseService.obtenerColoresDisponibles3D(),
      ]);
      setState(() {
        _impresiones = resultados[0] as List<Impresion3D>;
        _coloresDisponibles = resultados[1] as List<String>;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = mensajeErrorCarga(e, queCargaba: 'el catálogo');
        _cargando = false;
      });
    }
  }

  int get _cantidadCarrito => _carrito.fold(0, (s, i) => s + i.cantidad);

  void _agregarAlCarrito(Impresion3D pieza, String color, int cantidad) {
    setState(() {
      final existente =
          _carrito.indexWhere((i) => i.pieza.id == pieza.id && i.color == color);
      if (existente != -1) {
        _carrito[existente].cantidad += cantidad;
      } else {
        _carrito.add(_ItemCarrito(pieza: pieza, color: color, cantidad: cantidad));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${pieza.nombre}" agregado al carrito'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _abrirCarrito() {
    showDialog(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (context) => _CarritoDialog(
        carrito: _carrito,
        onCambio: () => setState(() {}),
        onCheckoutExitoso: () => setState(_carrito.clear),
      ),
    );
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CarritoFlotante(cantidad: _cantidadCarrito, onTap: _abrirCarrito),
          const SizedBox(height: AppSpacing.md),
          const WhatsAppFlotante(),
        ],
      ),
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
      builder: (context) => _DetalleImpresionDialog(
        impresion: impresion,
        coloresDisponibles: _coloresDisponibles,
        onAgregarCarrito: (color, cantidad) =>
            _agregarAlCarrito(impresion, color, cantidad),
      ),
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
                    color: AppColors.impresion3dColor.withValues(alpha: 0.14),
                    blurRadius: 14,
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
                    ? Image.network(CloudinaryService.optimizar(impresion.imagenes[0], ancho: 600), fit: BoxFit.cover)
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
/// selector de color + cantidad para agregarla al carrito.
class _DetalleImpresionDialog extends StatefulWidget {
  final Impresion3D impresion;

  /// Lista global de colores (ver `configuracion/colores3d`) — ya no es un
  /// campo por pieza, se ofrece igual en todo el catálogo.
  final List<String> coloresDisponibles;
  final void Function(String color, int cantidad) onAgregarCarrito;

  const _DetalleImpresionDialog({
    required this.impresion,
    required this.coloresDisponibles,
    required this.onAgregarCarrito,
  });

  @override
  State<_DetalleImpresionDialog> createState() => _DetalleImpresionDialogState();
}

class _DetalleImpresionDialogState extends State<_DetalleImpresionDialog> {
  int _fotoSeleccionada = 0;
  String? _colorSeleccionado;
  int _cantidad = 1;

  @override
  void initState() {
    super.initState();
    _colorSeleccionado =
        widget.coloresDisponibles.isNotEmpty ? widget.coloresDisponibles.first : null;
  }

  String get _tiempoFormateado {
    final total = widget.impresion.tiempoImpresion;
    if (total <= 0) return 'A confirmar';
    final horas = total ~/ 60;
    final minutos = total % 60;
    if (horas == 0) return '$minutos min';
    if (minutos == 0) return '$horas h';
    return '$horas h $minutos min';
  }

  void _agregarAlCarrito() {
    widget.onAgregarCarrito(_colorSeleccionado ?? 'Sin especificar', _cantidad);
    Navigator.pop(context);
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
                  ? Image.network(CloudinaryService.optimizar(imagenes[indice], ancho: 800), fit: BoxFit.cover)
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
                          child: Image.network(CloudinaryService.optimizar(imagenes[i], ancho: 200), fit: BoxFit.cover),
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
        if (widget.coloresDisponibles.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'ELEGÍ UN COLOR',
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
            children: widget.coloresDisponibles
                .map((c) => ChoiceChip(
                      label: Text(c),
                      selected: c == _colorSeleccionado,
                      onSelected: (_) => setState(() => _colorSeleccionado = c),
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            const Text(
              'CANTIDAD',
              style: TextStyle(
                color: AppColors.textDim,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              color: AppColors.textMuted,
              onPressed: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
            ),
            Text(
              '$_cantidad',
              style: const TextStyle(
                  color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              color: AppColors.textMuted,
              onPressed: () => setState(() => _cantidad++),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
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
            onPressed: _agregarAlCarrito,
            icon: const Icon(Icons.add_shopping_cart_outlined, size: 16),
            label: const Text('AGREGAR AL CARRITO'),
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

// ==================== CARRITO ====================
/// Ítem del carrito, en memoria — no se guarda entre visitas (igual que el
/// resto del sitio, sin cuentas de cliente). `pieza` y `color` identifican
/// la línea; agregar la misma pieza+color de nuevo suma cantidad en vez de
/// duplicar la fila.
class _ItemCarrito {
  final Impresion3D pieza;
  final String color;
  int cantidad;

  _ItemCarrito({required this.pieza, required this.color, required this.cantidad});

  double get subtotal => pieza.precioBase * cantidad;
}

/// Botón flotante del carrito con badge de cantidad. Va arriba del botón de
/// WhatsApp (ambos en `floatingActionButton` del Scaffold, como Column).
class _CarritoFlotante extends StatelessWidget {
  final int cantidad;
  final VoidCallback onTap;

  const _CarritoFlotante({required this.cantidad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          heroTag: 'carrito3d',
          backgroundColor: AppColors.surfaceElevated,
          foregroundColor: AppColors.impresion3dColor,
          shape: AppTheme.cutCorner(
            side: const BorderSide(color: AppColors.impresion3dColor),
          ),
          onPressed: onTap,
          tooltip: 'Ver carrito',
          child: const Icon(Icons.shopping_cart_outlined),
        ),
        if (cantidad > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: const BoxDecoration(color: AppColors.cianTech, shape: BoxShape.circle),
              child: Text(
                '$cantidad',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.background,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Fila de un ítem dentro del diálogo del carrito: nombre, color, cantidad
/// editable (+/-) y subtotal.
class _FilaCarrito extends StatelessWidget {
  final _ItemCarrito item;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;
  final VoidCallback onQuitar;

  const _FilaCarrito({
    required this.item,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.pieza.nombre,
                style: const TextStyle(
                    color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text('Color: ${item.color}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                'Bs ${item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.impresion3dColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          color: AppColors.textMuted,
          onPressed: onDecrementar,
        ),
        Text(
          '${item.cantidad}',
          style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 20),
          color: AppColors.textMuted,
          onPressed: onIncrementar,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: AppColors.error,
          onPressed: onQuitar,
        ),
      ],
    );
  }
}

/// Diálogo del carrito: lista de ítems editable + total + checkout. El
/// checkout (a) guarda un registro en `pedidosCarrito3d` (alimenta el
/// ranking "piezas más pedidas" del Dashboard) y (b) abre WhatsApp con el
/// pedido itemizado, directo al número de Admin — mismo criterio que el
/// resto del sitio: sin cuentas, la cotización se cierra por WhatsApp.
class _CarritoDialog extends StatefulWidget {
  final List<_ItemCarrito> carrito;
  final VoidCallback onCambio;
  final VoidCallback onCheckoutExitoso;

  const _CarritoDialog({
    required this.carrito,
    required this.onCambio,
    required this.onCheckoutExitoso,
  });

  @override
  State<_CarritoDialog> createState() => _CarritoDialogState();
}

class _CarritoDialogState extends State<_CarritoDialog> {
  final _firebaseService = FirebaseService();
  bool _enviando = false;

  double get _total => widget.carrito.fold(0.0, (s, i) => s + i.subtotal);

  void _incrementar(_ItemCarrito item) {
    setState(() => item.cantidad++);
    widget.onCambio();
  }

  void _decrementar(_ItemCarrito item) {
    setState(() {
      item.cantidad--;
      if (item.cantidad <= 0) widget.carrito.remove(item);
    });
    widget.onCambio();
  }

  void _quitar(_ItemCarrito item) {
    setState(() => widget.carrito.remove(item));
    widget.onCambio();
  }

  String _mensajeWhatsApp(List<ItemPedidoCarrito3D> items) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 *PEDIDO DEL CATÁLOGO 3D - 57 NATIONS*');
    buffer.writeln('');
    for (final item in items) {
      buffer.writeln(
          '• ${item.cantidad}x ${item.piezaNombre} (${item.color}) — Bs ${item.subtotal.toStringAsFixed(2)}');
    }
    buffer.writeln('');
    buffer.writeln('💰 *Total: Bs ${_total.toStringAsFixed(2)}*');
    buffer.writeln('');
    buffer.writeln('—');
    buffer.writeln('Enviado automáticamente desde la web de 57 Nations');
    return buffer.toString();
  }

  Future<void> _enviarPorWhatsApp() async {
    if (widget.carrito.isEmpty) return;
    setState(() => _enviando = true);

    try {
      final items = widget.carrito
          .map((i) => ItemPedidoCarrito3D(
                piezaId: i.pieza.id,
                piezaNombre: i.pieza.nombre,
                color: i.color,
                cantidad: i.cantidad,
                precioUnitario: i.pieza.precioBase,
              ))
          .toList();

      // 1) Registro en Firestore — es lo que alimenta el ranking "piezas
      //    más pedidas" del Dashboard.
      await _firebaseService.crearPedidoCarrito3D(PedidoCarrito3D(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: items,
        montoTotal: _total,
        fechaCreacion: DateTime.now(),
      ));

      // 2) WhatsApp con el pedido itemizado, directo a Senka.
      await WhatsAppHelper.abrirChat(
        telefono: AppConfig.whatsappAdminNumero,
        mensaje: _mensajeWhatsApp(items),
      );

      if (mounted) {
        widget.onCheckoutExitoso();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : 200,
        vertical: AppSpacing.xxl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      color: AppColors.impresion3dColor, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Tu carrito', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (widget.carrito.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child: Text(
                      'Todavía no agregaste ninguna pieza. Abrí el detalle de una '
                      'pieza del catálogo y tocá "Agregar al carrito".',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else ...[
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.carrito.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: AppSpacing.lg, color: AppColors.border),
                    itemBuilder: (context, i) {
                      final item = widget.carrito[i];
                      return _FilaCarrito(
                        item: item,
                        onIncrementar: () => _incrementar(item),
                        onDecrementar: () => _decrementar(item),
                        onQuitar: () => _quitar(item),
                      );
                    },
                  ),
                ),
                const Divider(height: AppSpacing.xl, color: AppColors.border),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Bs ${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.impresion3dColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _enviando ? null : _enviarPorWhatsApp,
                    icon: _enviando
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppColors.textLight)),
                          )
                        : const Icon(Icons.chat_bubble_outline, size: 16),
                    label: Text(_enviando ? 'ENVIANDO...' : 'ENVIAR COTIZACIÓN POR WHATSAPP'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
