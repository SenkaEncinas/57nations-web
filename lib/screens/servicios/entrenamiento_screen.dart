import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/widgets.dart';
import 'servicio_screen_base.dart';

/// Página de Entrenamiento — MULTI-DEPORTE (agosto 2026): ya no es solo
/// básquet, cualquier entrenador de cualquier disciplina puede aparecer en
/// el catálogo (ver CLAUDE.md "Catálogo de Entrenadores"). A diferencia de
/// las otras 4 páginas de servicio (estáticas), esta es la única con datos
/// reales detrás: por eso muestra una vidriera en vivo de entrenadores
/// cargados, no solo texto — es la principal mejora de UI pedida: que se
/// vea y se sienta la variedad real de disciplinas, no una lista de texto.
class EntrenamientoScreen extends StatefulWidget {
  const EntrenamientoScreen({super.key});

  @override
  State<EntrenamientoScreen> createState() => _EntrenamientoScreenState();
}

class _EntrenamientoScreenState extends State<EntrenamientoScreen> {
  static const int _maxPreview = 4;

  final _firebaseService = FirebaseService();
  List<Entrenador> _entrenadores = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final entrenadores = await _firebaseService.obtenerEntrenadores();
      if (!mounted) return;
      setState(() {
        _entrenadores = entrenadores.take(_maxPreview).toList();
        _cargando = false;
      });
    } catch (e) {
      // Vidriera opcional: si falla, la página no se rompe, simplemente
      // no se muestra (mismo criterio que el preview de Portfolio del Home).
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ServicioScreenBase(
      titulo: 'Entrenamiento',
      subtitulo:
          'Entrenamiento personalizado, uno a uno, en el deporte o disciplina '
          'que practiques — básquet, fútbol, funcional, boxeo, voleibol y más. '
          'Elegís al entrenador del catálogo y arreglás directo con él.',
      colorAcento: AppColors.entrenamientoColor,
      accionSecundaria: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.catalogoEntrenadores),
        child: const Text('VER ENTRENADORES'),
      ),
      tituloCta: '¿No sabés por dónde arrancar?',
      subtituloCta:
          'Contanos qué deporte querés entrenar y tu nivel actual, y te '
          'ayudamos a encontrar al entrenador que mejor encaje. Sin costo ni '
          'compromiso.',
      textoBotonCta: 'CONSULTAR AHORA',
      capacidades: const [
        CapacidadServicio(
          icon: Icons.sports_outlined,
          titulo: 'Cualquier disciplina',
          descripcion:
              'Básquet, fútbol, funcional, boxeo, voleibol y más — el '
              'catálogo suma disciplinas nuevas a medida que se suman '
              'entrenadores.',
        ),
        CapacidadServicio(
          icon: Icons.psychology_outlined,
          titulo: 'Técnica y táctica',
          descripcion:
              'Trabajás tu técnica individual y tu lectura del juego, uno a '
              'uno, corrigiendo lo que hace falta a tu ritmo.',
        ),
        CapacidadServicio(
          icon: Icons.trending_up_outlined,
          titulo: 'Plan de desarrollo',
          descripcion:
              'Armás un plan con objetivos claros junto a tu entrenador y '
              'hacés seguimiento de tu progreso, empieces de cero o ya compitas.',
        ),
      ],
      contenidoExtra: (_cargando || _entrenadores.isEmpty)
          ? null
          : _VidrieraEntrenadores(entrenadores: _entrenadores),
    );
  }
}

/// Vidriera en vivo: unos pocos entrenadores reales del catálogo, para que
/// la página muestre la variedad de disciplinas de un vistazo en vez de
/// solo describirla en texto.
class _VidrieraEntrenadores extends StatelessWidget {
  final List<Entrenador> entrenadores;

  const _VidrieraEntrenadores({required this.entrenadores});

  @override
  Widget build(BuildContext context) {
    final columnas = Responsive.valor(context, mobile: 2, tablet: 4, desktop: 4);

    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Catálogo',
            titulo: 'Algunos de nuestros entrenadores',
            subtitulo: 'Cada uno con su disciplina, su tarifa y su forma de entrenar.',
            accentColor: AppColors.entrenamientoColor,
          ),
          const SizedBox(height: AppSpacing.xxl),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisSpacing: AppSpacing.lg,
              childAspectRatio: 0.78,
            ),
            itemCount: entrenadores.length,
            itemBuilder: (context, i) => _EntrenadorMiniCard(entrenador: entrenadores[i]),
          ),
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.catalogoEntrenadores),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('VER TODOS LOS ENTRENADORES'),
          ),
        ],
      ),
    );
  }
}

class _EntrenadorMiniCard extends StatefulWidget {
  final Entrenador entrenador;

  const _EntrenadorMiniCard({required this.entrenador});

  @override
  State<_EntrenadorMiniCard> createState() => _EntrenadorMiniCardState();
}

class _EntrenadorMiniCardState extends State<_EntrenadorMiniCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entrenador;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.perfilEntrenador, arguments: e.id),
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
              ),
            ),
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
                          CloudinaryService.optimizar(e.fotoUrl!, ancho: 300),
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.person_outline, color: AppColors.textDim, size: 32),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.nombre,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (e.especialidad.isNotEmpty)
                      Text(
                        e.especialidad,
                        style: const TextStyle(color: AppColors.entrenamientoColor, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
