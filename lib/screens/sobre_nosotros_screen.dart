import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const PageHero(
              titulo: 'SOBRE NOSOTROS',
              subtitulo:
                  'Software + Hardware + Entrenamiento = Soluciones Completas.',
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 60,
                vertical: isMobile ? 50 : 80,
              ),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nuestra Misión', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  const Text(
                    'En 57 Nations transformamos ideas en proyectos reales. Somos un equipo '
                    'de Santa Cruz, Bolivia, especializado en desarrollo tech integral: '
                    'bots y sistemas a medida, apps multiplataforma, electrónica e IoT, '
                    'impresión 3D y entrenamiento deportivo.',
                    style: TextStyle(color: AppColors.textMuted, height: 1.7, fontSize: 15),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 60,
                vertical: isMobile ? 50 : 80,
              ),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nuestros Valores', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: isMobile ? 24 : 32),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: isMobile ? 2.4 : (isTablet ? 1.8 : 1.4),
                    children: const [
                      _ValorCard(
                        icon: Icons.verified_outlined,
                        titulo: 'Calidad',
                        descripcion: 'Cada proyecto se entrega con atención al detalle y control de calidad.',
                      ),
                      _ValorCard(
                        icon: Icons.bolt_outlined,
                        titulo: 'Compromiso',
                        descripcion: 'Acompañamos al cliente desde la idea hasta la entrega final.',
                      ),
                      _ValorCard(
                        icon: Icons.handshake_outlined,
                        titulo: 'Cercanía',
                        descripcion: 'Comunicación directa y trato personalizado en cada etapa.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 60,
                vertical: isMobile ? 50 : 80,
              ),
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('El Equipo', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: isMobile ? 24 : 32),
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 4),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _equipo.length,
                      itemBuilder: (context, index) => _MiembroCard(miembro: _equipo[index]),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.violetaPrincipal, size: 28),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          Text(descripcion, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

class _MiembroCard extends StatelessWidget {
  final MiembroEquipo miembro;

  const _MiembroCard({required this.miembro});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.surface,
            backgroundImage: miembro.fotoUrl != null ? NetworkImage(miembro.fotoUrl!) : null,
            child: miembro.fotoUrl == null
                ? const Icon(Icons.person_outline, color: AppColors.textDim, size: 32)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            miembro.nombre,
            style: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            miembro.rol,
            style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
