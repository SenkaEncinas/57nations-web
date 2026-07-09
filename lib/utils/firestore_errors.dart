import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Traduce un error de carga de Firestore a un mensaje honesto para el
/// usuario, distinguiendo la causa real en vez del genérico "revisá tu
/// conexión" (que hacía pensar que era internet cuando solía ser permisos
/// o un índice faltante).
///
/// En modo debug SIEMPRE loguea el error completo — para failed-precondition
/// el mensaje de Firestore incluye el link exacto para crear el índice en
/// Firebase Console.
String mensajeErrorCarga(Object error, {required String queCargaba}) {
  if (kDebugMode) {
    debugPrint('[FIRESTORE] Error cargando $queCargaba → $error');
  }

  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'No tenemos permiso para leer $queCargaba. '
            'Es un problema de configuración (reglas de Firestore), no de tu conexión.';
      case 'failed-precondition':
        return 'Falta configurar un índice en la base de datos para $queCargaba. '
            'Es un problema de configuración, no de tu conexión.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'No pudimos conectar con el servidor. Revisá tu conexión e intentá de nuevo.';
      case 'unauthenticated':
        return 'Tu sesión expiró. Volvé a iniciar sesión e intentá de nuevo.';
    }
  }
  return 'No pudimos cargar $queCargaba. Intentá de nuevo en un momento.';
}
