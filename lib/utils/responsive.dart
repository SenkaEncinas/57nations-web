import 'package:flutter/widgets.dart';

/// Breakpoints únicos de todo el sitio: mobile (&lt;800), tablet (800-1200)
/// y desktop (&gt;=1200). Centralizado acá para no repetir el mismo número
/// mágico en cada pantalla.
class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 800;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 800 && width < 1200;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1200;
}
