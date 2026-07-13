import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/firestore_errors.dart';
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
      floatingActionButton: WhatsAppFlotante(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            NavBar(),
            _HeroSection(),
            // Franjas de gradiente entre secciones: el cambio de fondo deja
            // de ser un corte seco (punto "ritmo" del balance visual). El
            // Hero ahora es negro plano (TechBackground, no gradiente), así
            // que esta franja arranca y termina en el mismo negro.
            _TransicionSeccion(desde: AppColors.background, hacia: AppColors.background),
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
/// Hero rediseñado (agosto 2026): la tipografía es la protagonista, no el
/// logo — ver CLAUDE.md "Dirección visual definitiva del Hero". Fondo:
/// foto real `assets/images/hero_bg.jpg` (placa/chip ESP32 generada por
/// IA) + degradé oscuro hacia la derecha, donde va el texto (el lado
/// izquierdo/centro de la foto es el más "ocupado" visualmente — chip,
/// circuito, watermark "57" — así que el texto se movió a la derecha para
/// no competir con eso). Si el archivo todavía no existe, cae a
/// `TechBackground` (el fondo procedural) para no romper la pantalla.
/// Headline de 4 líneas en bloque ("OTROS / DISEÑAN. / NOSOTROS /
/// CONSTRUIMOS.") y entrada animada UNA sola vez con `flutter_animate`
/// (nunca en loop — esto es above-the-fold, se anima al cargar, no al
/// hacer scroll).
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  /// Alto aproximado de la Navbar, para que el hero complete la pantalla.
  static const double _altoNavbar = 60;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final altoPantalla = MediaQuery.of(context).size.height;

    final tamanoHeadline = isMobile ? 42.0 : (isTablet ? 64.0 : 92.0);
    final alturaLinea = isMobile ? 1.02 : 0.96;

    return Container(
      width: double.infinity,
      // El hero cubre toda la pantalla al entrar (100vh menos la navbar);
      // en pantallas muy bajas crece con el contenido en vez de cortarlo.
      constraints: BoxConstraints(minHeight: altoPantalla - _altoNavbar),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const TechBackground(),
            ),
          ),
          // Degradé oscuro hacia la derecha: ahí va el texto, y el lado
          // izquierdo de la foto (chip, circuito) queda visible sin tapar.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.background.withValues(alpha: 0.05),
                    AppColors.background.withValues(alpha: isMobile ? 0.75 : 0.82),
                  ],
                  stops: const [0.0, 0.65],
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
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    )
                        .animate()
                        .fade(duration: 400.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
                    SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),
                    // Headline en bloque, cuatro líneas: "otros" en gris tenue
                    // (lo esperable) y "nosotros" en blanco pleno (lo que
                    // ofrece 57 Nations) — el contraste hace el argumento sin
                    // necesidad de más texto.
                    RichText(
                      textAlign: TextAlign.right,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily,
                          fontSize: tamanoHeadline,
                          fontWeight: FontWeight.w800,
                          height: alturaLinea,
                          letterSpacing: -1.5,
                        ),
                        children: const [
                          TextSpan(text: 'MIENTRAS OTROS\n', style: TextStyle(color: AppColors.textDim)),
                          TextSpan(text: 'DISEÑAN\n', style: TextStyle(color: AppColors.textDim)),
                          TextSpan(text: 'NOSOTROS\n', style: TextStyle(color: AppColors.textLight)),
                          TextSpan(text: 'CONSTRUIMOS', style: TextStyle(color: AppColors.textLight)),
                        ],
                      ),
                    )
                        .animate()
                        .fade(duration: 500.ms, delay: 120.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 120.ms, curve: Curves.easeOut),
                    SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxl),
                    SizedBox(
                      width: isMobile ? double.infinity : 560,
                      child: const Text(
                        'Software, hardware y entrenamiento — convertimos la idea que '
                        'tenés en algo que funciona de verdad.',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 16, height: 1.7),
                      ),
                    )
                        .animate()
                        .fade(duration: 500.ms, delay: 260.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 260.ms, curve: Curves.easeOut),
                    SizedBox(height: isMobile ? AppSpacing.xxl : AppSpacing.section),
                    // Un solo estilo primario (violeta sólido, default del
                    // tema) y un solo estilo secundario (outline) en todo
                    // el sitio.
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.md,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                          style: ElevatedButton.styleFrom(
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
                    )
                        .animate()
                        .fade(duration: 500.ms, delay: 400.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 400.ms, curve: Curves.easeOut),
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
/// Lista numerada minimalista (agosto 2026, sin cards — ver CLAUDE.md):
/// cada fila es número + título + descripción de una línea, separada por
/// una regla fina. Reemplaza la grilla de `ServiceCard` (retirado).
class _ServiciosSection extends StatelessWidget {
  const _ServiciosSection();

  // Descripciones recortadas a una línea (≤ 8 palabras), lenguaje simple
  // (ver CLAUDE.md, dirección minimalista + copy accesible).
  static const _servicios = [
    (
      '01',
      'BOTS & SISTEMAS',
      'Un asistente de WhatsApp que responde solo.',
      AppRoutes.botsScreen,
    ),
    (
      '02',
      'APPS FLUTTER',
      'Tu app en iPhone y Android, sin líos.',
      AppRoutes.flutterScreen,
    ),
    (
      '03',
      'ARDUINO & ESP32',
      'Objetos conectados que controlás desde el celular.',
      AppRoutes.arduinoScreen,
    ),
    (
      '04',
      'IMPRESIÓN 3D',
      'La pieza que necesités, impresa a medida.',
      AppRoutes.impresion3dScreen,
    ),
    (
      '05',
      'ENTRENAMIENTO',
      'Entrenamiento personalizado de básquet.',
      AppRoutes.entrenamientoScreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PageSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            overline: 'Servicios',
            titulo: 'Lo que hacemos',
          ),
          const SizedBox(height: AppSpacing.section),
          Column(
            children: _servicios
                .map((s) => _ServicioFila(
                      numero: s.$1,
                      titulo: s.$2,
                      descripcion: s.$3,
                      onTap: () => Navigator.pushNamed(context, s.$4),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ServicioFila extends StatefulWidget {
  final String numero;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  const _ServicioFila({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
  });

  @override
  State<_ServicioFila> createState() => _ServicioFilaState();
}

class _ServicioFilaState extends State<_ServicioFila> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: isMobile ? AppSpacing.lg : AppSpacing.xl),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.violetaPrincipal.withValues(alpha: 0.18),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.numero,
                style: TextStyle(
                  color: _hovered
                      ? AppColors.violetaPrincipal
                      : AppColors.violetaPrincipal.withValues(alpha: 0.4),
                  fontSize: isMobile ? 18 : 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: isMobile ? AppSpacing.lg : AppSpacing.xxl),
              Expanded(
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _tituloServicio(context),
                          const SizedBox(height: AppSpacing.xs),
                          _descripcionServicio(),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(flex: 2, child: _tituloServicio(context)),
                          Expanded(flex: 3, child: _descripcionServicio()),
                        ],
                      ),
              ),
              const SizedBox(width: AppSpacing.lg),
              AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                offset: _hovered ? const Offset(0.15, 0) : Offset.zero,
                child: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: _hovered ? AppColors.violetaPrincipal : AppColors.textDim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloServicio(BuildContext context) => Text(
        widget.titulo,
        style: TextStyle(
          color: _hovered ? AppColors.violetaPrincipal : AppColors.textLight,
          fontWeight: FontWeight.w700,
          fontSize: Responsive.isMobile(context) ? 15 : 18,
          letterSpacing: 0.5,
        ),
      );

  Widget _descripcionServicio() => Text(
        widget.descripcion,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5),
      );
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
        _error = mensajeErrorCarga(e, queCargaba: 'el equipo');
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      // Carrusel tipo "selección de personaje": Senka (admin) arranca
      // seleccionado al centro (detección dinámica, nunca índice fijo) y se
      // rota miembro por miembro con vuelta infinita. Click al centro →
      // perfil público con el currículum.
      contenido = EquipoCarrusel(
        equipo: _equipo,
        onVerPerfil: (m) => Navigator.pushNamed(
          context,
          AppRoutes.perfilEquipo,
          arguments: m.id,
        ),
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
/// Reutiliza `TechBackground` (a media opacidad) como único lenguaje de
/// fondo técnico del sitio, junto con el Hero — ver CLAUDE.md.
class _CotizarBanner extends StatelessWidget {
  const _CotizarBanner();

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.background),
      child: Stack(
        children: [
          const Positioned.fill(child: TechBackground(opacidad: 0.4)),
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
                  // Mismo CTA que el Hero: mismo texto y mismo estilo
                  // primario único del sitio (violeta sólido, default).
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.cotizacion),
                    style: ElevatedButton.styleFrom(
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
