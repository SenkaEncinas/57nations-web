import 'package:flutter/widgets.dart';

/// Breakpoints únicos de todo el sitio: mobile (&lt;800), tablet (800-1200)
/// y desktop (&gt;=1200). Centralizado acá para no repetir el mismo número
/// mágico en cada pantalla.
///
/// Regla del proyecto: NUNCA comparar `MediaQuery.of(context).size.width`
/// contra números sueltos en las pantallas; siempre pasar por esta clase.
class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 800 && width < 1200;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;

  /// Breakpoint del panel interno (sidebar visible u oculto). El panel colapsa
  /// antes que la web pública porque el sidebar de 260px come ancho útil.
  static bool isCompact(BuildContext context) => MediaQuery.of(context).size.width < 900;

  /// Devuelve un valor distinto según breakpoint sin repetir ternarios
  /// anidados en cada pantalla. `tablet` cae en `desktop` si no se pasa.
  static T valor<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? desktop;
    return desktop;
  }
}
