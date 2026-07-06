import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../widgets/widgets.dart';

/// "Mi Currículum": cada socio/colaborador edita SU PROPIO documento de la
/// colección `equipo` (permiso 'equipo.editar_propio'). Se busca por
/// username == usuario logueado; si no existe todavía, se crea con id =
/// username. Lo que se guarda acá es lo que se muestra públicamente en el
/// Home y en Sobre Nosotros.
class MiCurriculumScreen extends StatefulWidget {
  final Usuario usuario;

  const MiCurriculumScreen({super.key, required this.usuario});

  @override
  State<MiCurriculumScreen> createState() => _MiCurriculumScreenState();
}

class _MiCurriculumScreenState extends State<MiCurriculumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final _nombreCtrl = TextEditingController();
  final _rolCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  final _biografiaCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();

  String? _fotoUrl;
  MiembroEquipo? _existente; // documento actual, si ya existe
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _rolCtrl.dispose();
    _especialidadCtrl.dispose();
    _biografiaCtrl.dispose();
    _instagramCtrl.dispose();
    _linkedinCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final miembro =
          await _firebaseService.obtenerMiembroEquipoPorUsername(widget.usuario.username);
      setState(() {
        _existente = miembro;
        _nombreCtrl.text = miembro?.nombre ?? widget.usuario.nombre;
        _rolCtrl.text = miembro?.rol ?? '';
        _especialidadCtrl.text = miembro?.especialidad ?? '';
        _biografiaCtrl.text = miembro?.biografia ?? '';
        _instagramCtrl.text = miembro?.instagramUrl ?? '';
        _linkedinCtrl.text = miembro?.linkedinUrl ?? '';
        _fotoUrl = miembro?.fotoUrl;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar tu currículum. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      final miembro = MiembroEquipo(
        // Si ya existía un doc (aunque sea con id viejo), se respeta su id;
        // si es nuevo, el id es el username.
        id: _existente?.id ?? widget.usuario.username,
        username: widget.usuario.username,
        nombre: _nombreCtrl.text.trim(),
        rol: _rolCtrl.text.trim(),
        especialidad: _especialidadCtrl.text.trim(),
        biografia: _biografiaCtrl.text.trim(),
        fotoUrl: _fotoUrl,
        instagramUrl:
            _instagramCtrl.text.trim().isEmpty ? null : _instagramCtrl.text.trim(),
        linkedinUrl:
            _linkedinCtrl.text.trim().isEmpty ? null : _linkedinCtrl.text.trim(),
      );

      await _firebaseService.crearOActualizarMiembroEquipo(miembro);

      if (mounted) {
        setState(() => _existente = miembro);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Currículum guardado. Ya se ve en la web pública.'),
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
      return const EstadoCargando(mensaje: 'Cargando tu currículum...');
    }
    if (_error != null) {
      return EstadoError(mensaje: _error!, onReintentar: _cargar);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.panel(context)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxFormWidth),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                overline: 'Panel',
                titulo: 'Mi Currículum',
                subtitulo:
                    'Esto es lo que se muestra de vos en la web pública (Home y Sobre '
                    'Nosotros). Editalo cuando quieras.',
                compacto: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              TechCard(
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
                    _campo('Rol (ej: Fundador, Diseñador 3D, Artista)', _rolCtrl,
                        requerido: true),
                    _campo('Especialidad', _especialidadCtrl),
                    _campo(
                      'Contanos sobre vos, como quieras presentarte',
                      _biografiaCtrl,
                      lineas: 8,
                    ),
                    _campo('Instagram (URL, opcional)', _instagramCtrl),
                    _campo('LinkedIn (URL, opcional)', _linkedinCtrl),
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
                        label: Text(_guardando ? 'GUARDANDO...' : 'GUARDAR CURRÍCULUM'),
                      ),
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
