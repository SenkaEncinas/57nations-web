import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

/// Detalle público de un proyecto del Portfolio: galería completa (con
/// lightbox), cliente, categoría, estado, tecnologías y contenido detallado.
class ProyectoDetalleScreen extends StatefulWidget {
  final String proyectoId;

  const ProyectoDetalleScreen({
    super.key,
    required this.proyectoId,
  });

  @override
  State<ProyectoDetalleScreen> createState() => _ProyectoDetalleScreenState();
}

class _ProyectoDetalleScreenState extends State<ProyectoDetalleScreen> {
  final _firebaseService = FirebaseService();
  Proyecto? _proyecto;
  bool _cargando = true;
  String? _error;
  int _fotoSeleccionada = 0;

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
      final proyecto = await _firebaseService.obtenerProyecto(widget.proyectoId);
      setState(() {
        _proyecto = proyecto;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar el proyecto. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  void _abrirLightbox(int indiceInicial) {
    final imagenes = _proyecto?.imagenes ?? [];
    if (imagenes.isEmpty) return;
    showDialog(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (context) => GaleriaLightbox(
        imagenes: imagenes,
        indiceInicial: indiceInicial,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cuerpo;
    if (_cargando) {
      cuerpo = const PageSection(child: EstadoCargando(mensaje: 'Cargando proyecto...'));
    } else if (_error != null) {
      cuerpo = PageSection(child: EstadoError(mensaje: _error!, onReintentar: _cargar));
    } else if (_proyecto == null) {
      cuerpo = PageSection(
        child: Column(
          children: [
            const EstadoVacio(
              icon: Icons.search_off_outlined,
              mensaje: 'No encontramos este proyecto. Puede que haya sido eliminado.',
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('VOLVER AL PORTFOLIO'),
            ),
          ],
        ),
      );
    } else {
      cuerpo = _buildDetalle(_proyecto!);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            cuerpo,
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalle(Proyecto proyecto) {
    final isMobile = Responsive.isMobile(context);

    final galeria = _Galeria(
      imagenes: proyecto.imagenes,
      seleccionada: _fotoSeleccionada,
      onSeleccionar: (i) => setState(() => _fotoSeleccionada = i),
      onAbrir: _abrirLightbox,
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            StatusBadge(texto: proyecto.categoria, color: AppColors.cianTech),
            StatusBadge(
              texto: proyecto.estado,
              color: proyecto.estado == 'Completo' ? AppColors.success : AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(proyecto.titulo, style: Theme.of(context).textTheme.headlineMedium),
        if (proyecto.cliente.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.business_outlined, size: 15, color: AppColors.textDim),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Cliente: ${proyecto.cliente}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text(
          proyecto.descripcion,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.7),
        ),
        if (proyecto.tecnologias.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'TECNOLOGÍAS',
            style: TextStyle(
              color: AppColors.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: proyecto.tecnologias
                .map((t) => Chip(label: Text(t)))
                .toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
          child: const Text('QUIERO ALGO ASÍ'),
        ),
      ],
    );

    return Column(
      children: [
        PageSection(
          verticalPadding: AppSpacing.section,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Migas de pan simples para volver
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 14, color: AppColors.cianTech),
                      SizedBox(width: 6),
                      Text(
                        'PORTFOLIO',
                        style: TextStyle(
                          color: AppColors.cianTech,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              isMobile
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
                        Expanded(flex: 3, child: galeria),
                        const SizedBox(width: AppSpacing.section),
                        Expanded(flex: 2, child: info),
                      ],
                    ),
            ],
          ),
        ),
        if (proyecto.contenidoDetallado.isNotEmpty)
          PageSection(
            alternada: true,
            verticalPadding: AppSpacing.sectionLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  overline: 'El proyecto',
                  titulo: 'En detalle',
                  compacto: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    proyecto.contenidoDetallado,
                    style:
                        const TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Imagen principal + tira de thumbnails. Click en la principal abre lightbox.
class _Galeria extends StatelessWidget {
  final List<String> imagenes;
  final int seleccionada;
  final ValueChanged<int> onSeleccionar;
  final ValueChanged<int> onAbrir;

  const _Galeria({
    required this.imagenes,
    required this.seleccionada,
    required this.onSeleccionar,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    if (imagenes.isEmpty) {
      return Container(
        height: 320,
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: AppTheme.cutCorner(side: const BorderSide(color: AppColors.border)),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, color: AppColors.textDim, size: 48),
        ),
      );
    }

    final indice = seleccionada.clamp(0, imagenes.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.zoomIn,
          child: GestureDetector(
            onTap: () => onAbrir(indice),
            child: Container(
              height: 340,
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: AppTheme.cutCorner(side: const BorderSide(color: AppColors.border)),
              ),
              child: Image.network(imagenes[indice], fit: BoxFit.cover),
            ),
          ),
        ),
        if (imagenes.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
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
                        onTap: () => onSeleccionar(i),
                        child: Container(
                          width: 64,
                          height: 64,
                          clipBehavior: Clip.hardEdge,
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: AppTheme.cutCorner(
                              size: AppTheme.cutSizeSm,
                              side: BorderSide(
                                color: i == indice
                                    ? AppColors.violetaPrincipal
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
  }
}
