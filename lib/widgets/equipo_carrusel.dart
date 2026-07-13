import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'miembro_equipo_card.dart';

/// Carrusel de equipo estilo "selección de personaje" (referencia: song
/// select de Pump It Up): la card seleccionada va al CENTRO en grande, los
/// vecinos se ven más chicos y atenuados a los costados, y se rota miembro
/// por miembro con las flechas (o clickeando un vecino). La rotación es
/// infinita (da la vuelta). Click en la card central → perfil público.
///
/// El seleccionado inicial es SIEMPRE el admin (Senka), detectado con
/// [esMiembroAdmin] sobre la lista real — nunca un índice hardcodeado: si
/// mañana se suma un socio, Senka sigue arrancando al centro.
class EquipoCarrusel extends StatefulWidget {
  final List<MiembroEquipo> equipo;
  final void Function(MiembroEquipo) onVerPerfil;

  const EquipoCarrusel({
    super.key,
    required this.equipo,
    required this.onVerPerfil,
  });

  @override
  State<EquipoCarrusel> createState() => _EquipoCarruselState();
}

class _EquipoCarruselState extends State<EquipoCarrusel> {
  PageController? _controller;
  double? _fraccionActual;
  late int _paginaActual;

  /// Con más de una card se simula rotación infinita usando un itemCount
  /// enorme y el índice módulo largo de la lista.
  bool get _infinito => widget.equipo.length > 1;

  int get _indiceAdminInicial {
    final i = widget.equipo.indexWhere(esMiembroAdmin);
    return i == -1 ? 0 : i;
  }

  double _fraccionViewport(BuildContext context) =>
      Responsive.valor(context, mobile: 0.82, tablet: 0.5, desktop: 0.34);

  @override
  void initState() {
    super.initState();
    // Arranca centrado en el admin, en el "medio" del rango infinito para
    // poder rotar hacia ambos lados desde el inicio.
    _paginaActual = _infinito
        ? widget.equipo.length * 500 + _indiceAdminInicial
        : 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // viewportFraction es fijo por controller: si cambia el breakpoint
    // (resize de ventana), se recrea el controller manteniendo la página.
    final fraccion = _fraccionViewport(context);
    if (_fraccionActual != fraccion) {
      final anterior = _controller;
      _fraccionActual = fraccion;
      _controller = PageController(
        initialPage: _paginaActual,
        viewportFraction: fraccion,
      );
      if (anterior != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => anterior.dispose());
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  MiembroEquipo _miembroEn(int pagina) =>
      widget.equipo[pagina % widget.equipo.length];

  void _irA(int pagina) {
    _controller?.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final equipo = widget.equipo;
    if (equipo.isEmpty) return const SizedBox.shrink();

    // Una sola persona: card centrada sin flechas ni rotación.
    if (equipo.length == 1) {
      return Center(
        child: SizedBox(
          width: 320,
          child: MiembroEquipoCard(
            miembro: equipo.first,
            destacada: esMiembroAdmin(equipo.first),
            mostrarDescripcion: false,
            onTap: () => widget.onVerPerfil(equipo.first),
          ),
        ),
      );
    }

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Alto del carrusel FIJO por breakpoint (antes se derivaba del ancho
        // real de pantalla vía `constraints.maxWidth * fraccion`, lo que en
        // desktop/mobile anchos producía cards de hasta 320px y una sección
        // de ~550-600px de alto — no entraba bien en la pantalla, ni en
        // laptop ni en celular). Ahora se fija un alto objetivo y el ancho
        // de la card se deriva de ahí (al revés), así la sección nunca crece
        // más de la cuenta sin importar el ancho de la ventana.
        final alturaObjetivo = isMobile ? 420.0 : (isTablet ? 460.0 : 500.0);
        // Espacio del bloque de texto bajo la foto: en el carrusel la card
        // NO muestra la descripción (mostrarDescripcion: false, solo nombre
        // + rol) y nombre/rol están limitados a 1 línea (maxLines + ellipsis
        // en MiembroEquipoCard), así el alto del texto es predecible y no
        // varía según qué tan largo sea el rol de cada miembro — antes
        // variaba (ej. "FUNDADOR DE 57 NATIONS" se envolvía a 2 líneas) y
        // eso hacía que el contenido real se pasara del alto fijo
        // (overflow "BOTTOM OVERFLOWED BY N PIXELS").
        const alturaTexto = 110.0;
        final anchoCard =
            ((alturaObjetivo - alturaTexto) * MiembroEquipoCard.aspectRatioFoto)
                .clamp(180.0, 340.0);
        final altoCarrusel = anchoCard / MiembroEquipoCard.aspectRatioFoto + alturaTexto;

        return Column(
          children: [
            SizedBox(
              height: altoCarrusel,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    // didChangeDependencies corre antes del primer build,
                    // así que acá el controller ya existe siempre.
                    controller: _controller!,
                    onPageChanged: (p) => setState(() => _paginaActual = p),
                    itemCount: _infinito ? equipo.length * 1000 : equipo.length,
                    itemBuilder: (context, pagina) {
                      final miembro = _miembroEn(pagina);
                      final seleccionada = pagina == _paginaActual;

                      return AnimatedScale(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        scale: seleccionada ? 1.0 : 0.86,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: seleccionada ? 1.0 : 0.45,
                          child: Center(
                            child: SizedBox(
                              width: anchoCard,
                              child: MiembroEquipoCard(
                                miembro: miembro,
                                destacada: seleccionada && esMiembroAdmin(miembro),
                                mostrarDescripcion: false,
                                // Card central → perfil; vecina → rotar hasta ella.
                                onTap: seleccionada
                                    ? () => widget.onVerPerfil(miembro)
                                    : () => _irA(pagina),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Flechas de rotación
                  Positioned(
                    left: 0,
                    child: _FlechaCarrusel(
                      icon: Icons.chevron_left,
                      compacta: isMobile,
                      onTap: () => _irA(_paginaActual - 1),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: _FlechaCarrusel(
                      icon: Icons.chevron_right,
                      compacta: isMobile,
                      onTap: () => _irA(_paginaActual + 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Indicador de posición (cuadraditos recortados, no puntos pill)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < equipo.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == _paginaActual % equipo.length ? 20 : 8,
                      height: 4,
                      decoration: ShapeDecoration(
                        color: i == _paginaActual % equipo.length
                            ? AppColors.cianTech
                            : AppColors.border,
                        shape: AppTheme.cutCorner(size: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _FlechaCarrusel extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool compacta;

  const _FlechaCarrusel({
    required this.icon,
    required this.onTap,
    required this.compacta,
  });

  @override
  State<_FlechaCarrusel> createState() => _FlechaCarruselState();
}

class _FlechaCarruselState extends State<_FlechaCarrusel> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final lado = widget.compacta ? 36.0 : 44.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: lado,
          height: lado,
          decoration: ShapeDecoration(
            color: AppColors.surfaceElevated
                .withValues(alpha: _hovered ? 1 : 0.85),
            shape: AppTheme.cutCorner(
              size: AppTheme.cutSizeSm,
              side: BorderSide(
                color: _hovered ? AppColors.cianTech : AppColors.border,
              ),
            ),
            shadows: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.cianTech.withValues(alpha: 0.14),
                      blurRadius: 12,
                    ),
                  ]
                : const [],
          ),
          child: Icon(
            widget.icon,
            size: 22,
            color: _hovered ? AppColors.cianTech : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
