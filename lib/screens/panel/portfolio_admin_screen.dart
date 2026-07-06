import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

/// Pantalla de administración del Portfolio (permiso 'portfolio.administrar').
/// Permite crear, editar y borrar proyectos que se muestran públicamente
/// en la web (página de Portfolio). Responsive: funciona en mobile y desktop.
class PortfolioAdminScreen extends StatefulWidget {
  final Usuario usuario;

  const PortfolioAdminScreen({super.key, required this.usuario});

  @override
  State<PortfolioAdminScreen> createState() => _PortfolioAdminScreenState();
}

class _PortfolioAdminScreenState extends State<PortfolioAdminScreen> {
  final _firebaseService = FirebaseService();
  List<Proyecto> _proyectos = [];
  bool _cargando = true;
  String? _error;

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
        _error = 'No pudimos cargar los proyectos. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  void _abrirFormulario({Proyecto? proyectoExistente}) {
    showDialog(
      context: context,
      builder: (context) => _FormularioProyectoDialog(
        proyectoExistente: proyectoExistente,
        onGuardado: _cargar,
      ),
    );
  }

  Future<void> _confirmarEliminar(Proyecto proyecto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar proyecto?', style: TextStyle(color: AppColors.textLight)),
        content: Text(
          'Esto borra "${proyecto.titulo}" de la web pública. No se puede deshacer.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _firebaseService.eliminarProyecto(proyecto.id);
        _cargar();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('No se pudo eliminar: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isCompact(context);

    return RefreshIndicator(
      onRefresh: _cargar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.panel(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: SectionHeader(
                    overline: 'Panel',
                    titulo: 'Administrar Portfolio',
                    subtitulo: 'Estos proyectos aparecen en la página pública de Portfolio.',
                    compacto: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(isCompact ? 'NUEVO' : 'NUEVO PROYECTO'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_cargando)
              const EstadoCargando(mensaje: 'Cargando proyectos...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else if (_proyectos.isEmpty)
              const EstadoVacio(
                  icon: Icons.collections_bookmark_outlined,
                  mensaje: 'Todavía no hay proyectos cargados.')
            else
              ..._proyectos.map((p) => _ProyectoAdminCard(
                    proyecto: p,
                    onEditar: () => _abrirFormulario(proyectoExistente: p),
                    onEliminar: () => _confirmarEliminar(p),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ProyectoAdminCard extends StatelessWidget {
  final Proyecto proyecto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ProyectoAdminCard({
    required this.proyecto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: AppTheme.cutCorner(
                  size: AppTheme.cutSizeSm,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              child: proyecto.imagenes.isNotEmpty
                  ? Image.network(proyecto.imagenes.first, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported, color: AppColors.textDim),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proyecto.titulo,
                    style: const TextStyle(
                        color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge(texto: proyecto.categoria, color: AppColors.violetaPrincipal),
                      StatusBadge(
                        texto: proyecto.estado,
                        color: proyecto.estado == 'Completo'
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    proyecto.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.cianTech, size: 20),
                  tooltip: 'Editar',
                  onPressed: onEditar,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  tooltip: 'Eliminar',
                  onPressed: onEliminar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormularioProyectoDialog extends StatefulWidget {
  final Proyecto? proyectoExistente;
  final VoidCallback onGuardado;

  const _FormularioProyectoDialog({
    this.proyectoExistente,
    required this.onGuardado,
  });

  @override
  State<_FormularioProyectoDialog> createState() => _FormularioProyectoDialogState();
}

class _FormularioProyectoDialogState extends State<_FormularioProyectoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  late TextEditingController _tituloCtrl;
  late TextEditingController _clienteCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _imagenUrlCtrl;
  late TextEditingController _tecnologiasCtrl;
  late TextEditingController _contenidoCtrl;

  String _categoria = CategoriasProyecto.web;
  String _estado = 'Completo';
  bool _guardando = false;

  bool get _esEdicion => widget.proyectoExistente != null;

  @override
  void initState() {
    super.initState();
    final p = widget.proyectoExistente;
    _tituloCtrl = TextEditingController(text: p?.titulo ?? '');
    _clienteCtrl = TextEditingController(text: p?.cliente ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _imagenUrlCtrl =
        TextEditingController(text: p?.imagenes.isNotEmpty == true ? p!.imagenes.first : '');
    _tecnologiasCtrl = TextEditingController(text: p?.tecnologias.join(', ') ?? '');
    _contenidoCtrl = TextEditingController(text: p?.contenidoDetallado ?? '');
    _categoria = p?.categoria ?? CategoriasProyecto.web;
    _estado = p?.estado ?? 'Completo';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _clienteCtrl.dispose();
    _descripcionCtrl.dispose();
    _imagenUrlCtrl.dispose();
    _tecnologiasCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    try {
      final proyecto = Proyecto(
        id: widget.proyectoExistente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloCtrl.text.trim(),
        cliente: _clienteCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        imagenes: _imagenUrlCtrl.text.trim().isEmpty ? [] : [_imagenUrlCtrl.text.trim()],
        tecnologias: _tecnologiasCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        categoria: _categoria,
        estado: _estado,
        fechaCreacion: widget.proyectoExistente?.fechaCreacion ?? DateTime.now(),
        contenidoDetallado: _contenidoCtrl.text.trim(),
      );

      if (_esEdicion) {
        await _firebaseService.actualizarProyecto(proyecto.id, proyecto);
      } else {
        await _firebaseService.crearProyecto(proyecto);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onGuardado();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 80, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _esEdicion ? Icons.edit_outlined : Icons.add_circle_outline,
                        color: AppColors.violetaPrincipal,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _esEdicion ? 'Editar Proyecto' : 'Nuevo Proyecto',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _campo('Título', _tituloCtrl, requerido: true),
                  _campo('Cliente', _clienteCtrl),
                  _campo('Descripción corta', _descripcionCtrl, lineas: 2, requerido: true),
                  _campo('URL de imagen', _imagenUrlCtrl),
                  _campo('Tecnologías (separadas por coma)', _tecnologiasCtrl),
                  _campo('Contenido detallado', _contenidoCtrl, lineas: 4),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _categoria,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    dropdownColor: AppColors.surfaceElevated,
                    items: CategoriasProyecto.todas
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v ?? _categoria),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _estado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    dropdownColor: AppColors.surfaceElevated,
                    items: ['Completo', 'En progreso']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _estado = v ?? _estado),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: _guardando ? null : _guardar,
                        child: _guardando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(AppColors.textLight)),
                              )
                            : const Text('GUARDAR'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController ctrl,
      {int lineas = 1, bool requerido = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextFormField(
        controller: ctrl,
        maxLines: lineas,
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(labelText: label),
        validator:
            requerido ? (v) => (v?.isEmpty ?? true) ? 'Campo requerido' : null : null,
      ),
    );
  }
}
