import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Material 3 theme for "Imagem com Ação".
///
/// Digital Playground design language — tactile surfaces, chunky shadows,
/// pill-shaped buttons, generous touch targets, and XL corner radii.
class AppTheme {
  AppTheme._();

  // ── Corner radii (XL system) ──────────────────────────────────────────
  static const double radiusButton = 48;
  static const double radiusCard = 24;
  static const double radiusInput = 16;

  // ── Chunky shadow (blur 24, 6 % onSurface tint) ──────────────────────
  static List<BoxShadow> get chunkyShadow => [
        BoxShadow(
          color: AppColors.onSurface.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ];

  // ── Typography helpers ────────────────────────────────────────────────
  static TextTheme get _textTheme {
    final display = GoogleFonts.plusJakartaSansTextTheme();
    final body = GoogleFonts.beVietnamProTextTheme();

    return TextTheme(
      // Display / Headline — Plus Jakarta Sans
      displayLarge: display.displayLarge!.copyWith(color: AppColors.onSurface),
      displayMedium:
          display.displayMedium!.copyWith(color: AppColors.onSurface),
      displaySmall: display.displaySmall!.copyWith(color: AppColors.onSurface),
      headlineLarge:
          display.headlineLarge!.copyWith(color: AppColors.onSurface),
      headlineMedium:
          display.headlineMedium!.copyWith(color: AppColors.onSurface),
      headlineSmall:
          display.headlineSmall!.copyWith(color: AppColors.onSurface),

      // Title — Plus Jakarta Sans (bridges headline ↔ body)
      titleLarge: display.titleLarge!.copyWith(color: AppColors.onSurface),
      titleMedium: display.titleMedium!.copyWith(color: AppColors.onSurface),
      titleSmall: display.titleSmall!.copyWith(color: AppColors.onSurface),

      // Body / Label — Be Vietnam Pro
      bodyLarge: body.bodyLarge!.copyWith(color: AppColors.onSurface),
      bodyMedium: body.bodyMedium!.copyWith(color: AppColors.onSurface),
      bodySmall: body.bodySmall!.copyWith(color: AppColors.onSurface),
      labelLarge: body.labelLarge!.copyWith(color: AppColors.onSurface),
      labelMedium: body.labelMedium!.copyWith(color: AppColors.onSurface),
      labelSmall: body.labelSmall!.copyWith(color: AppColors.onSurface),
    );
  }

  // ── Light theme ───────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryContainer,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondary: AppColors.onSecondary,
      tertiary: AppColors.tertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      surface: AppColors.surface,
      surfaceDim: AppColors.surfaceDim,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      // surfaceVariant mapped to surfaceContainerHighest per Material 3
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurface,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      onError: Colors.white,
      onErrorContainer: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      scaffoldBackgroundColor: AppColors.surface,

      // ── App bar ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),

      // ── Elevated button (pill, gradient-ready) ────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(64, 56),
          shape: const StadiumBorder(),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Filled button ─────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(64, 56),
          shape: const StadiumBorder(),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Outlined button ───────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          minimumSize: const Size(64, 56),
          shape: const StadiumBorder(),
          side: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.20),
          ),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ── Text button ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          textStyle: _textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Card (surface tonal shift, no border) ────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),

      // ── Input decoration (ghost border) ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.20),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.20),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        labelStyle: _textTheme.bodyMedium?.copyWith(
          color: AppColors.outline,
        ),
        hintStyle: _textTheme.bodyMedium?.copyWith(
          color: AppColors.outline.withValues(alpha: 0.60),
        ),
      ),

      // ── Floating action button ────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primaryContainer,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: _textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── Bottom navigation ─────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Navigation bar (Material 3) ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          _textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusCard)),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.outlineVariant.withValues(alpha: 0.30),
        thickness: 1,
        space: 1,
      ),

      // ── Icon ──────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.onSurface,
        size: 24,
      ),

      // ── Splash / visual feedback ─────────────────────────────────────
      splashColor: AppColors.primary.withValues(alpha: 0.08),
      highlightColor: AppColors.primary.withValues(alpha: 0.04),
    );
  }
}
