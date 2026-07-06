import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'tech_card.dart';

/// Card pública de un miembro del equipo: foto, nombre, rol, especialidad,
/// biografía truncada con "Ver más" expandible y links a redes.
/// Se usa en el Home (sección Equipo) y en Sobre Nosotros — una sola card
/// para no tener dos versiones desincronizadas.
class MiembroEquipoCard extends StatefulWidget {
  final MiembroEquipo miembro;

  const MiembroEquipoCard({super.key, required this.miembro});

  @override
  State<MiembroEquipoCard> createState() => _MiembroEquipoCardState();
}

class _MiembroEquipoCardState extends State<MiembroEquipoCard> {
  bool _bioExpandida = false;

  /// A partir de este largo la bio se trunca y aparece "Ver más".
  static const int _limiteBio = 140;

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
    final m = widget.miembro;
    final bioLarga = m.biografia.length > _limiteBio;
    final bioVisible = _bioExpandida || !bioLarga
        ? m.biografia
        : '${m.biografia.substring(0, _limiteBio).trimRight()}…';

    return TechCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.violetaPrincipal.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.surface,
                  backgroundImage: m.fotoUrl != null ? NetworkImage(m.fotoUrl!) : null,
                  child: m.fotoUrl == null
                      ? const Icon(Icons.person_outline, color: AppColors.textDim, size: 28)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.nombre,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
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
                    if (m.especialidad.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        m.especialidad,
                        style: const TextStyle(color: AppColors.textDim, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (m.biografia.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              bioVisible,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.6),
            ),
            if (bioLarga)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => setState(() => _bioExpandida = !_bioExpandida),
                    child: Text(
                      _bioExpandida ? 'VER MENOS' : 'VER MÁS',
                      style: const TextStyle(
                        color: AppColors.cianTech,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          if (m.instagramUrl != null || m.linkedinUrl != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                if (m.instagramUrl != null)
                  _RedSocialBoton(
                    icon: Icons.camera_alt_outlined,
                    tooltip: 'Instagram',
                    onTap: () => _abrirUrl(m.instagramUrl!),
                  ),
                if (m.linkedinUrl != null)
                  _RedSocialBoton(
                    icon: Icons.work_outline,
                    tooltip: 'LinkedIn',
                    onTap: () => _abrirUrl(m.linkedinUrl!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RedSocialBoton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RedSocialBoton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: IconButton(
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        color: AppColors.textMuted,
        hoverColor: AppColors.cianTech.withValues(alpha: 0.1),
        onPressed: onTap,
      ),
    );
  }
}
