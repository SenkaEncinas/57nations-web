import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/models.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'calculadora_screen.dart';
import 'pedidos_screen.dart';
import 'pedidos_pintado_screen.dart';
import 'crear_pedido_screen.dart';
import 'cotizaciones_panel_screen.dart';
import 'portfolio_admin_screen.dart';
/// Contenedor principal del panel interno. Arma el menú dinámicamente según
/// los permisos de [usuario], para que agregar un socio/servicio nuevo en el
/// futuro sea solo cuestión de datos (Firestore), no de código.
class PanelShell extends StatefulWidget {
  final Usuario usuario;

  const PanelShell({Key? key, required this.usuario}) : super(key: key);

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

    if (usuario.tienePermiso('cotizaciones.ver')) {
      secciones.add(_PanelSeccion(
        id: 'cotizaciones',
        label: 'Cotizaciones Web',
        icon: Icons.mail_outline,
        builder: (u) => const CotizacionesPanelScreen(),
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
    final isMobile = MediaQuery.of(context).size.width < 900;
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
      appBar: isMobile
          ? AppBar(
              title: Text(seccionActual.label),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _cerrarSesion,
                ),
              ],
            )
          : null,
      drawer: isMobile ? _buildDrawer() : null,
      body: isMobile
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
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '57 NATIONS',
                  style: TextStyle(
                    color: AppColors.violetaPrincipal,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.usuario.nombre,
                  style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                ),
                Text(
                  widget.usuario.rol.toUpperCase(),
                  style: const TextStyle(color: AppColors.textDim, fontSize: 11, letterSpacing: 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: _secciones.map((s) => _buildNavItem(s)).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _cerrarSesion,
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.usuario.nombre,
                style: const TextStyle(color: AppColors.textLight, fontSize: 16),
              ),
            ),
            ..._secciones.map((s) => _buildNavItem(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(_PanelSeccion s) {
    final activo = s.id == _seccionActiva;
    return ListTile(
      leading: Icon(s.icon, color: activo ? AppColors.cianTech : AppColors.textMuted),
      title: Text(
        s.label,
        style: TextStyle(
          color: activo ? AppColors.textLight : AppColors.textMuted,
          fontWeight: activo ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      selected: activo,
      selectedTileColor: AppColors.violetaPrincipal.withOpacity(0.12),
      onTap: () {
        setState(() => _seccionActiva = s.id);
        if (MediaQuery.of(context).size.width < 900) {
          Navigator.pop(context);
        }
      },
    );
  }
}

class _SinPermisosView extends StatelessWidget {
  const _SinPermisosView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Tu usuario no tiene módulos habilitados.\nContacta a Admin.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
