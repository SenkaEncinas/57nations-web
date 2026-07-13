import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../theme/app_spacing.dart';
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
        _error = mensajeErrorCarga(e, queCargaba: 'el portfolio');
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
      floatingActionButton: const WhatsAppFlotante(),
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
                          return ProyectoCard(
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
