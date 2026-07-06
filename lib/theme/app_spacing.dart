import 'package:flutter/widgets.dart';
import '../utils/responsive.dart';

/// Escala de espaciado única de todo el sitio (múltiplos de 4).
/// Regla: NUNCA usar valores sueltos tipo 17, 23, 35 en pantallas;
/// siempre referenciar esta escala para que el ritmo vertical sea consistente.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 48;
  static const double sectionLg = 64;
  static const double sectionXl = 96;

  /// Ancho máximo del contenido en pantallas anchas. Las secciones centran
  /// su contenido a este ancho para que el sitio no se "estire" infinito
  /// en monitores grandes.
  static const double maxContentWidth = 1200;

  /// Ancho máximo para formularios y columnas de texto largo.
  static const double maxFormWidth = 720;

  /// Padding horizontal estándar de página según breakpoint.
  static double horizontal(BuildContext context) =>
      Responsive.isMobile(context) ? 20 : (Responsive.isTablet(context) ? 40 : 60);

  /// Padding vertical estándar de una sección de página pública.
  static double vertical(BuildContext context) =>
      Responsive.isMobile(context) ? sectionLg : sectionXl;

  /// Padding interno estándar del área de trabajo del panel.
  static double panel(BuildContext context) =>
      Responsive.isCompact(context) ? lg : xxl;
}
