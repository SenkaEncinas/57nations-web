import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../services/cloudinary_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../utils/whatsapp_helper.dart';
import '../../widgets/widgets.dart';

/// Perfil público de un entrenador externo (no requiere login): foto grande,
/// especialidad, ubicación, tarifa, certificaciones, biografía completa,
/// experiencia y un botón de contacto que va DIRECTO al WhatsApp del
/// entrenador (no al de 57 Nations — son externos, ver CLAUDE.md "Catálogo
/// de Entrenadores"). Cada toque en "Contactar" registra un clic en
/// Firestore: es la base con la que Senka cobra la publicidad mensual.
class PerfilEntrenadorScreen extends StatefulWidget {
  final String entrenadorId;

  const PerfilEntrenadorScreen({super.key, required this.entrenadorId});

  @override
  State<PerfilEntrenadorScreen> createState() => _PerfilEntrenadorScreenState();
}

class _PerfilEntrenadorScreenState extends State<PerfilEntrenadorScreen> {
  final _firebaseService = FirebaseService();
  Entrenador? _entrenador;
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
      final entrenador = await _firebaseService.obtenerEntrenador(widget.entrenadorId);
      setState(() {
        _entrenador = entrenador;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = mensajeErrorCarga(e, queCargaba: 'el perfil');
        _cargando = false;
      });
    }
  }

  /// Registra el clic (no bloquea ni rompe el contacto si falla — es
  /// telemetría, no el flujo principal) y abre WhatsApp directo al
  /// entrenador.
  void _contactar(Entrenador e) {
    _firebaseService.registrarClickContactoEntrenador(e.id, e.nombre).catchError((error) {
      if (kDebugMode) debugPrint('[CLICK ENTRENADOR] No se pudo registrar: $error');
    });
    WhatsAppHelper.abrirChat(
      telefono: e.telefono,
      mensaje: 'Hola ${e.nombre.split(' ').first}! Vi tu perfil en el catálogo de '
          'entrenadores de 57 Nations y quiero entrenar con vos.',
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cuerpo;
    if (_cargando) {
      cuerpo = const PageSection(child: EstadoCargando(mensaje: 'Cargando perfil...'));
    } else if (_error != null) {
      cuerpo = PageSection(child: EstadoError(mensaje: _error!, onReintentar: _cargar));
    } else if (_entrenador == null) {
      cuerpo = PageSection(
        child: Column(
          children: [
            const EstadoVacio(
              icon: Icons.person_search_outlined,
              mensaje: 'No encontramos este entrenador. Puede que ya no esté disponible.',
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('VOLVER'),
            ),
          ],
        ),
      );
    } else {
      cuerpo = _buildPerfil(_entrenador!)
          .animate()
          .fade(duration: 300.ms, curve: Curves.easeOut)
          .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }

    return Scaffold(
      floatingActionButton: const WhatsAppFlotante(),
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

  Widget _buildPerfil(Entrenador e) {
    final isMobile = Responsive.isMobile(context);

    final foto = Container(
      height: isMobile ? 300 : 380,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: AppTheme.cutCorner(side: const BorderSide(color: AppColors.border)),
      ),
      child: e.fotoUrl != null
          ? Image.network(CloudinaryService.optimizar(e.fotoUrl!, ancho: 800), fit: BoxFit.cover)
          : Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: CircuitGridPainter(
                    color: AppColors.entrenamientoColor.withValues(alpha: 0.06),
                    spacing: 32,
                  ),
                ),
                const Center(
                  child: Icon(Icons.person_outline, color: AppColors.textDim, size: 72),
                ),
              ],
            ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (e.especialidad.isNotEmpty)
          StatusBadge(texto: e.especialidad, color: AppColors.entrenamientoColor),
        const SizedBox(height: AppSpacing.lg),
        Text(e.nombre, style: Theme.of(context).textTheme.headlineMedium),
        if (e.ubicacion.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textDim),
              const SizedBox(width: AppSpacing.xs),
              Text(e.ubicacion,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ],
          ),
        ],
        if (e.tarifaAprox.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 15, color: AppColors.textDim),
              const SizedBox(width: AppSpacing.xs),
              Text(e.tarifaAprox,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ],
          ),
        ],
        if (e.certificaciones.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
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
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: e.certificaciones
                .map((c) => StatusBadge(texto: c, color: AppColors.cianTech, relleno: false))
                .toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: e.telefono.isEmpty ? null : () => _contactar(e),
          icon: const Icon(Icons.chat_bubble_outline, size: 16),
          label: Text('CONTACTAR A ${e.nombre.split(' ').first.toUpperCase()}'),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          e.telefono.isEmpty
              ? 'Este entrenador todavía no cargó un número de contacto.'
              : 'Te vas a comunicar directo con ${e.nombre.split(' ').first} por WhatsApp.',
          style: const TextStyle(color: AppColors.textDim, fontSize: 12),
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
                        'ENTRENADORES',
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
                        foto,
                        const SizedBox(height: AppSpacing.xl),
                        info,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: foto),
                        const SizedBox(width: AppSpacing.section),
                        Expanded(flex: 3, child: info),
                      ],
                    ),
            ],
          ),
        ),
        if (e.biografia.trim().isNotEmpty || e.experiencia.isNotEmpty)
          PageSection(
            alternada: true,
            verticalPadding: AppSpacing.sectionLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  overline: 'Sobre mí',
                  titulo: e.nombre.split(' ').first,
                  compacto: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (e.biografia.trim().isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Text(
                      e.biografia,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 15, height: 1.8),
                    ),
                  ),
                if (e.experiencia.isNotEmpty) ...[
                  if (e.biografia.trim().isNotEmpty) const SizedBox(height: AppSpacing.xxl),
                  const Text(
                    'EXPERIENCIA',
                    style: TextStyle(
                      color: AppColors.cianTech,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          e.experiencia.map((item) => _ExperienciaFila(item: item)).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Item de experiencia en el perfil público: viñeta de circuito (cuadradito
/// recortado + línea vertical), título y descripción opcional. Mismo
/// widget visual que `perfil_equipo_screen.dart`, copiado acá porque es
/// privado a ese archivo (los entrenadores no son equipo interno).
class _ExperienciaFila extends StatelessWidget {
  final ExperienciaItem item;

  const _ExperienciaFila({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 8,
              height: 8,
              decoration: ShapeDecoration(
                color: AppColors.violetaPrincipal.withValues(alpha: 0.25),
                shape: AppTheme.cutCorner(
                  size: 2,
                  side: const BorderSide(color: AppColors.violetaPrincipal),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.titulo,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (item.descripcion.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.descripcion,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
