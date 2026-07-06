import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/servicios/bots_screen.dart';
import '../screens/servicios/flutter_screen.dart';
import '../screens/servicios/arduino_screen.dart';
import '../screens/servicios/impresion3d_screen.dart';
import '../screens/servicios/entrenamiento_screen.dart';
import '../screens/portfolio/portfolio_screen.dart';
import '../screens/portfolio/proyecto_detalle_screen.dart';
import '../screens/catalogo/catalogo_3d_screen.dart';
import '../screens/cotizacion/cotizacion_screen.dart';
import '../screens/contacto_screen.dart';
import '../screens/sobre_nosotros_screen.dart';
import '../screens/panel/login_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String servicios = '/servicios';
  static const String botsScreen = '/bots';
  static const String flutterScreen = '/flutter';
  static const String arduinoScreen = '/arduino';
  static const String impresion3dScreen = '/impresion3d';
  static const String entrenamientoScreen = '/entrenamiento';
  static const String portfolio = '/portfolio';
  static const String proyectoDetalle = '/proyecto-detalle';
  static const String catalogo3d = '/catalogo-3d';
  static const String cotizacion = '/cotizacion';
  static const String contacto = '/contacto';
  static const String sobreNosotros = '/sobre-nosotros';
  static const String panelLogin = '/panel';

  static final routes = <String, WidgetBuilder>{
    home: (context) => const HomeScreen(),
    botsScreen: (context) => const BotsScreen(),
    flutterScreen: (context) => const FlutterScreen(),
    arduinoScreen: (context) => const ArduinoScreen(),
    impresion3dScreen: (context) => const Impresion3dScreen(),
    entrenamientoScreen: (context) => const EntrenamientoScreen(),
    portfolio: (context) => const PortfolioScreen(),
    catalogo3d: (context) => const Catalogo3dScreen(),
    cotizacion: (context) => const CotizacionScreen(),
    contacto: (context) => const ContactoScreen(),
    sobreNosotros: (context) => const SobreNosotrosScreen(),
    panelLogin: (context) => const PanelLoginScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case proyectoDetalle:
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (context) => ProyectoDetalleScreen(proyectoId: args ?? ''),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
    }
  }
}
