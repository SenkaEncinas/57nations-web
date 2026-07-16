import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../services/cloudinary_service.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/models.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

/// Catálogo público de entrenadores externos (pagan publicidad mensual a
/// 57 Nations por aparecer acá — ver CLAUDE.md "Catálogo de Entrenadores").
/// Estructura mellizada a `catalogo_3d_screen.dart`: buscador + grilla,
/// cada card lleva al perfil público completo.
class CatalogoEntrenadoresScreen extends StatefulWidget {
  const CatalogoEntrenadoresScreen({super.key});

  @override
  State<CatalogoEntrenadoresScreen> createState() => _CatalogoEntrenadoresScreenState();
}

class _CatalogoEntrenadoresScreenState extends State<CatalogoEntrenadoresScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Entrenador> _entrenadores = [];
  bool _cargando = true;
  String? _error;
  String _filtroEspecialidad = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final entrenadores = await _firebaseService.obtenerEntrenadores();
      setState(() {
        _entrenadores = entrenadores;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = mensajeErrorCarga(e, queCargaba: 'el catálogo de entrenadores');
        _cargando = false;
      });
    }
  }

  /// Deportes/especialidades presentes en el catálogo, para armar los
  /// chips de filtro dinámicamente — no hay una lista fija de deportes,
  /// cada entrenador escribe la suya libremente en su perfil.
  List<String> get _especialidadesDisponibles {
    final set = _entrenadores
        .map((e) => e.especialidad.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Todas', ...set];
  }

  List<Entrenador> get _entrenadoresFiltrados {
    var lista = _entrenadores;
    if (_filtroEspecialidad != 'Todas') {
      lista = lista.where((e) => e.especialidad == _filtroEspecialidad).toList();
    }
    final busqueda = _searchController.text.trim().toLowerCase();
    if (busqueda.isNotEmpty) {
      lista = lista
          .where((e) =>
              e.nombre.toLowerCase().contains(busqueda) ||
              e.especialidad.toLowerCase().contains(busqueda))
          .toList();
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const WhatsAppFlotante(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              overline: 'Entrenamiento',
              titulo: 'Catálogo de Entrenadores',
              subtitulo:
                  'Conocé a los entrenadores que trabajan con nosotros y elegí con '
                  'quién entrenar. Los contactás directo, sin intermediarios.',
              colorAcento: AppColors.entrenamientoColor,
            ),
            PageSection(
              verticalPadding: AppSpacing.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColors.textLight),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o deporte...',
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
                  if (_especialidadesDisponibles.length > 1) ...[
                    const SizedBox(height: AppSpacing.lg),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _especialidadesDisponibles
                            .map((esp) => Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                                  child: _FilterChip(
                                    label: esp,
                                    selected: _filtroEspecialidad == esp,
                                    onSelected: () =>
                                        setState(() => _filtroEspecialidad = esp),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _buildGrid(context),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final crossAxisCount = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);

    Widget contenido;
    if (_cargando) {
      contenido = const EstadoCargando(mensaje: 'Cargando entrenadores...');
    } else if (_error != null) {
      contenido = EstadoError(mensaje: _error!, onReintentar: _cargar);
    } else if (_entrenadoresFiltrados.isEmpty) {
      contenido = EstadoVacio(
        icon: Icons.sports_outlined,
        mensaje: _entrenadores.isEmpty
            ? 'Todavía no hay entrenadores cargados en el catálogo.'
            : 'No encontramos entrenadores con esa búsqueda.',
      );
    } else {
      contenido = GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppSpacing.xl,
          mainAxisSpacing: AppSpacing.xl,
          childAspectRatio: Responsive.isMobile(context) ? 1.05 : 0.78,
        ),
        itemCount: _entrenadoresFiltrados.length,
        itemBuilder: (context, index) => _EntrenadorCard(
          entrenador: _entrenadoresFiltrados[index],
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.perfilEntrenador,
            arguments: _entrenadoresFiltrados[index].id,
          ),
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
      selectedColor: AppColors.entrenamientoColor.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: selected ? AppColors.entrenamientoColor : AppColors.textMuted,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected ? AppColors.entrenamientoColor : AppColors.border,
      ),
    );
  }
}

class _EntrenadorCard extends StatefulWidget {
  final Entrenador entrenador;
  final VoidCallback onTap;

  const _EntrenadorCard({required this.entrenador, required this.onTap});

  @override
  State<_EntrenadorCard> createState() => _EntrenadorCardState();
}

class _EntrenadorCardState extends State<_EntrenadorCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entrenador;

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
            color: AppColors.background,
            shape: AppTheme.cutCorner(
              side: BorderSide(
                color: AppColors.entrenamientoColor.withValues(alpha: _isHovered ? 0.8 : 0.3),
                width: 1,
              ),
            ),
            shadows: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.entrenamientoColor.withValues(alpha: 0.14),
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
                  child: e.fotoUrl != null
                      ? Image.network(
                          CloudinaryService.optimizar(e.fotoUrl!, ancho: 600),
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.person_outline, color: AppColors.textDim, size: 40),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (e.especialidad.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      StatusBadge(texto: e.especialidad, color: AppColors.entrenamientoColor),
                    ],
                    if (e.tarifaAprox.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        e.tarifaAprox,
                        style: const TextStyle(
                          color: AppColors.entrenamientoColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (e.ubicacion.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppColors.textDim),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              e.ubicacion,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
