import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Sección de página pública estándar: fondo (negro o surface alternado),
/// padding vertical del sistema y contenido centrado a
/// [AppSpacing.maxContentWidth] para que el sitio no se estire infinito
/// en monitores anchos.
class PageSection extends StatelessWidget {
  final Widget child;

  /// true = fondo surface (levemente violáceo) para alternar con secciones negras.
  final bool alternada;

  /// Sobrescribe el padding vertical estándar (usar valores de AppSpacing).
  final double? verticalPadding;

  const PageSection({
    super.key,
    required this.child,
    this.alternada = false,
    this.verticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: alternada ? AppColors.surface : AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontal(context),
        vertical: verticalPadding ?? AppSpacing.vertical(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
