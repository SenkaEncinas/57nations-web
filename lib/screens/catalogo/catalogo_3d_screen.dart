import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
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
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            _buildHeroSection(isMobile),
            _buildFiltersSection(isMobile),
            _buildImpresionesGrid(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return const PageHero(
      titulo: 'Catálogo de Impresiones 3D',
      subtitulo: 'Piezas decorativas y funcionales, diseño custom, acabado profesional.',
      colorAcento: AppColors.impresion3dColor,
    );
  }

  Widget _buildFiltersSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 32,
      ),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textLight),
            decoration: InputDecoration(
              hintText: 'Buscar impresiones 3D...',
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
          SizedBox(height: isMobile ? 24 : 32),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todas', 'Decorativa', 'Funcional', 'Accesorio']
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

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
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: isMobile ? 1.1 : 0.75,
        ),
        itemCount: _impresionesFiltradas.length,
        itemBuilder: (context, index) => _Impresion3DCard(impresion: _impresionesFiltradas[index]),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      color: AppColors.surface,
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
      selectedColor: AppColors.impresion3dColor.withValues(alpha: 0.2),
      labelStyle: TextStyle(color: selected ? AppColors.impresion3dColor : AppColors.textMuted),
      side: BorderSide(
        color: selected ? AppColors.impresion3dColor : AppColors.border,
      ),
    );
  }
}

class _Impresion3DCard extends StatefulWidget {
  final Impresion3D impresion;

  const _Impresion3DCard({required this.impresion});

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovered ? AppColors.impresion3dColor : AppColors.border,
            width: _isHovered ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.hardEdge,
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
                        child: Icon(Icons.image_not_supported_outlined, color: AppColors.textDim, size: 32),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    impresion.nombre,
                    style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.impresion3dColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      impresion.categoria,
                      style: const TextStyle(color: AppColors.impresion3dColor, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bs ${impresion.precioBase.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.impresion3dColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Ver'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
