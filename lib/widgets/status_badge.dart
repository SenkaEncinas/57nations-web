import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Mapa único de colores por estado de pedido. Antes estaba duplicado en
/// cada pantalla del panel; cualquier pantalla nueva debe usar esto.
Color colorEstadoPedido(String estado) {
  switch (estado) {
    case EstadoPedido.pendiente:
      return AppColors.warning;
    case EstadoPedido.imprimiendo:
      return AppColors.cianTech;
    case EstadoPedido.enPintado:
      return AppColors.categoriaArte;
    case EstadoPedido.listo:
      return AppColors.success;
    case EstadoPedido.entregado:
      return AppColors.textDim;
    default:
      return AppColors.textMuted;
  }
}

/// Badge de estado con esquinas recortadas (nunca pill redondeada, por
/// manual de marca). Sirve para estados de pedido, cotización, o cualquier
/// etiqueta corta con color semántico.
class StatusBadge extends StatelessWidget {
  final String texto;
  final Color color;
  final bool relleno;

  const StatusBadge({
    super.key,
    required this.texto,
    required this.color,
    this.relleno = true,
  });

  /// Constructor de conveniencia para estados de pedido.
  StatusBadge.pedido(String estado, {super.key})
      : texto = estado,
        color = colorEstadoPedido(estado),
        relleno = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: ShapeDecoration(
        color: relleno ? color.withValues(alpha: 0.14) : null,
        shape: AppTheme.cutCorner(
          size: AppTheme.cutSizeSm,
          side: BorderSide(color: color.withValues(alpha: 0.7)),
        ),
      ),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Mini-stepper horizontal del flujo de un pedido
/// (Pendiente → Imprimiendo → [En Pintado] → Listo → Entregado).
/// Muestra de un vistazo en qué etapa está la pieza.
class FlujoPedidoStepper extends StatelessWidget {
  final Pedido pedido;

  const FlujoPedidoStepper({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final flujo = EstadoPedido.flujoPara(pedido.requierePintado);
    final indiceActual = flujo.indexOf(pedido.estado);
    final colorActivo = colorEstadoPedido(pedido.estado);

    return Row(
      children: [
        for (var i = 0; i < flujo.length; i++) ...[
          Tooltip(
            message: flujo[i],
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= indiceActual ? colorActivo : Colors.transparent,
                border: Border.all(
                  color: i <= indiceActual ? colorActivo : AppColors.border,
                  width: 1.2,
                ),
              ),
            ),
          ),
          if (i < flujo.length - 1)
            Expanded(
              child: Container(
                height: 1.2,
                color: i < indiceActual ? colorActivo.withValues(alpha: 0.6) : AppColors.border,
              ),
            ),
        ],
      ],
    );
  }
}
