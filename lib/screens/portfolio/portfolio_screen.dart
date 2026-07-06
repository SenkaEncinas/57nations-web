import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _firebaseService = FirebaseService();
  List<Proyecto> _proyectos = [];
  bool _cargando = true;
  String? _error;
  String _filtroCategoria = 'Todas';

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
      final proyectos = await _firebaseService.obtenerProyectos();
      setState(() {
        _proyectos = proyectos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar el portfolio. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  List<Proyecto> get _proyectosFiltrados {
    if (_filtroCategoria == 'Todas') return _proyectos;
    return _proyectos.where((p) => p.categoria == _filtroCategoria).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const NavBar(),
              const PageHero(
                titulo: 'PORTFOLIO',
                subtitulo: 'Proyectos reales que llevamos a cabo para nuestros clientes.',
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 60,
                  vertical: isMobile ? 40 : 60,
                ),
                color: AppColors.background,
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const ['Todas', ...CategoriasProyecto.todas]
                            .map((c) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(c),
                                    selected: _filtroCategoria == c,
                                    onSelected: (_) => setState(() => _filtroCategoria = c),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(height: isMobile ? 32 : 48),
                    if (_cargando)
                      const EstadoCargando(mensaje: 'Cargando portfolio...')
                    else if (_error != null)
                      EstadoError(mensaje: _error!, onReintentar: _cargar)
                    else if (_proyectosFiltrados.isEmpty)
                      EstadoVacio(
                        icon: Icons.photo_library_outlined,
                        mensaje: _proyectos.isEmpty
                            ? 'Todavía no hay proyectos cargados.'
                            : 'Todavía no hay proyectos cargados en esta categoría.',
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: isMobile ? 1.3 : 0.9,
                        ),
                        itemCount: _proyectosFiltrados.length,
                        itemBuilder: (context, index) {
                          final proyecto = _proyectosFiltrados[index];
                          return _ProyectoCard(
                            proyecto: proyecto,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.proyectoDetalle,
                              arguments: proyecto.id,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProyectoCard extends StatefulWidget {
  final Proyecto proyecto;
  final VoidCallback onTap;

  const _ProyectoCard({required this.proyecto, required this.onTap});

  @override
  State<_ProyectoCard> createState() => _ProyectoCardState();
}

class _ProyectoCardState extends State<_ProyectoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final proyecto = widget.proyecto;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered ? AppColors.violetaPrincipal : AppColors.border,
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
                  child: proyecto.imagenes.isNotEmpty
                      ? Image.network(proyecto.imagenes.first, fit: BoxFit.cover)
                      : const Center(
                          child: Icon(Icons.image_outlined, color: AppColors.textDim, size: 32),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proyecto.titulo,
                      style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proyecto.categoria,
                      style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
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
