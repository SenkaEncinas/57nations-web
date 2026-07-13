import 'package:flutter/material.dart';
import '../../utils/firestore_errors.dart';
import '../../services/cloudinary_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_config.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../utils/whatsapp_helper.dart';
import '../../widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Perfil público de un miembro del equipo (no requiere login): foto grande,
/// rol, especialidad, biografía completa (su "currículum" libre), redes y un
/// CTA de contacto por WhatsApp que menciona a la persona. Se llega desde las
/// cards de equipo del Home y de Sobre Nosotros.
class PerfilEquipoScreen extends StatefulWidget {
  final String miembroId;

  const PerfilEquipoScreen({super.key, required this.miembroId});

  @override
  State<PerfilEquipoScreen> createState() => _PerfilEquipoScreenState();
}

class _PerfilEquipoScreenState extends State<PerfilEquipoScreen> {
  final _firebaseService = FirebaseService();
  MiembroEquipo? _miembro;
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
      final miembro = await _firebaseService.obtenerMiembroEquipo(widget.miembroId);
      setState(() {
        _miembro = miembro;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = mensajeErrorCarga(e, queCargaba: 'el perfil');
        _cargando = false;
      });
    }
  }

  void _contactar(MiembroEquipo m) {
    WhatsAppHelper.abrirChat(
      telefono: AppConfig.whatsappAdminNumero,
      mensaje: 'Hola 57 Nations! Vi el perfil de ${m.nombre} en la web y me '
          'gustaría hablar sobre un proyecto con ${m.nombre.split(' ').first}.',
    );
  }

  Future<void> _abrirUrl(String url) async {
    var destino = url.trim();
    if (destino.isEmpty) return;
    if (!destino.startsWith('http')) destino = 'https://$destino';
    final uri = Uri.parse(destino);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cuerpo;
    if (_cargando) {
      cuerpo = const PageSection(child: EstadoCargando(mensaje: 'Cargando perfil...'));
    } else if (_error != null) {
      cuerpo = PageSection(child: EstadoError(mensaje: _error!, onReintentar: _cargar));
    } else if (_miembro == null) {
      cuerpo = PageSection(
        child: Column(
          children: [
            const EstadoVacio(
              icon: Icons.person_search_outlined,
              mensaje: 'No encontramos este perfil. Puede que ya no forme parte del equipo.',
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
      cuerpo = _buildPerfil(_miembro!)
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

  Widget _buildPerfil(MiembroEquipo m) {
    final isMobile = Responsive.isMobile(context);

    final foto = Container(
      height: isMobile ? 300 : 380,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: AppTheme.cutCorner(side: const BorderSide(color: AppColors.border)),
      ),
      child: m.fotoUrl != null
          ? Image.network(CloudinaryService.optimizar(m.fotoUrl!, ancho: 800), fit: BoxFit.cover)
          : Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: CircuitGridPainter(
                    color: AppColors.violetaPrincipal.withValues(alpha: 0.06),
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
        if (m.rol.isNotEmpty)
          StatusBadge(texto: m.rol, color: AppColors.cianTech),
        const SizedBox(height: AppSpacing.lg),
        Text(m.nombre, style: Theme.of(context).textTheme.headlineMedium),
        if (m.especialidad.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            m.especialidad,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.6),
          ),
        ],
        if (m.instagramUrl != null || m.linkedinUrl != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              if (m.instagramUrl != null)
                OutlinedButton.icon(
                  onPressed: () => _abrirUrl(m.instagramUrl!),
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text('INSTAGRAM'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                ),
              if (m.linkedinUrl != null)
                OutlinedButton.icon(
                  onPressed: () => _abrirUrl(m.linkedinUrl!),
                  icon: const Icon(Icons.work_outline, size: 16),
                  label: const Text('LINKEDIN'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        ElevatedButton.icon(
          onPressed: () => _contactar(m),
          icon: const Icon(Icons.chat_bubble_outline, size: 16),
          label: Text('HABLAR CON ${m.nombre.split(' ').first.toUpperCase()}'),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Te respondemos por WhatsApp desde el número oficial de 57 Nations.',
          style: TextStyle(color: AppColors.textDim, fontSize: 12),
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
                        'EQUIPO',
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
        PageSection(
          alternada: true,
          verticalPadding: AppSpacing.sectionLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                overline: 'Currículum',
                titulo: 'Sobre ${m.nombre.split(' ').first}',
                compacto: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (m.biografia.trim().isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Text(
                    m.biografia,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 15, height: 1.8),
                  ),
                )
              else if (m.experiencia.isNotEmpty)
                // Hay experiencia cargada pero no biografía: no mostramos la
                // card de "está preparando su presentación", la experiencia
                // de abajo ya cuenta la historia.
                const SizedBox.shrink()
              else
                // Biografía todavía no cargada: nada de sección vacía o rota.
                TechCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.edit_note_outlined,
                          color: AppColors.violetaPrincipal, size: 28),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '${m.nombre.split(' ').first} todavía está preparando su presentación completa.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Mientras tanto, podés escribirnos y te contamos sobre su '
                        'experiencia y trabajos anteriores.',
                        style: TextStyle(color: AppColors.textMuted, height: 1.6),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      OutlinedButton.icon(
                        onPressed: () => _contactar(m),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('CONSULTAR POR WHATSAPP'),
                      ),
                    ],
                  ),
                ),
              // ===== EXPERIENCIA (lista tipo currículum) =====
              if (m.experiencia.isNotEmpty) ...[
                if (m.biografia.trim().isNotEmpty)
                  const SizedBox(height: AppSpacing.xxl),
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
                    children: m.experiencia
                        .map((e) => _ExperienciaFila(item: e))
                        .toList(),
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
/// recortado + línea vertical), título y descripción opcional.
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
