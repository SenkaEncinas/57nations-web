import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';
import '../utils/responsive.dart';
import '../widgets/widgets.dart';

class SobreNosotrosScreen extends StatefulWidget {
  const SobreNosotrosScreen({super.key});

  @override
  State<SobreNosotrosScreen> createState() => _SobreNosotrosScreenState();
}

class _SobreNosotrosScreenState extends State<SobreNosotrosScreen> {
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
      setState(() {
        _equipo = equipo;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No pudimos cargar el equipo. Revisá tu conexión.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final columnasValores = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);
    final columnasEquipo = Responsive.valor(context, mobile: 1, tablet: 2, desktop: 3);

    return Scaffold(
      floatingActionButton: const WhatsAppFlotante(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              overline: '57 Nations',
              titulo: 'Sobre Nosotros',
              subtitulo: 'Software + Hardware + Entrenamiento = Soluciones Completas.',
            ),
            PageSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    overline: 'Misión',
                    titulo: 'Nuestra Misión',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: const Text(
                      'En 57 Nations transformamos ideas en proyectos reales. Somos un equipo '
                      'de Santa Cruz, Bolivia, especializado en desarrollo tech integral: '
                      'bots y sistemas a medida, apps multiplataforma, electrónica e IoT, '
                      'impresión 3D y entrenamiento deportivo.',
                      style: TextStyle(color: AppColors.textMuted, height: 1.7, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            PageSection(
              alternada: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    overline: 'Valores',
                    titulo: 'Cómo trabajamos',
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: columnasValores,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: Responsive.valor(
                      context,
                      mobile: 2.2,
                      tablet: 1.7,
                      desktop: 1.6,
                    ),
                    children: const [
                      _ValorCard(
                        icon: Icons.verified_outlined,
                        titulo: 'Calidad',
                        descripcion:
                            'Cada proyecto se entrega con atención al detalle y control de calidad.',
                      ),
                      _ValorCard(
                        icon: Icons.bolt_outlined,
                        titulo: 'Compromiso',
                        descripcion:
                            'Acompañamos al cliente desde la idea hasta la entrega final.',
                      ),
                      _ValorCard(
                        icon: Icons.handshake_outlined,
                        titulo: 'Cercanía',
                        descripcion:
                            'Comunicación directa y trato personalizado en cada etapa.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PageSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    overline: 'Equipo',
                    titulo: 'El Equipo',
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (_cargando)
                    const EstadoCargando(mensaje: 'Cargando equipo...')
                  else if (_error != null)
                    EstadoError(mensaje: _error!, onReintentar: _cargar)
                  else if (_equipo.isEmpty)
                    const EstadoVacio(
                      icon: Icons.groups_outlined,
                      mensaje: 'Estamos preparando las presentaciones del equipo. Ya vuelven.',
                    )
                  else
                    // Mismo orden que el Home: admin al centro (primero en
                    // mobile), y cada card navega al perfil público.
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Mismo ancho acotado que el Home: cards verticales
                        // uniformes (foto retrato 3:4).
                        final anchoCard = ((constraints.maxWidth -
                                    AppSpacing.lg * (columnasEquipo - 1)) /
                                columnasEquipo)
                            .clamp(0.0, 300.0);
                        final equipoOrdenado = ordenarEquipoConAdminAlCentro(
                          _equipo,
                          adminPrimero: columnasEquipo == 1,
                        );
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
                    ),
                ],
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _ValorCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descripcion;

  const _ValorCard({required this.icon, required this.titulo, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return TechCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.violetaPrincipal, size: 28),
          const SizedBox(height: AppSpacing.md),
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            descripcion,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

