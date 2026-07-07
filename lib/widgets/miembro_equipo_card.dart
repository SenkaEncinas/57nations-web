import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'page_hero.dart' show CircuitGridPainter;

/// ¿Este miembro es el admin (Senka)? Se detecta por rol == 'admin'
/// (case-insensitive) con fallback al username, porque el rol público
/// visible puede decir "Fundador" u otro texto.
bool esMiembroAdmin(MiembroEquipo m) =>
    m.rol.trim().toLowerCase() == 'admin' || m.username.toLowerCase() == 'senka';

/// Reordena el equipo para que el admin quede en la posición CENTRAL de la
/// lista (índice largo ~/ 2), recalculado según cuántos miembros haya — si
/// mañana se suma un socio, el admin sigue al centro sin tocar código.
/// Con [adminPrimero] (mobile, 1 columna) el admin va arriba de todo: en una
/// lista vertical "el del medio" no se percibe como centro.
List<MiembroEquipo> ordenarEquipoConAdminAlCentro(
  List<MiembroEquipo> equipo, {
  bool adminPrimero = false,
}) {
  final indiceAdmin = equipo.indexWhere(esMiembroAdmin);
  if (indiceAdmin == -1) return equipo;

  final resto = List<MiembroEquipo>.from(equipo)..removeAt(indiceAdmin);
  final admin = equipo[indiceAdmin];
  final destino = adminPrimero ? 0 : equipo.length ~/ 2;
  return resto..insert(destino.clamp(0, resto.length), admin);
}

/// Card pública de miembro del equipo, estilo "selección de personaje"
/// (referencia: carrusel vertical tipo Pump It Up): foto GRANDE en formato
/// retrato 3:4 — todas las cards idénticas en proporción —, nombre y
/// descripción corta debajo, toda la card clickeable hacia el perfil público.
/// Compartida entre Home y Sobre Nosotros.
/// La card del admin ([destacada]) lleva brackets de circuito en las esquinas.
class MiembroEquipoCard extends StatefulWidget {
  final MiembroEquipo miembro;
  final VoidCallback onTap;
  final bool destacada;

  const MiembroEquipoCard({
    super.key,
    required this.miembro,
    required this.onTap,
    this.destacada = false,
  });

  /// Proporción retrato del área de foto (ancho : alto = 3 : 4), igual en
  /// todas las cards para que el carrusel se vea uniforme.
  static const double aspectRatioFoto = 3 / 4;

  @override
  State<MiembroEquipoCard> createState() => _MiembroEquipoCardState();
}

class _MiembroEquipoCardState extends State<MiembroEquipoCard> {
  bool _hovered = false;

  /// Descripción corta bajo el nombre: la especialidad es una línea curada
  /// para presentarse; la biografía es texto libre en primera persona que
  /// truncado a mitad de frase queda mal — solo se usa de fallback.
  String get _descripcionCorta {
    final m = widget.miembro;
    if (m.especialidad.trim().isNotEmpty) return m.especialidad.trim();
    final bio = m.biografia.trim();
    if (bio.isNotEmpty) {
      return bio.length <= 70 ? bio : '${bio.substring(0, 70).trimRight()}…';
    }
    return 'Equipo 57 Nations';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.miembro;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
              clipBehavior: Clip.hardEdge,
              decoration: ShapeDecoration(
                color: AppColors.surfaceElevated,
                shape: AppTheme.cutCorner(
                  side: BorderSide(
                    color: _hovered ? AppColors.violetaPrincipal : AppColors.border,
                    width: _hovered ? 1.4 : 1,
                  ),
                ),
                shadows: _hovered
                    ? [
                        BoxShadow(
                          color: AppColors.violetaPrincipal.withValues(alpha: 0.22),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : const [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FOTO GRANDE en retrato 3:4, con zoom sutil al hover
                  AspectRatio(
                    aspectRatio: MiembroEquipoCard.aspectRatioFoto,
                    child: ClipRect(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        scale: _hovered ? 1.05 : 1.0,
                        child: m.fotoUrl != null
                            ? Image.network(CloudinaryService.optimizar(m.fotoUrl!, ancho: 600), fit: BoxFit.cover)
                            : _PlaceholderFotoMiembro(destacada: widget.destacada),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.nombre,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (m.rol.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            m.rol.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.cianTech,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _descripcionCorta,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            color: _hovered ? AppColors.cianTech : AppColors.textDim,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('VER PERFIL'),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward,
                                size: 13,
                                color: _hovered ? AppColors.cianTech : AppColors.textDim,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Brackets de circuito solo en la card destacada (admin), sin
            // saturar el resto del grid.
            if (widget.destacada) ...[
              const Positioned(top: 6, left: 6, child: _Bracket()),
              Positioned(
                bottom: 6,
                right: 6,
                child: Transform.rotate(angle: 3.1416, child: const _Bracket()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Bracket extends StatelessWidget {
  const _Bracket();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14, 14),
      painter: _BracketPainter(),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violetaPrincipal.withValues(alpha: 0.6)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Placeholder de foto cuando el miembro todavía no subió la suya: fondo con
/// grid de circuito sutil y silueta enmarcada — nunca una imagen rota.
class _PlaceholderFotoMiembro extends StatelessWidget {
  final bool destacada;

  const _PlaceholderFotoMiembro({required this.destacada});

  @override
  Widget build(BuildContext context) {
    final color = destacada ? AppColors.cianTech : AppColors.violetaPrincipal;

    return Container(
      color: AppColors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: CircuitGridPainter(
              color: color.withValues(alpha: 0.06),
              spacing: 28,
            ),
          ),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(
                color: color.withValues(alpha: 0.1),
                shape: AppTheme.cutCorner(
                  size: AppTheme.cutSizeSm,
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                ),
              ),
              child: Icon(Icons.person_outline, color: color, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
