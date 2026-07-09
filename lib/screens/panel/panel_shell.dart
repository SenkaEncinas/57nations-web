import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import '../../utils/responsive.dart';
import 'login_screen.dart';
import 'calculadora_screen.dart';
import 'pedidos_screen.dart';
import 'pedidos_pintado_screen.dart';
import 'crear_pedido_screen.dart';
import 'cotizaciones_panel_screen.dart';
import 'portfolio_admin_screen.dart';
import 'mi_curriculum_screen.dart';
import 'dashboard_screen.dart';
import 'catalogo3d_admin_screen.dart';
import 'cotizacion_pdf_screen.dart';

/// Contenedor principal del panel interno. Arma el menú dinámicamente según
/// los permisos de [usuario], para que agregar un socio/servicio nuevo en el
/// futuro sea solo cuestión de datos (Firestore), no de código.
class PanelShell extends StatefulWidget {
  final Usuario usuario;

  const PanelShell({super.key, required this.usuario});

  @override
  State<PanelShell> createState() => _PanelShellState();
}

class _PanelSeccion {
  final String id;
  final String label;
  final IconData icon;
  final Widget Function(Usuario) builder;

  _PanelSeccion({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
  });
}

class _PanelShellState extends State<PanelShell> {
  final _authService = AuthService();
  late String _seccionActiva;

  late final List<_PanelSeccion> _secciones;

  @override
  void initState() {
    super.initState();
    _secciones = _construirSecciones(widget.usuario);
    _seccionActiva = _secciones.isNotEmpty ? _secciones.first.id : '';
  }

  List<_PanelSeccion> _construirSecciones(Usuario usuario) {
    final secciones = <_PanelSeccion>[];

    // Dashboard del negocio: SOLO admin.total, siempre primero.
    if (usuario.permisos.contains('admin.total')) {
      secciones.add(_PanelSeccion(
        id: 'dashboard',
        label: 'Dashboard',
        icon: Icons.insights_outlined,
        builder: (u) => const DashboardScreen(),
      ));
    }

    if (usuario.tienePermiso('pedidos.ver_todos')) {
      secciones.add(_PanelSeccion(
        id: 'pedidos',
        label: 'Pedidos',
        icon: Icons.inventory_2_outlined,
        builder: (u) => PedidosScreen(usuario: u),
      ));
    }

    if (usuario.tienePermiso('pedidos.ver_pintado')) {
      secciones.add(_PanelSeccion(
        id: 'pintado',
        label: 'Pendientes de Pintar',
        icon: Icons.brush_outlined,
        builder: (u) => PedidosPintadoScreen(usuario: u),
      ));
    }

    if (usuario.tienePermiso('pedidos.crear')) {
      secciones.add(_PanelSeccion(
        id: 'crear_pedido',
        label: 'Nuevo Pedido',
        icon: Icons.add_circle_outline,
        builder: (u) => CrearPedidoScreen(usuario: u),
      ));
    }

    if (usuario.tienePermiso('calculadora.usar')) {
      secciones.add(_PanelSeccion(
        id: 'calculadora',
        label: 'Calculadora 3D',
        icon: Icons.calculate_outlined,
        builder: (u) => const Calculadora3DScreen(),
      ));
    }

    // Cotizador en PDF: no depende de Firestore, cada quien cotiza su
    // propio trabajo. Se otorga por permiso individual, no automático.
    if (usuario.tienePermiso('cotizaciones.generar')) {
      secciones.add(_PanelSeccion(
        id: 'cotizacion_pdf',
        label: 'Generar Cotización',
        icon: Icons.picture_as_pdf_outlined,
        builder: (u) => CotizacionPdfScreen(usuario: u),
      ));
    }

    if (usuario.tienePermiso('cotizaciones.ver')) {
      secciones.add(_PanelSeccion(
        id: 'cotizaciones',
        label: 'Cotizaciones Web',
        icon: Icons.mail_outline,
        builder: (u) => CotizacionesPanelScreen(usuario: u),
      ));
    }
    if (usuario.tienePermiso('catalogo3d.administrar')) {
      secciones.add(_PanelSeccion(
        id: 'catalogo3d',
        label: 'Catálogo 3D',
        icon: Icons.view_in_ar_outlined,
        builder: (u) => Catalogo3dAdminScreen(usuario: u),
      ));
    }
    if (usuario.tienePermiso('equipo.editar_propio')) {
      secciones.add(_PanelSeccion(
        id: 'mi_curriculum',
        label: 'Mi Currículum',
        icon: Icons.badge_outlined,
        builder: (u) => MiCurriculumScreen(usuario: u),
      ));
    }
    if (usuario.tienePermiso('portfolio.administrar')) {
      secciones.add(_PanelSeccion(
        id: 'portfolio',
        label: 'Administrar Portfolio',
        icon: Icons.collections_bookmark_outlined,
        builder: (u) => PortfolioAdminScreen(usuario: u),
      ));
    }
    return secciones;
  }

  Future<void> _cerrarSesion() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PanelLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isCompact(context);
    final seccionActual = _secciones.firstWhere(
      (s) => s.id == _seccionActiva,
      orElse: () => _PanelSeccion(
        id: '',
        label: 'Sin acceso',
        icon: Icons.block,
        builder: (u) => const _SinPermisosView(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isCompact
          ? AppBar(
              title: Text(seccionActual.label),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Cerrar sesión',
                  onPressed: _cerrarSesion,
                ),
              ],
            )
          : null,
      drawer: isCompact ? _buildDrawer() : null,
      body: isCompact
          ? seccionActual.builder(widget.usuario)
          : Row(
              children: [
                _buildSidebar(),
                Expanded(child: seccionActual.builder(widget.usuario)),
              ],
            ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/logos/logo_57nations.png',
                  height: 28,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                _UsuarioChip(usuario: widget.usuario),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: _secciones.map((s) => _buildNavItem(s)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: OutlinedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('CERRAR SESIÓN'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logos/logo_57nations.png',
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _UsuarioChip(usuario: widget.usuario),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                children: _secciones.map((s) => _buildNavItem(s)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(_PanelSeccion s) {
    final activo = s.id == _seccionActiva;

    return InkWell(
      onTap: () {
        setState(() => _seccionActiva = s.id);
        if (Responsive.isCompact(context)) {
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
        decoration: BoxDecoration(
          color: activo ? AppColors.violetaPrincipal.withValues(alpha: 0.1) : null,
          border: Border(
            left: BorderSide(
              color: activo ? AppColors.cianTech : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(s.icon, size: 20, color: activo ? AppColors.cianTech : AppColors.textMuted),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                s.label,
                style: TextStyle(
                  color: activo ? AppColors.textLight : AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: activo ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nombre + rol del usuario logueado, con indicador de sesión activa.
class _UsuarioChip extends StatelessWidget {
  final Usuario usuario;

  const _UsuarioChip({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                usuario.nombre,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                usuario.rol.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textDim,
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SinPermisosView extends StatelessWidget {
  const _SinPermisosView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_person_outlined, color: AppColors.textDim, size: 40),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Tu usuario no tiene módulos habilitados.\nContacta a Admin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
