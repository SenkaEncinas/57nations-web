import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Lightbox reutilizable: foto en grande con zoom (InteractiveViewer),
/// flechas para navegar entre fotos y botón de cierre.
class GaleriaLightbox extends StatefulWidget {
  final List<String> imagenes;
  final int indiceInicial;

  const GaleriaLightbox({
    super.key,
    required this.imagenes,
    this.indiceInicial = 0,
  });

  @override
  State<GaleriaLightbox> createState() => _GaleriaLightboxState();
}

class _GaleriaLightboxState extends State<GaleriaLightbox> {
  late final PageController _controller;
  late int _indice;

  @override
  void initState() {
    super.initState();
    _indice = widget.indiceInicial;
    _controller = PageController(initialPage: _indice);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ir(int delta) {
    final destino = (_indice + delta).clamp(0, widget.imagenes.length - 1);
    _controller.animateToPage(
      destino,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _indice = i),
              itemCount: widget.imagenes.length,
              itemBuilder: (context, i) => InteractiveViewer(
                maxScale: 4,
                child: Center(
                  child: Image.network(widget.imagenes[i], fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textLight),
              style: IconButton.styleFrom(backgroundColor: AppColors.overlayDark),
              tooltip: 'Cerrar',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (widget.imagenes.length > 1) ...[
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.textLight, size: 28),
                  style: IconButton.styleFrom(backgroundColor: AppColors.overlayDark),
                  onPressed: _indice > 0 ? () => _ir(-1) : null,
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.textLight, size: 28),
                  style: IconButton.styleFrom(backgroundColor: AppColors.overlayDark),
                  onPressed: _indice < widget.imagenes.length - 1 ? () => _ir(1) : null,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: ShapeDecoration(
                    color: AppColors.overlayDark,
                    shape: AppTheme.cutCorner(size: AppTheme.cutSizeSm),
                  ),
                  child: Text(
                    '${_indice + 1} / ${widget.imagenes.length}',
                    style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
