import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // NAVBAR
            const NavBar(),

            // HERO SECTION
            _buildHeroSection(isMobile),

            // SECCIÓN SERVICIOS
            _buildServicesSection(isMobile),

            // SECCIÓN PORTFOLIO
            _buildPortfolioSection(isMobile),

            // SECCIÓN EQUIPO
            _buildTeamSection(isMobile),

            // FOOTER
            const Footer(),
          ],
        ),
      ),
    );
  }

Widget _buildHeroSection(bool isMobile) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Stack(
        children: [
          // Decoraciones de circuito en las esquinas (manual, sección 05)
          if (!isMobile) ...[
            const Positioned(
              top: 24,
              left: 24,
              child: TechCornerDecoration(),
            ),
            const Positioned(
              top: 24,
              right: 24,
              child: TechCornerDecoration(espejado: true),
            ),
          ],

          // Glow violeta suave detrás del contenido
          Positioned(
            top: -100,
            left: isMobile ? -80 : 100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.violetaPrincipal.withOpacity(0.25),
                    AppColors.violetaPrincipal.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 60,
              vertical: isMobile ? 80 : 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logos/logo_57nations.png',
                  height: isMobile ? 90 : 140,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: isMobile ? 16 : 24),
                Text(
                  'Software + Hardware + Entrenamiento = Soluciones Completas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                        fontSize: isMobile ? 18 : 24,
                      ),
                ),
                SizedBox(height: isMobile ? 12 : 20),
                SizedBox(
                  width: isMobile ? double.infinity : 600,
                  child: Text(
                    'Transformamos tus ideas en proyectos reales. Especialistas en desarrollo tech integral: desde código hasta electrónica.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                  ),
                ),
                SizedBox(height: isMobile ? 32 : 48),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/contacto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cianTech,
                    foregroundColor: AppColors.negroProfundo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 18,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('COTIZAR PROYECTO'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(bool isMobile) {
    final services = [
      {
        'icon': Icons.smart_toy,
        'title': 'BOTS & SISTEMAS',
        'description': 'Automatización vía WhatsApp, sistemas con base de datos, control inteligente',
        'color': AppColors.botColor,
        'route': '/bots',
      },
      {
        'icon': Icons.phone_android,
        'title': 'APPS FLUTTER',
        'description': 'Desarrollo multiplataforma iOS + Android con interfaces intuitivas',
        'color': AppColors.flutterColor,
        'route': '/flutter',
      },
      {
        'icon': Icons.memory,
        'title': 'ARDUINO & ESP32',
        'description': 'IoT, automatización, control remoto de dispositivos inteligentes',
        'color': AppColors.arduinoColor,
        'route': '/arduino',
      },
      {
        'icon': Icons.print_outlined,
        'title': 'IMPRESIÓN 3D',
        'description': 'Piezas decorativas y funcionales, diseño custom, acabado profesional',
        'color': AppColors.impresion3dColor,
        'route': '/impresion3d',
      },
      {
        'icon': Icons.sports_basketball,
        'title': 'ENTRENAMIENTO',
        'description': 'Coaching profesional de basketball, técnica, táctica y desarrollo',
        'color': AppColors.entrenamientoColor,
        'route': '/entrenamiento',
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      color: AppColors.background,
      child: Column(
        children: [
          Text(
            'Nuestros Servicios',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: isMobile ? 28 : 36,
                ),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 5,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.95,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCard(
                icon: service['icon'] as IconData,
                title: service['title'] as String,
                description: service['description'] as String,
                color: service['color'] as Color,
                onTap: () => Navigator.pushNamed(context, service['route'] as String),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      color: AppColors.surface,
      child: Column(
        children: [
          Text(
            'Portfolio',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: isMobile ? 28 : 36,
                ),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          // TODO: Implementar carrusel de proyectos
          Center(
            child: Text('Galería de proyectos aquí'),
          ),
          SizedBox(height: isMobile ? 32 : 48),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/portfolio'),
            child: const Text('VER TODOS LOS PROYECTOS'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 60 : 100,
      ),
      color: AppColors.background,
      child: Column(
        children: [
          Text(
            'El Equipo 57 Nations',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: isMobile ? 28 : 36,
                ),
          ),
          SizedBox(height: isMobile ? 40 : 60),
          // TODO: Implementar grid de equipo
          Center(
            child: Text('Grid de integrantes del equipo aquí'),
          ),
        ],
      ),
    );
  }
}
