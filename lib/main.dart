import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // URLs limpias (sin "#"): nations-2b049.web.app/catalogo-3d en vez de
  // nations-2b049.web.app/#/catalogo-3d. Necesario para que los links que
  // se comparten afuera (ej. el chip NFC de los llaveros, WhatsApp, redes)
  // funcionen tal cual se escriben. Firebase Hosting ya tiene el rewrite
  // "**" -> "/index.html" (firebase.json) que esto requiere para
  // funcionar en cualquier ruta, no solo en la home.
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App57Nations());
}

class App57Nations extends StatelessWidget {
  const App57Nations({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '57 Nations - Soluciones Tech Integrales',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
