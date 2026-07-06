import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';

/// Encabezado de sección estándar: overline técnica ("// SERVICIOS" con línea
/// de circuito), título grande y subtítulo opcional. Da la misma jerarquía
/// tipográfica a todas las secciones del sitio y del panel.
class SectionHeader extends StatelessWidget {
  final String overline;
  final String titulo;
  final String? subtitulo;
  final Color? accentColor;
  final bool centrado;

  /// Escala compacta para usar dentro del panel interno.
  final bool compacto;

  const SectionHeader({
    super.key,
    required this.overline,
    required this.titulo,
    this.subtitulo,
    this.accentColor,
    this.centrado = false,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final acento = accentColor ?? AppColors.violetaPrincipal;
    final isMobile = Responsive.isMobile(context);
    final cross = centrado ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    final tituloStyle = compacto
        ? Theme.of(context).textTheme.headlineMedium
        : Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: isMobile ? 28 : 36);

    return Column(
      crossAxisAlignment: cross,
      children: [
        Row(
          mainAxisSize: centrado ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Container(width: 20, height: 1.2, color: acento.withValues(alpha: 0.6)),
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(color: acento, shape: BoxShape.circle),
            ),
            Text(
              overline.toUpperCase(),
              style: TextStyle(
                color: acento,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(titulo, style: tituloStyle, textAlign: centrado ? TextAlign.center : TextAlign.start),
        if (subtitulo != null) ...[
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              subtitulo!,
              textAlign: centrado ? TextAlign.center : TextAlign.start,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
