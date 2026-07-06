import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Estado de carga consistente para toda pantalla que hace fetch a Firestore.
class EstadoCargando extends StatelessWidget {
  final String mensaje;

  const EstadoCargando({super.key, this.mensaje = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(mensaje, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

/// Estado vacío (la consulta funcionó pero no hay datos todavía).
class EstadoVacio extends StatelessWidget {
  final IconData icon;
  final String mensaje;

  const EstadoVacio({super.key, required this.icon, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textDim, size: 40),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: const TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de error visible (la consulta a Firestore falló). Siempre con
/// acción de reintentar para no dejar a quien usa el panel sin salida.
class EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const EstadoError({
    super.key,
    this.mensaje = 'No pudimos cargar la información. Revisá tu conexión.',
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, color: AppColors.error, size: 40),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: const TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
