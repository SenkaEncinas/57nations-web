import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../services/cloudinary_service.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';
import 'mi_perfil_entrenador_screen.dart';

/// Panel de estadísticas de entrenadores — SOLO Admin. Es la base con la que
/// Senka cobra la publicidad mensual de cada entrenador: cuántos clics en
/// "Contactar" tuvo cada uno (este mes / histórico), un switch para pausar
/// la visibilidad de quien deje de pagar (sin borrar su perfil ni su
/// historial), y un botón para editar el perfil de CUALQUIER entrenador
/// (reutiliza `MiPerfilEntrenadorScreen` en modo Admin — ver su doc). Ver
/// CLAUDE.md "Catálogo de Entrenadores".
class EntrenadoresDashboardScreen extends StatefulWidget {
  final Usuario usuario;

  const EntrenadoresDashboardScreen({super.key, required this.usuario});

  @override
  State<EntrenadoresDashboardScreen> createState() => _EntrenadoresDashboardScreenState();
}

class _EntrenadoresDashboardScreenState extends State<EntrenadoresDashboardScreen> {
  final _firebaseService = FirebaseService();

  List<Entrenador> _entrenadores = [];
  List<ClickContactoEntrenador> _clicks = [];
  bool _cargando = true;
  String? _error;
  bool _soloEsteMes = true;

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
      final resultados = await Future.wait([
        _firebaseService.obtenerTodosEntrenadores(),
        _firebaseService.obtenerTodosLosClicksEntrenadores(),
      ]);
      setState(() {
        _entrenadores = resultados[0] as List<Entrenador>;
        _clicks = resultados[1] as List<ClickContactoEntrenador>;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = mensajeErrorCarga(e, queCargaba: 'las estadísticas de entrenadores');
        _cargando = false;
      });
    }
  }

  bool _esDelMesActual(DateTime fecha) {
    final ahora = DateTime.now();
    return fecha.year == ahora.year && fecha.month == ahora.month;
  }

  int _clicksDe(String entrenadorId) {
    return _clicks
        .where((c) =>
            c.entrenadorId == entrenadorId && (!_soloEsteMes || _esDelMesActual(c.fecha)))
        .length;
  }

  int get _clicksEsteMesTotal =>
      _clicks.where((c) => _esDelMesActual(c.fecha)).length;

  List<Entrenador> get _entrenadoresOrdenados {
    final lista = List<Entrenador>.from(_entrenadores);
    lista.sort((a, b) => _clicksDe(b.id).compareTo(_clicksDe(a.id)));
    return lista;
  }

  /// El de más contactos en el período elegido (este mes / histórico) — o
  /// null si nadie tuvo ningún clic todavía. Explícito acá para no dejar
  /// que "quién es el más popular" quede implícito solo en el orden de la
  /// lista de abajo.
  Entrenador? get _masPopular {
    if (_entrenadoresOrdenados.isEmpty) return null;
    final top = _entrenadoresOrdenados.first;
    return _clicksDe(top.id) > 0 ? top : null;
  }

  Future<void> _toggleActivo(Entrenador e, bool activo) async {
    setState(() {
      final i = _entrenadores.indexWhere((x) => x.id == e.id);
      if (i != -1) {
        _entrenadores[i] = Entrenador(
          id: e.id,
          username: e.username,
          nombre: e.nombre,
          especialidad: e.especialidad,
          biografia: e.biografia,
          experiencia: e.experiencia,
          certificaciones: e.certificaciones,
          ubicacion: e.ubicacion,
          telefono: e.telefono,
          tarifaAprox: e.tarifaAprox,
          fotoUrl: e.fotoUrl,
          instagramUrl: e.instagramUrl,
          activo: activo,
          fechaCreacion: e.fechaCreacion,
        );
      }
    });
    try {
      await _firebaseService.actualizarActivoEntrenador(e.id, activo);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar: $err'), backgroundColor: AppColors.error),
        );
        _cargar();
      }
    }
  }

  /// Abre el mismo formulario de "Mi Perfil de Entrenador" pero apuntando
  /// al entrenador [e] en vez de al usuario logueado — así Admin puede
  /// completar o corregir el perfil de cualquiera (útil si un entrenador
  /// no es muy técnico y necesita ayuda para cargar su info).
  void _editarEntrenador(Entrenador e) {
    showDialog(
      context: context,
      barrierColor: AppColors.overlayDark,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: Responsive.isMobile(context) ? AppSpacing.lg : 80,
          vertical: AppSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
          child: MiPerfilEntrenadorScreen(
            usuario: widget.usuario,
            entrenadorAEditar: e,
            onGuardado: _cargar,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargar,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.panel(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              overline: 'Panel',
              titulo: 'Entrenadores',
              subtitulo:
                  'Clics en "Contactar" por entrenador — la base para cobrar la '
                  'publicidad mensual de cada uno.',
              accentColor: AppColors.entrenamientoColor,
              compacto: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_cargando)
              const EstadoCargando(mensaje: 'Cargando estadísticas...')
            else if (_error != null)
              EstadoError(mensaje: _error!, onReintentar: _cargar)
            else if (_entrenadores.isEmpty)
              const EstadoVacio(
                icon: Icons.sports_outlined,
                mensaje:
                    'Todavía no hay entrenadores cargados. Creá la cuenta desde Firebase '
                    'Console y pedile que complete su perfil en "Mi Perfil de Entrenador".',
              )
            else ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final columnas = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);
                  final ancho =
                      (constraints.maxWidth - AppSpacing.lg * (columnas - 1)) / columnas;
                  return Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.lg,
                    children: [
                      SizedBox(
                        width: ancho,
                        child: _StatCard(
                          icon: Icons.groups_outlined,
                          label: 'Entrenadores activos',
                          valor: '${_entrenadores.where((e) => e.activo).length}',
                          nota: 'De ${_entrenadores.length} cargados en total',
                        ),
                      ),
                      SizedBox(
                        width: ancho,
                        child: _StatCard(
                          icon: Icons.touch_app_outlined,
                          label: 'Contactos este mes (todos)',
                          valor: '$_clicksEsteMesTotal',
                          nota: 'Suma de clics en "Contactar" de todo el catálogo',
                        ),
                      ),
                      SizedBox(
                        width: ancho,
                        child: _StatCard(
                          icon: Icons.emoji_events_outlined,
                          label: 'Más popular (${_soloEsteMes ? "este mes" : "histórico"})',
                          valor: _masPopular?.nombre ?? '—',
                          valorFontSize: 18,
                          nota: _masPopular == null
                              ? 'Todavía nadie tuvo contactos en este período'
                              : '${_clicksDe(_masPopular!.id)} contactos',
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                spacing: AppSpacing.md,
                children: [
                  ChoiceChip(
                    label: const Text('Este mes'),
                    selected: _soloEsteMes,
                    onSelected: (_) => setState(() => _soloEsteMes = true),
                  ),
                  ChoiceChip(
                    label: const Text('Histórico'),
                    selected: !_soloEsteMes,
                    onSelected: (_) => setState(() => _soloEsteMes = false),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ..._entrenadoresOrdenados.map((e) => _FilaEntrenador(
                    entrenador: e,
                    clicks: _clicksDe(e.id),
                    esMasPopular: _masPopular?.id == e.id,
                    onActivoCambiado: (v) => _toggleActivo(e, v),
                    onEditar: () => _editarEntrenador(e),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final String nota;
  final double valorFontSize;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.valor,
    required this.nota,
    this.valorFontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return TechCard(
      accentColor: AppColors.entrenamientoColor,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.entrenamientoColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.entrenamientoColor,
              fontSize: valorFontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(nota, style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FilaEntrenador extends StatelessWidget {
  final Entrenador entrenador;
  final int clicks;
  final bool esMasPopular;
  final ValueChanged<bool> onActivoCambiado;
  final VoidCallback onEditar;

  const _FilaEntrenador({
    required this.entrenador,
    required this.clicks,
    required this.esMasPopular,
    required this.onActivoCambiado,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    final e = entrenador;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TechCard(
        accentColor: AppColors.entrenamientoColor,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: AppTheme.cutCorner(
                  size: AppTheme.cutSizeSm,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              child: e.fotoUrl != null
                  ? Image.network(
                      CloudinaryService.optimizar(e.fotoUrl!, ancho: 200),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person_outline, color: AppColors.textDim),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.nombre.isEmpty ? '(sin nombre cargado)' : e.nombre,
                    style: const TextStyle(
                        color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (esMasPopular)
                        const StatusBadge(texto: '★ Más popular', color: AppColors.cianTech),
                      if (e.especialidad.isNotEmpty)
                        StatusBadge(texto: e.especialidad, color: AppColors.entrenamientoColor),
                      StatusBadge(
                        texto: e.activo ? 'Activo' : 'Inactivo',
                        color: e.activo ? AppColors.success : AppColors.textDim,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$clicks',
                  style: const TextStyle(
                    color: AppColors.entrenamientoColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'contactos',
                  style: TextStyle(color: AppColors.textDim, fontSize: 11),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.cianTech, size: 20),
              tooltip: 'Editar perfil',
              onPressed: onEditar,
            ),
            Switch(
              value: e.activo,
              onChanged: onActivoCambiado,
              activeThumbColor: AppColors.entrenamientoColor,
            ),
          ],
        ),
      ),
    );
  }
}
