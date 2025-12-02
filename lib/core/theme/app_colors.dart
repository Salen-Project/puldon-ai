import 'package:flutter/material.dart';

/// Puldon Color Palette
/// Premium futuristic theme with midnight blue, emerald green, and neon cyan
class AppColors {
  AppColors._();

  // Primary Colors - Deep Midnight Blue
  static const Color primaryDark = Color(0xFF0A0E27);
  static const Color primaryMid = Color(0xFF131A3A);
  static const Color primaryLight = Color(0xFF1E2749);

  // Accent Colors - Neon Cyan
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentCyanLight = Color(0xFF64F4FF);
  static const Color accentCyanDark = Color(0xFF00B8D4);

  // Secondary - Emerald Green
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);

  // Additional Accent Colors
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color orange = Color(0xFFF59E0B);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4C6);
  static const Color textTertiary = Color(0xFF6B7280);

  // Glass & Overlay
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassMedium = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x0DFFFFFF);
  static const Color overlay = Color(0xCC0A0E27);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryMid, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, emerald],
  );

  static const LinearGradient glowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentCyanLight, accentCyan, accentCyanDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1A00F0FF), Color(0x1A10B981)],
  );

  // Shadows with Glow Effect
  static List<BoxShadow> glowingShadow({
    Color color = accentCyan,
    double blur = 20,
    double spread = 0,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: blur,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.2),
        blurRadius: blur * 2,
        spreadRadius: spread,
      ),
    ];
  }

  static List<BoxShadow> softShadow = [
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];
}
