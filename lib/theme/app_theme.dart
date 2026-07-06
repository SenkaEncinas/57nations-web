import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tema visual 57 NATIONS.
/// Estética: tech futurista, fondo negro/violeta, tipografía geométrica
/// limpia, glow violeta suave, bordes con esquinas recortadas.
/// Ver manual de marca secciones 04 (Tipografía) y 05 (Sistema gráfico).
///
/// Decisión de sistema: TODOS los contenedores interactivos (botones, inputs,
/// cards, chips, diálogos) usan [BeveledRectangleBorder] — esquina recortada
/// en chaflán — en vez de esquinas redondeadas Material default. Es la
/// traducción directa del sistema de marcos rectos del manual. Si una pantalla
/// necesita una forma propia, usar [AppTheme.cutCorner].
class AppTheme {
  /// Chaflán estándar del sistema (esquinas recortadas).
  static const double cutSize = 8;

  /// Chaflán chico para elementos compactos (chips, badges, inputs).
  static const double cutSizeSm = 5;

  /// Forma de esquinas recortadas reutilizable en pantallas.
  static BeveledRectangleBorder cutCorner({double size = cutSize, BorderSide side = BorderSide.none}) {
    return BeveledRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(size)),
      side: side,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violetaPrincipal,
        brightness: Brightness.dark,
        surface: AppColors.surface,
        primary: AppColors.violetaPrincipal,
        secondary: AppColors.cianTech,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: _buildTextTheme(),
      // Los inputs exigen InputBorder (no acepta BeveledRectangleBorder),
      // así que usamos OutlineInputBorder con radio mínimo: esquina
      // prácticamente recta, coherente con el sistema de marcos del manual.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textDim),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.violetaPrincipal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? AppColors.violetaPrincipal.withValues(alpha: 0.35)
                : states.contains(WidgetState.hovered)
                    ? const Color(0xFF938BEA) // violeta un paso más claro al hover
                    : AppColors.violetaPrincipal,
          ),
          foregroundColor: const WidgetStatePropertyAll(AppColors.textLight),
          elevation: const WidgetStatePropertyAll(0),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(cutCorner()),
          // Glow violeta sutil solo cuando el mouse está encima (manual:
          // glow nunca excesivo ni en todo a la vez).
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          overlayColor: WidgetStatePropertyAll(
            AppColors.blanco.withValues(alpha: 0.06),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(AppColors.cianTech),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.hovered)
                  ? AppColors.cianTech
                  : AppColors.cianTech.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(cutCorner()),
          overlayColor: WidgetStatePropertyAll(
            AppColors.cianTech.withValues(alpha: 0.08),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(AppColors.cianTech),
          shape: WidgetStatePropertyAll(cutCorner(size: cutSizeSm)),
          overlayColor: WidgetStatePropertyAll(
            AppColors.cianTech.withValues(alpha: 0.08),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: cutCorner(side: const BorderSide(color: AppColors.border)),
        color: AppColors.surfaceElevated,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: cutCorner(side: const BorderSide(color: AppColors.border)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.textLight),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.violetaPrincipal.withValues(alpha: 0.22),
        labelStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
        side: const BorderSide(color: AppColors.border),
        shape: cutCorner(size: cutSizeSm),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        shape: cutCorner(side: const BorderSide(color: AppColors.border)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.violetaPrincipal,
      ),
      listTileTheme: ListTileThemeData(
        shape: cutCorner(size: cutSizeSm),
        iconColor: AppColors.textMuted,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.surfaceElevated,
        shape: cutCorner(side: const BorderSide(color: AppColors.border)),
        headerBackgroundColor: AppColors.violetaOscuro,
        headerForegroundColor: AppColors.textLight,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceElevated,
        shape: cutCorner(size: cutSizeSm, side: const BorderSide(color: AppColors.border)),
        textStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(), // sin curvas: marcos rectos de marca
      ),
      switchTheme: const SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(AppColors.border),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceElevated),
          shape: WidgetStatePropertyAll(cutCorner(size: cutSizeSm)),
        ),
      ),
    );
  }

  // Alias por compatibilidad con código existente que use AppTheme.lightTheme
  static ThemeData get lightTheme => darkTheme;

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        height: 1.15,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        height: 1.35,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDim,
        letterSpacing: 1.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textLight,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textDim,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        letterSpacing: 0.5,
      ),
    );
  }
}
