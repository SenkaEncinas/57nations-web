import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
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
    final crossAxisCount = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const NavBar(),
              const PageHero(
                overline: '57 Nations',
                titulo: 'Portfolio',
                subtitulo:
                    'Proyectos reales que llevamos a cabo para nuestros clientes: '
                    'sistemas en producción, apps publicadas y piezas entregadas.',
              ),
              PageSection(
                verticalPadding: AppSpacing.section,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['Todas', ...CategoriasProyecto.todas]
                            .map((c) => Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                                  child: ChoiceChip(
                                    label: Text(c),
                                    selected: _filtroCategoria == c,
                                    onSelected: (_) => setState(() => _filtroCategoria = c),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
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
                          crossAxisSpacing: AppSpacing.xl,
                          mainAxisSpacing: AppSpacing.xl,
                          childAspectRatio: Responsive.isMobile(context) ? 1.2 : 0.9,
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
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          clipBehavior: Clip.hardEdge,
          decoration: ShapeDecoration(
            color: AppColors.surfaceElevated,
            shape: AppTheme.cutCorner(
              side: BorderSide(
                color: _isHovered ? AppColors.violetaPrincipal : AppColors.border,
                width: _isHovered ? 1.4 : 1,
              ),
            ),
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.violetaPrincipal.withValues(alpha: 0.22),
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
                  child: proyecto.imagenes.isNotEmpty
                      ? Image.network(proyecto.imagenes.first, fit: BoxFit.cover)
                      : const Center(
                          child:
                              Icon(Icons.image_outlined, color: AppColors.textDim, size: 32),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proyecto.titulo,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        StatusBadge(
                          texto: proyecto.categoria,
                          color: AppColors.cianTech,
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _isHovered ? 1 : 0,
                          child: const Icon(Icons.arrow_forward,
                              size: 16, color: AppColors.cianTech),
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
