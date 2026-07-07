import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';

/// Administración del Catálogo 3D público (permiso 'catalogo3d.administrar',
/// Luchin y Admin). Lista TODAS las piezas — incluidas las no disponibles,
/// a diferencia del catálogo público — con alta, edición y borrado.
class Catalogo3dAdminScreen extends StatefulWidget {
  final Usuario usuario;

  const Catalogo3dAdminScreen({super.key, required this.usuario});

  @override
  State<Catalogo3dAdminScreen> createState() => _Catalogo3dAdminScreenState();
}

class _Catalogo3dAdminScreenState extends State<Catalogo3dAdminScreen> {
  final _firebaseService = FirebaseService();
  List<Impresion3D> _impresiones = [];
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
      final impresiones = await _firebaseService.obtenerTodasImpresiones3D();
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

  void _abrirFormulario({Impresion3D? existente}) {
    showDialog(
      context: context,
      builder: (context) => _FormularioImpresionDialog(
        existente: existente,
        onGuardado: _cargar,
      ),
    );
  }

  Future<void> _confirmarEliminar(Impresion3D impresion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar pieza?', style: TextStyle(color: AppColors.textLight)),
        content: Text(
          'Esto borra "${impresion.nombre}" del catálogo público. No se puede deshacer.',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await _firebaseService.eliminarImpresion3D(impresion.id);
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
                    titulo: 'Catálogo 3D',
                    subtitulo:
                        'Las piezas disponibles aparecen en el catálogo público; '
                        'las no disponibles solo se ven acá.',
                    accentColor: AppColors.impresion3dColor,
                    compacto: true,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(isCompact ? 'NUEVA' : 'NUEVA PIEZA'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_cargando)
              const EstadoCargando(mensaje: 'Cargando catálogo...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else if (_impresiones.isEmpty)
              const EstadoVacio(
                  icon: Icons.view_in_ar_outlined,
                  mensaje: 'Todavía no hay piezas cargadas. Creá la primera con "Nueva pieza".')
            else
              ..._impresiones.map((i) => _ImpresionAdminCard(
                    impresion: i,
                    onEditar: () => _abrirFormulario(existente: i),
                    onEliminar: () => _confirmarEliminar(i),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ImpresionAdminCard extends StatelessWidget {
  final Impresion3D impresion;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ImpresionAdminCard({
    required this.impresion,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        accentColor: AppColors.impresion3dColor,
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
              child: impresion.imagenes.isNotEmpty
                  ? Image.network(
                      CloudinaryService.optimizar(impresion.imagenes.first, ancho: 200),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.view_in_ar_outlined, color: AppColors.textDim),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    impresion.nombre,
                    style: const TextStyle(
                        color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      StatusBadge(
                          texto: impresion.categoria.isEmpty
                              ? 'Sin categoría'
                              : impresion.categoria,
                          color: AppColors.impresion3dColor),
                      StatusBadge(
                        texto: impresion.disponible ? 'Disponible' : 'No disponible',
                        color: impresion.disponible ? AppColors.success : AppColors.textDim,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Desde Bs ${impresion.precioBase.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.impresion3dColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
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

class _FormularioImpresionDialog extends StatefulWidget {
  final Impresion3D? existente;
  final VoidCallback onGuardado;

  const _FormularioImpresionDialog({
    this.existente,
    required this.onGuardado,
  });

  @override
  State<_FormularioImpresionDialog> createState() => _FormularioImpresionDialogState();
}

class _FormularioImpresionDialogState extends State<_FormularioImpresionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  // Mismas categorías que filtra el catálogo público.
  static const _categorias = ['Decorativa', 'Funcional', 'Accesorio'];

  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _materialCtrl;
  late TextEditingController _pesoCtrl;
  late TextEditingController _tiempoCtrl;
  late TextEditingController _coloresCtrl;

  late List<String> _imagenes;
  String _categoria = _categorias.first;
  bool _disponible = true;
  bool _guardando = false;

  bool get _esEdicion => widget.existente != null;

  @override
  void initState() {
    super.initState();
    final i = widget.existente;
    _nombreCtrl = TextEditingController(text: i?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: i?.descripcion ?? '');
    _precioCtrl = TextEditingController(text: i != null ? i.precioBase.toString() : '');
    _materialCtrl = TextEditingController(text: i?.material ?? 'PLA+');
    _pesoCtrl = TextEditingController(text: i != null ? i.peso.toString() : '');
    _tiempoCtrl =
        TextEditingController(text: i != null ? i.tiempoImpresion.toString() : '');
    _coloresCtrl = TextEditingController(text: i?.coloresDisponibles.join(', ') ?? '');
    _imagenes = List<String>.from(i?.imagenes ?? []);
    _categoria = _categorias.contains(i?.categoria) ? i!.categoria : _categorias.first;
    _disponible = i?.disponible ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _materialCtrl.dispose();
    _pesoCtrl.dispose();
    _tiempoCtrl.dispose();
    _coloresCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    try {
      final impresion = Impresion3D(
        id: widget.existente?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        imagenes: _imagenes,
        precioBase: double.tryParse(_precioCtrl.text) ?? 0,
        material: _materialCtrl.text.trim(),
        peso: double.tryParse(_pesoCtrl.text) ?? 0,
        categoria: _categoria,
        disponible: _disponible,
        fechaCreacion: widget.existente?.fechaCreacion ?? DateTime.now(),
        archivo3d: widget.existente?.archivo3d,
        tiempoImpresion: int.tryParse(_tiempoCtrl.text) ?? 0,
        coloresDisponibles: _coloresCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );

      if (_esEdicion) {
        await _firebaseService.actualizarImpresion3D(impresion.id, impresion);
      } else {
        await _firebaseService.crearImpresion3D(impresion);
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
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
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
                        color: AppColors.impresion3dColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _esEdicion ? 'Editar pieza' : 'Nueva pieza',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _campo('Nombre de la pieza', _nombreCtrl, requerido: true),
                  _campo('Descripción', _descripcionCtrl, lineas: 3),
                  SelectorFotos(
                    etiqueta: 'Fotos de la pieza',
                    fotosIniciales: _imagenes,
                    onChanged: (urls) => _imagenes = urls,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _categoria,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    dropdownColor: AppColors.surfaceElevated,
                    items: _categorias
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v ?? _categoria),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(children: [
                    Expanded(
                        child: _campoNumero('Precio base (Bs)', _precioCtrl,
                            requerido: true)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _campo('Material', _materialCtrl)),
                  ]),
                  Row(children: [
                    Expanded(child: _campoNumero('Peso (g)', _pesoCtrl)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _campoNumero('Tiempo impresión (min)', _tiempoCtrl)),
                  ]),
                  _campo('Colores disponibles (separados por coma)', _coloresCtrl),
                  SwitchListTile(
                    value: _disponible,
                    onChanged: (v) => setState(() => _disponible = v),
                    title: const Text('Disponible en el catálogo público',
                        style: TextStyle(color: AppColors.textLight)),
                    subtitle: const Text(
                      'Disponible = tenemos el archivo y se imprime bajo pedido.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    activeThumbColor: AppColors.impresion3dColor,
                    contentPadding: EdgeInsets.zero,
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
        decoration: InputDecoration(labelText: label, alignLabelWithHint: lineas > 1),
        validator:
            requerido ? (v) => (v?.isEmpty ?? true) ? 'Campo requerido' : null : null,
      ),
    );
  }

  Widget _campoNumero(String label, TextEditingController ctrl, {bool requerido = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(labelText: label),
        validator: requerido
            ? (v) => (double.tryParse(v ?? '') == null) ? 'Número inválido' : null
            : null,
      ),
    );
  }
}
