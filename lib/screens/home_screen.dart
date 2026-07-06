import 'package:flutter/material.dart';
import '../models/models.dart';
import '../routes/app_routes.dart';
import '../services/firebase_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            NavBar(),
            _HeroSection(),
            // Franjas de gradiente entre secciones: el cambio de fondo deja
            // de ser un corte seco (punto "ritmo" del balance visual).
            _TransicionSeccion(desde: Color(0x4026215C), hacia: AppColors.background),
            AparecerAlScroll(id: 'servicios', child: _ServiciosSection()),
            _TransicionSeccion(desde: AppColors.background, hacia: AppColors.surface),
            AparecerAlScroll(id: 'portfolio', child: _PortfolioSection()),
            _TransicionSeccion(desde: AppColors.surface, hacia: AppColors.background),
            AparecerAlScroll(id: 'equipo', child: _EquipoSection()),
            AparecerAlScroll(id: 'cierre', child: _CotizarBanner()),
            Footer(),
          ],
        ),
      ),
    );
  }
}

/// Franja de gradiente vertical que suaviza el cambio de fondo entre dos
/// secciones contiguas. Colores siempre de AppColors; alto de la escala.
class _TransicionSeccion extends StatelessWidget {
  final Color desde;
  final Color hacia;

  const _TransicionSeccion({required this.desde, required this.hacia});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSpacing.sectionLg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [desde, hacia],
        ),
      ),
    );
  }
}

// ==================== HERO ====================
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  /// Alto aproximado de la Navbar, para que el hero complete la pantalla.
  static const double _altoNavbar = 60;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final altoPantalla = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      // El hero cubre toda la pantalla al entrar (100vh menos la navbar);
      // en pantallas muy bajas crece con el contenido en vez de cortarlo.
      constraints: BoxConstraints(minHeight: altoPantalla - _altoNavbar),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CircuitGridPainter(
                color: AppColors.violetaPrincipal.withValues(alpha: 0.06),
              ),
            ),
          ),
          if (!isMobile) ...[
            const Positioned(top: 24, left: 24, child: TechCornerDecoration()),
            const Positioned(top: 24, right: 24, child: TechCornerDecoration(espejado: true)),
          ],
          Positioned(
            top: -120,
            right: isMobile ? -100 : 60,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.violetaPrincipal.withValues(alpha: 0.22),
                    AppColors.violetaPrincipal.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal(context),
              vertical: AppSpacing.sectionLg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 1.2,
                          color: AppColors.cianTech.withValues(alpha: 0.7),
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.cianTech,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Text(
                          'SANTA CRUZ · BOLIVIA',
                          style: TextStyle(
                            color: AppColors.cianTech,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),
                    // Logo protagonista, como en la versión inicial del Home
                    Image.asset(
                      'assets/logos/logo_57nations.png',
                      height: isMobile ? 110 : 170,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),
                    Text(
                      'Software + Hardware + Entrenamiento',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: isMobile ? 20 : 30,
                            color: AppColors.textLight,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: isMobile ? double.infinity : 560,
                      child: Text(
                        'Transformamos tus ideas en proyectos reales. Bots, apps, '
                        'electrónica e impresión 3D — de la idea al producto, todo '
                        'bajo un mismo techo.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                              height: 1.7,
                            ),
                      ),
                    ),
                    SizedBox(height: isMobile ? AppSpacing.xxl : AppSpacing.section),
                    Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.md,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cianTech,
                            foregroundColor: AppColors.negroProfundo,
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                          ),
                          child: const Text('COTIZAR PROYECTO'),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.portfolio),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                          ),
                          child: const Text('VER PORTFOLIO'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SERVICIOS ====================
class _ServiciosSection extends StatelessWidget {
  const _ServiciosSection();

  static final _servicios = [
    (
      Icons.smart_toy_outlined,
      'BOTS & SISTEMAS',
      'Automatización vía WhatsApp, sistemas con base de datos, control inteligente',
      AppColors.botColor,
      AppRoutes.botsScreen,
    ),
    (
      Icons.phone_android_outlined,
      'APPS FLUTTER',
      'Desarrollo multiplataforma iOS + Android con interfaces intuitivas',
      AppColors.flutterColor,
      AppRoutes.flutterScreen,
    ),
    (
      Icons.memory_outlined,
      'ARDUINO & ESP32',
      'IoT, automatización, control remoto de dispositivos inteligentes',
      AppColors.arduinoColor,
      AppRoutes.arduinoScreen,
    ),
    (
      Icons.view_in_ar_outlined,
      'IMPRESIÓN 3D',
      'Piezas decorativas y funcionales, diseño custom, acabado profesional',
      AppColors.impresion3dColor,
      AppRoutes.impresion3dScreen,
    ),
    (
      Icons.sports_basketball_outlined,
      'ENTRENAMIENTO',
      'Coaching profesional de basketball, técnica, táctica y desarrollo',
      AppColors.entrenamientoColor,
      AppRoutes.entrenamientoScreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 5 servicios: en desktop, 5 en fila quedaban de ~224px a 1200px (muy
    // apretados). Wrap centrado con ancho fijo → desktop 3+2 centrado,
    // tablet 2+2+1 centrado, mobile 1 columna.
    final columnas = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);
    final isMobile = Responsive.isMobile(context);

    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Servicios',
            titulo: 'Lo que hacemos',
            subtitulo:
                'Cinco áreas, un mismo estándar: entender el problema, proponer la '
                'solución justa y entregarla funcionando.',
          ),
          const SizedBox(height: AppSpacing.section),
          LayoutBuilder(
            builder: (context, constraints) {
              final anchoCard =
                  (constraints.maxWidth - AppSpacing.lg * (columnas - 1)) / columnas;
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: _servicios
                    .map((s) => SizedBox(
                          width: anchoCard,
                          height: isMobile ? null : 248,
                          child: ServiceCard(
                            icon: s.$1,
                            title: s.$2,
                            description: s.$3,
                            color: s.$4,
                            onTap: () => Navigator.pushNamed(context, s.$5),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================== PORTFOLIO (CTA) ====================
class _PortfolioSection extends StatefulWidget {
  const _PortfolioSection();

  @override
  State<_PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<_PortfolioSection> {
  static const int _maxProyectos = 3;

  final _firebaseService = FirebaseService();
  List<Proyecto> _proyectos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      // obtenerProyectos() ya viene ordenado por fechaCreacion descendente.
      final proyectos = await _firebaseService.obtenerProyectos();
      if (!mounted) return;
      setState(() {
        _proyectos = proyectos.take(_maxProyectos).toList();
        _cargando = false;
      });
    } catch (e) {
      // En el Home no mostramos un bloque de error para un preview:
      // caemos al mismo estado elegante que "sin proyectos".
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnas = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);

    Widget contenido;
    if (_cargando) {
      contenido = const EstadoCargando(mensaje: 'Cargando proyectos...');
    } else if (_proyectos.isEmpty) {
      contenido = _PortfolioVacio(
        onVerPortfolio: () => Navigator.pushNamed(context, AppRoutes.portfolio),
      );
    } else {
      contenido = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columnas,
              crossAxisSpacing: AppSpacing.xl,
              mainAxisSpacing: AppSpacing.xl,
              childAspectRatio: Responsive.isMobile(context) ? 1.2 : 0.9,
            ),
            itemCount: _proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = _proyectos[index];
              return ProyectoCard(
                proyecto: proyecto,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.proyectoDetalle,
                  arguments: proyecto.id,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.portfolio),
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('VER TODOS LOS PROYECTOS'),
          ),
        ],
      );
    }

    return PageSection(
      alternada: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Portfolio',
            titulo: 'Proyectos reales, clientes reales',
            subtitulo:
                'Cada proyecto del portfolio salió a producción: sistemas en uso, '
                'apps publicadas y piezas entregadas.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          contenido,
        ],
      ),
    );
  }
}

/// Estado vacío elegante del preview de portfolio: invita a ver el portfolio
/// completo en vez de dejar la sección muerta.
class _PortfolioVacio extends StatelessWidget {
  final VoidCallback onVerPortfolio;

  const _PortfolioVacio({required this.onVerPortfolio});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return TechCard(
      showCornerBrackets: true,
      padding: EdgeInsets.all(isMobile ? AppSpacing.xl : AppSpacing.section),
      onTap: onVerPortfolio,
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: isMobile ? 0 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estamos cargando los proyectos al portfolio',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Muy pronto vas a poder ver el trabajo terminado, con fotos y '
                  'detalle de cada entrega.',
                  style: TextStyle(color: AppColors.textMuted, height: 1.6),
                ),
              ],
            ),
          ),
          SizedBox(
            width: isMobile ? 0 : AppSpacing.xxl,
            height: isMobile ? AppSpacing.xl : 0,
          ),
          OutlinedButton.icon(
            onPressed: onVerPortfolio,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('VER PORTFOLIO COMPLETO'),
          ),
        ],
      ),
    );
  }
}

// ==================== EQUIPO (datos reales de la colección `equipo`) ====================
class _EquipoSection extends StatefulWidget {
  const _EquipoSection();

  @override
  State<_EquipoSection> createState() => _EquipoSectionState();
}

class _EquipoSectionState extends State<_EquipoSection> {
  final _firebaseService = FirebaseService();
  List<MiembroEquipo> _equipo = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final equipo = await _firebaseService.obtenerEquipo();
      if (!mounted) return;
      setState(() {
        _equipo = equipo;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No pudimos cargar el equipo.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnas = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);

    Widget contenido;
    if (_cargando) {
      contenido = const EstadoCargando(mensaje: 'Cargando equipo...');
    } else if (_error != null) {
      contenido = EstadoError(mensaje: _error!, onReintentar: _cargar);
    } else if (_equipo.isEmpty) {
      contenido = const EstadoVacio(
        icon: Icons.groups_outlined,
        mensaje: 'Estamos preparando las presentaciones del equipo. Ya vuelven.',
      );
    } else {
      // Orden dinámico: Senka (admin) siempre al centro de la fila,
      // recalculado según cuántos miembros haya. En mobile (1 columna)
      // va primero, destacado arriba.
      final equipoOrdenado = ordenarEquipoConAdminAlCentro(
        _equipo,
        adminPrimero: columnas == 1,
      );
      contenido = LayoutBuilder(
        builder: (context, constraints) {
          // Ancho acotado a 300px: con la foto retrato 3:4, la card queda en
          // formato vertical tipo carrusel de selección, todas iguales.
          final anchoCard =
              ((constraints.maxWidth - AppSpacing.lg * (columnas - 1)) / columnas)
                  .clamp(0.0, 300.0);
          return Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: equipoOrdenado
                .map((m) => SizedBox(
                      width: anchoCard,
                      child: MiembroEquipoCard(
                        miembro: m,
                        destacada: esMiembroAdmin(m),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.perfilEquipo,
                          arguments: m.id,
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      );
    }

    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Equipo',
            titulo: 'El equipo 57 Nations',
            subtitulo:
                'Desarrollo, diseño 3D y acabado artístico: conocé quién está '
                'detrás de cada entrega.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          contenido,
          const SizedBox(height: AppSpacing.xxl),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.sobreNosotros),
            icon: const Icon(Icons.groups_outlined, size: 18),
            label: const Text('MÁS SOBRE NOSOTROS'),
          ),
        ],
      ),
    );
  }
}

// ==================== BANNER FINAL: COTIZAR ====================
class _CotizarBanner extends StatelessWidget {
  const _CotizarBanner();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CircuitGridPainter(
                color: AppColors.cianTech.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Líneas de circuito en las esquinas, como el Hero: abre y cierra
          // la página con el mismo lenguaje gráfico.
          if (!isMobile) ...[
            const Positioned(top: 24, left: 24, child: TechCornerDecoration()),
            const Positioned(top: 24, right: 24, child: TechCornerDecoration(espejado: true)),
          ],
          // Glow violeta radial centrado detrás del contenido
          Positioned.fill(
            child: Center(
              child: Container(
                width: 480,
                height: 320,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violetaPrincipal.withValues(alpha: 0.18),
                      AppColors.violetaPrincipal.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontal(context),
              vertical: isMobile ? AppSpacing.sectionLg : AppSpacing.sectionXl,
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    '¿Tenés un proyecto en mente?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontSize: isMobile ? 26 : 34,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Contanos qué necesitás y te respondemos por WhatsApp. Sin costo, sin compromiso.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Mismo CTA que el Hero (mismo texto y estilo, cierre coherente)
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cianTech,
                      foregroundColor: AppColors.negroProfundo,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    ),
                    child: const Text('COTIZAR PROYECTO'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
