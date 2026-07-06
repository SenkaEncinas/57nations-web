import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';

class Catalogo3dScreen extends StatefulWidget {
  const Catalogo3dScreen({Key? key}) : super(key: key);

  @override
  State<Catalogo3dScreen> createState() => _Catalogo3dScreenState();
}

class _Catalogo3dScreenState extends State<Catalogo3dScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Impresion3D> _impresiones = [];
  String _filtroCategoria = 'Todas';
  String _ordenamiento = 'Recientes';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarImpresiones();
  }

  Future<void> _cargarImpresiones() async {
    setState(() => _cargando = true);
    try {
      final impresiones = await _firebaseService.obtenerImpresiones3D();
      setState(() => _impresiones = impresiones);
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            // HERO SECTION
            _buildHeroSection(isMobile),
            // FILTROS Y BÚSQUEDA
            _buildFiltersSection(isMobile),
            // GRID DE IMPRESIONES
            _buildImpresionesGrid(isMobile),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catálogo de Impresiones 3D',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontSize: isMobile ? 32 : 44,
                ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'Piezas decorativas y funcionales, diseño custom, acabado profesional',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                  fontSize: isMobile ? 14 : 16,
                ),
          ),
        ],
      ),
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
          // BÚSQUEDA
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar impresiones 3D...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          // FILTROS Y ORDENAMIENTO
          if (!isMobile)
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        selected: _filtroCategoria == 'Todas',
                        onSelected: () => setState(() => _filtroCategoria = 'Todas'),
                      ),
                      _FilterChip(
                        label: 'Decorativas',
                        selected: _filtroCategoria == 'Decorativa',
                        onSelected: () => setState(() => _filtroCategoria = 'Decorativa'),
                      ),
                      _FilterChip(
                        label: 'Funcionales',
                        selected: _filtroCategoria == 'Funcional',
                        onSelected: () => setState(() => _filtroCategoria = 'Funcional'),
                      ),
                      _FilterChip(
                        label: 'Accesorios',
                        selected: _filtroCategoria == 'Accesorio',
                        onSelected: () => setState(() => _filtroCategoria = 'Accesorio'),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 24),
                DropdownButton<String>(
                  value: _ordenamiento,
                  items: ['Recientes', 'Precio: Menor a Mayor', 'Precio: Mayor a Menor']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _ordenamiento = value);
                    }
                  },
                ),
              ],
            )
          else
            Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Todas',
                        selected: _filtroCategoria == 'Todas',
                        onSelected: () => setState(() => _filtroCategoria = 'Todas'),
                      ),
                      SizedBox(width: 8),
                      _FilterChip(
                        label: 'Decorativas',
                        selected: _filtroCategoria == 'Decorativa',
                        onSelected: () => setState(() => _filtroCategoria = 'Decorativa'),
                      ),
                      SizedBox(width: 8),
                      _FilterChip(
                        label: 'Funcionales',
                        selected: _filtroCategoria == 'Funcional',
                        onSelected: () => setState(() => _filtroCategoria = 'Funcional'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImpresionesGrid(bool isMobile) {
    if (_cargando) {
      return Container(
        padding: const EdgeInsets.all(60),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      color: AppColors.surface,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 0.75,
        ),
        itemCount: _impresiones.length,
        itemBuilder: (context, index) {
          final impresion = _impresiones[index];
          return _Impresion3DCard(impresion: impresion);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.impresion3dColor.withOpacity(0.2),
      side: BorderSide(
        color: selected ? AppColors.impresion3dColor : const Color(0xFFE5E7EB),
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGEN
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: widget.impresion.imagenes.isNotEmpty
                      ? Image.network(
                          widget.impresion.imagenes[0],
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade600,
                          ),
                        ),
                ),
                // CONTENIDO
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.impresion.nombre,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Chip(
                          label: Text(
                            widget.impresion.categoria,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppColors.impresion3dColor.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: AppColors.impresion3dColor,
                          ),
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${widget.impresion.precioBase.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.impresion3dColor,
                                  ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              child: const Text('Ver'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isHovered)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
