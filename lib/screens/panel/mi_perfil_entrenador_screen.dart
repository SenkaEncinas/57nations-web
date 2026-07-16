import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../widgets/widgets.dart';

/// "Mi Perfil de Entrenador": cada entrenador externo edita SU PROPIO
/// documento de la colección `entrenadores` (permiso
/// `entrenadores.editar_propio`) — mismo criterio que "Mi Currículum" del
/// equipo interno, pero es una colección aparte (ver CLAUDE.md "Catálogo de
/// Entrenadores"). Arriba del formulario muestra sus propias estadísticas de
/// clics de "Contactar" (este mes / histórico), de solo lectura — es lo que
/// Senka usa para cobrar la publicidad mensual, así el entrenador también
/// puede seguir su propio rendimiento.
class MiPerfilEntrenadorScreen extends StatefulWidget {
  final Usuario usuario;

  const MiPerfilEntrenadorScreen({super.key, required this.usuario});

  @override
  State<MiPerfilEntrenadorScreen> createState() => _MiPerfilEntrenadorScreenState();
}

class _MiPerfilEntrenadorScreenState extends State<MiPerfilEntrenadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final _nombreCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  final _biografiaCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _tarifaCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  final List<_ExperienciaCampos> _experiencias = [];
  final List<TextEditingController> _certificaciones = [];

  String? _fotoUrl;
  bool _activo = true;
  Entrenador? _existente;
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  int _clicksEsteMes = 0;
  int _clicksTotal = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _especialidadCtrl.dispose();
    _biografiaCtrl.dispose();
    _ubicacionCtrl.dispose();
    _telefonoCtrl.dispose();
    _tarifaCtrl.dispose();
    _instagramCtrl.dispose();
    for (final e in _experiencias) {
      e.dispose();
    }
    for (final c in _certificaciones) {
      c.dispose();
    }
    super.dispose();
  }

  void _agregarExperiencia({ExperienciaItem? desde}) {
    setState(() => _experiencias.add(_ExperienciaCampos(desde: desde)));
  }

  void _eliminarExperiencia(_ExperienciaCampos campos) {
    setState(() => _experiencias.remove(campos));
    WidgetsBinding.instance.addPostFrameCallback((_) => campos.dispose());
  }

  void _agregarCertificacion({String texto = ''}) {
    setState(() => _certificaciones.add(TextEditingController(text: texto)));
  }

  void _eliminarCertificacion(TextEditingController ctrl) {
    setState(() => _certificaciones.remove(ctrl));
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.dispose());
  }

  bool _esDelMesActual(DateTime fecha) {
    final ahora = DateTime.now();
    return fecha.year == ahora.year && fecha.month == ahora.month;
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final entrenador =
          await _firebaseService.obtenerEntrenadorPorUsername(widget.usuario.username);

      List<ClickContactoEntrenador> clicks = [];
      if (entrenador != null) {
        clicks = await _firebaseService.obtenerClicksEntrenador(entrenador.id);
      }

      setState(() {
        _existente = entrenador;
        _nombreCtrl.text = entrenador?.nombre ?? widget.usuario.nombre;
        _especialidadCtrl.text = entrenador?.especialidad ?? '';
        _biografiaCtrl.text = entrenador?.biografia ?? '';
        _ubicacionCtrl.text = entrenador?.ubicacion ?? '';
        _telefonoCtrl.text = entrenador?.telefono ?? '';
        _tarifaCtrl.text = entrenador?.tarifaAprox ?? '';
        _instagramCtrl.text = entrenador?.instagramUrl ?? '';
        _fotoUrl = entrenador?.fotoUrl;
        _activo = entrenador?.activo ?? true;

        for (final e in _experiencias) {
          e.dispose();
        }
        _experiencias
          ..clear()
          ..addAll((entrenador?.experiencia ?? []).map((item) => _ExperienciaCampos(desde: item)));

        for (final c in _certificaciones) {
          c.dispose();
        }
        _certificaciones
          ..clear()
          ..addAll((entrenador?.certificaciones ?? []).map((c) => TextEditingController(text: c)));

        _clicksEsteMes = clicks.where((c) => _esDelMesActual(c.fecha)).length;
        _clicksTotal = clicks.length;

        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = mensajeErrorCarga(e, queCargaba: 'tu perfil');
        _cargando = false;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      final entrenador = Entrenador(
        id: _existente?.id ?? widget.usuario.username,
        username: widget.usuario.username,
        nombre: _nombreCtrl.text.trim(),
        especialidad: _especialidadCtrl.text.trim(),
        biografia: _biografiaCtrl.text.trim(),
        experiencia: _experiencias
            .where((e) => e.tituloCtrl.text.trim().isNotEmpty)
            .map((e) => ExperienciaItem(
                  titulo: e.tituloCtrl.text.trim(),
                  descripcion: e.descripcionCtrl.text.trim(),
                ))
            .toList(),
        certificaciones: _certificaciones
            .map((c) => c.text.trim())
            .where((c) => c.isNotEmpty)
            .toList(),
        ubicacion: _ubicacionCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        tarifaAprox: _tarifaCtrl.text.trim(),
        fotoUrl: _fotoUrl,
        instagramUrl: _instagramCtrl.text.trim().isEmpty ? null : _instagramCtrl.text.trim(),
        activo: _activo,
        fechaCreacion: _existente?.fechaCreacion ?? DateTime.now(),
      );

      await _firebaseService.crearOActualizarEntrenador(entrenador);

      if (mounted) {
        setState(() => _existente = entrenador);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil guardado. Ya se ve en el catálogo público.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const EstadoCargando(mensaje: 'Cargando tu perfil...');
    }
    if (_error != null) {
      return EstadoError(mensaje: _error!, onReintentar: _cargar);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.panel(context)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxFormWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              overline: 'Panel',
              titulo: 'Mi Perfil de Entrenador',
              subtitulo:
                  'Esto es lo que se muestra de vos en el catálogo público de '
                  'entrenadores. Editalo cuando quieras.',
              compacto: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            // ===== ESTADÍSTICAS PROPIAS (solo lectura) =====
            TechCard(
              accentColor: AppColors.entrenamientoColor,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: _EstadisticaClicks(
                      label: 'Contactos este mes',
                      valor: _clicksEsteMes,
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: _EstadisticaClicks(label: 'Contactos en total', valor: _clicksTotal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Form(
              key: _formKey,
              child: TechCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectorFotos(
                      etiqueta: 'Foto de perfil',
                      unaSola: true,
                      fotosIniciales: _fotoUrl != null ? [_fotoUrl!] : const [],
                      onChanged: (urls) => _fotoUrl = urls.isEmpty ? null : urls.first,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _campo('Nombre', _nombreCtrl, requerido: true),
                    _campo('Especialidad (ej: Básquet, Funcional, Boxeo)', _especialidadCtrl),
                    _campo('Ubicación (ej: Santa Cruz, Equipetrol)', _ubicacionCtrl),
                    _campo('WhatsApp de contacto (con código de país)', _telefonoCtrl,
                        requerido: true),
                    _campo('Tarifa aproximada (ej: Bs 100/hora)', _tarifaCtrl),
                    _campo(
                      'Contanos sobre vos, tu experiencia y tu forma de entrenar',
                      _biografiaCtrl,
                      lineas: 8,
                    ),
                    // ===== CERTIFICACIONES (lista dinámica) =====
                    const Text(
                      'CERTIFICACIONES',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._certificaciones.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: c,
                                  style: const TextStyle(color: AppColors.textLight),
                                  decoration: const InputDecoration(
                                    labelText: 'Ej: Licencia FIBA nivel 1',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.error, size: 20),
                                onPressed: () => _eliminarCertificacion(c),
                              ),
                            ],
                          ),
                        )),
                    OutlinedButton.icon(
                      onPressed: _agregarCertificacion,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('AGREGAR CERTIFICACIÓN'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // ===== EXPERIENCIA (lista dinámica) =====
                    const Text(
                      'EXPERIENCIA',
                      style: TextStyle(
                        color: AppColors.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Items puntuales de tu recorrido. Se muestran como lista en tu perfil público.',
                      style: TextStyle(color: AppColors.textDim, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ..._experiencias.map((e) => _ExperienciaEditor(
                          key: ObjectKey(e),
                          campos: e,
                          onEliminar: () => _eliminarExperiencia(e),
                        )),
                    OutlinedButton.icon(
                      onPressed: _agregarExperiencia,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('AGREGAR EXPERIENCIA'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _campo('Instagram (URL, opcional)', _instagramCtrl),
                    SwitchListTile(
                      value: _activo,
                      onChanged: (v) => setState(() => _activo = v),
                      title: const Text('Visible en el catálogo público',
                          style: TextStyle(color: AppColors.textLight)),
                      subtitle: const Text(
                        'Si lo apagás, tu perfil deja de aparecer en el catálogo '
                        '(pero no se borra).',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      activeThumbColor: AppColors.entrenamientoColor,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        icon: _guardando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(AppColors.textLight)),
                              )
                            : const Icon(Icons.save_outlined, size: 18),
                        label: Text(_guardando ? 'GUARDANDO...' : 'GUARDAR PERFIL'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: lineas > 1,
        ),
        validator:
            requerido ? (v) => (v?.isEmpty ?? true) ? 'Campo requerido' : null : null,
      ),
    );
  }
}

class _EstadisticaClicks extends StatelessWidget {
  final String label;
  final int valor;

  const _EstadisticaClicks({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textDim,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$valor',
          style: const TextStyle(
            color: AppColors.entrenamientoColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// Par de controladores de un item de experiencia en edición.
class _ExperienciaCampos {
  final TextEditingController tituloCtrl;
  final TextEditingController descripcionCtrl;

  _ExperienciaCampos({ExperienciaItem? desde})
      : tituloCtrl = TextEditingController(text: desde?.titulo ?? ''),
        descripcionCtrl = TextEditingController(text: desde?.descripcion ?? '');

  void dispose() {
    tituloCtrl.dispose();
    descripcionCtrl.dispose();
  }
}

/// Editor visual de un item de experiencia: título + descripción opcional
/// y botón para eliminar ese item puntual.
class _ExperienciaEditor extends StatelessWidget {
  final _ExperienciaCampos campos;
  final VoidCallback onEliminar;

  const _ExperienciaEditor({
    super.key,
    required this.campos,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const ShapeDecoration(
        color: AppColors.surface,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: campos.tituloCtrl,
                  style: const TextStyle(color: AppColors.textLight),
                  decoration: const InputDecoration(
                    labelText: 'Título (ej: 5 años entrenando en Club Tahuichi)',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                tooltip: 'Eliminar esta experiencia',
                onPressed: onEliminar,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: campos.descripcionCtrl,
            maxLines: 2,
            style: const TextStyle(color: AppColors.textLight),
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
