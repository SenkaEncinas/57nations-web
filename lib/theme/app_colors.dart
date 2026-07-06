import 'package:flutter/material.dart';

/// Paleta de colores oficial 57 NATIONS
/// Fuente: Manual de Marca 57 Nations (definitivo)
/// Regla clave: la base SIEMPRE es negro + violeta + blanco.
/// Los colores de categoría (verde, azul, rojo/naranja, rosa) son acentos,
/// nunca deben dominar sobre la identidad principal.
class AppColors {
  // ==================== BASE DE MARCA (no tocar sin actualizar manual) ====================
  static const Color negroProfundo = Color(0xFF000000);
  static const Color violetaOscuro = Color(0xFF26215C);
  static const Color violetaPrincipal = Color(0xFF7F77DD);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color cianTech = Color(0xFF00FFFF);
  static const Color grisSecundario = Color(0xFFB8B8C8);

  // ==================== ALIAS SEMÁNTICOS (usar estos en las pantallas) ====================
  static const Color primary = violetaPrincipal;
  static const Color primaryDark = violetaOscuro;
  static const Color background = negroProfundo;
  static const Color accent = cianTech;
  static const Color secondary = grisSecundario;

  // Texto (la marca vive sobre fondo negro/violeta oscuro → texto claro por defecto)
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB8B8C8);
  static const Color textDim = Color(0xFF8A87B0);
  static const Color textDark = Color(0xFF15132B);

  // Fondos de superficie (paneles, tarjetas) sobre la base negra
  static const Color surface = Color(0xFF0D0B1A);
  static const Color surfaceElevated = Color(0xFF161331);
  static const Color border = Color(0xFF2A2650);

  // Colores de estado (uso funcional, no decorativo)
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF2A93B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = cianTech;

  // ==================== COLORES POR CATEGORÍA (del manual, sección 03) ====================
  static const Color categoriaIoT = Color(0xFF90AF28);
  static const Color categoriaSoftware = cianTech;
  static const Color categoriaGaming = Color(0xFFF2751A);
  static const Color categoriaArte = Color(0xFFE85D9C);

  // Colores de servicios del home (mapeados a categorías del manual)
  static const Color botColor = categoriaSoftware;
  static const Color flutterColor = violetaPrincipal;
  static const Color arduinoColor = categoriaIoT;
  static const Color impresion3dColor = categoriaGaming;
  static const Color entrenamientoColor = categoriaArte;

  // Cosecha (sub-marca definida en el manual, sección 07)
  static const Color cosechaVerdeOscuro = Color(0xFF204F10);
  static const Color cosechaLima = Color(0xFF90AF28);
  static const Color cosechaCrema = Color(0xFFEFF2EB);
  static const Color cosechaTomate = Color(0xFFD93B30);

  // Legacy alias (compatibilidad con código existente)
  static const Color lightGray = surface;
  static const Color lightBorder = border;
  static const Color cardBorder = border;
  static const Color hoveredCard = surfaceElevated;

  // Gradientes de marca
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [negroProfundo, violetaOscuro],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [violetaPrincipal, cianTech],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glowVioleta = LinearGradient(
    colors: [Color(0x557F77DD), Color(0x007F77DD)],
    begin: Alignment.center,
    end: Alignment.bottomRight,
  );

  // Overlays y sombras
  static const Color shadowColor = Color(0x66000000);
  static const Color overlayDark = Color(0xCC000000);
  static const Color glowShadow = Color(0x407F77DD);
}
