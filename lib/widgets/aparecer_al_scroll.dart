import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Anima la entrada de una sección la PRIMERA vez que aparece en el viewport
/// al hacer scroll: fade-in + slide-up sutil (~350ms, manual de marca: todo
/// sutil). No se repite al volver a scrollear — el flag [_visto] nunca vuelve
/// a false.
///
/// No usar en el Hero ni en nada above-the-fold crítico: eso debe estar
/// visible al instante, sin esperar animación.
class AparecerAlScroll extends StatefulWidget {
  final Widget child;

  /// Clave única de la sección (requerida por VisibilityDetector).
  final String id;

  /// Retraso opcional para escalonar elementos de una misma sección.
  final Duration delay;

  const AparecerAlScroll({
    super.key,
    required this.id,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<AparecerAlScroll> createState() => _AparecerAlScrollState();
}

class _AparecerAlScrollState extends State<AparecerAlScroll> {
  bool _visto = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('aparecer_${widget.id}'),
      onVisibilityChanged: (info) {
        // Dispara una sola vez, cuando al menos ~10% de la sección es visible.
        if (!_visto && info.visibleFraction > 0.1 && mounted) {
          setState(() => _visto = true);
        }
      },
      child: widget.child
          .animate(target: _visto ? 1 : 0)
          .fade(duration: 350.ms, delay: widget.delay, curve: Curves.easeOut)
          .slideY(
            begin: 0.06,
            end: 0,
            duration: 350.ms,
            delay: widget.delay,
            curve: Curves.easeOut,
          ),
    );
  }
}
