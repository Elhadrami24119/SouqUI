import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class AppTheme {
  // ─── Color Palette ────────────────────────────────────────────────────────
  static const Color primary    = Color(0xFFFF5A1A);
  static const Color primaryDark= Color(0xFFE04400);
  static const Color secondary  = Color(0xFF0F0F1A);
  static const Color accent     = Color(0xFFFFB347);
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface    = Colors.white;
  static const Color priceRed   = Color(0xFFE53935);
  static const Color textDark   = Color(0xFF0F0F1A);
  static const Color textMid    = Color(0xFF4A4A5A);
  static const Color textGrey   = Color(0xFF9A9AAF);
  static const Color success    = Color(0xFF00C853);
  static const Color warning    = Color(0xFFFF9500);
  static const Color divider    = Color(0xFFEEEEF5);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5A1A), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1E1E35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF0F0F1A).withOpacity(0.07),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
  static List<BoxShadow> get primaryShadow => [
        BoxShadow(
          color: primary.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  // ─── Utilities ────────────────────────────────────────────────────────────
  static String formatPrice(double price) {
    final formatted = price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$formatted MRU';
  }

  static Color statusColor(ProductStatus s) => switch (s) {
        ProductStatus.approved => success,
        ProductStatus.pending  => warning,
        ProductStatus.rejected => Colors.red,
        ProductStatus.sold     => const Color(0xFF6B7280),
      };

  static String statusLabel(ProductStatus s) => switch (s) {
        ProductStatus.approved => 'Publiée',
        ProductStatus.pending  => 'En attente',
        ProductStatus.rejected => 'Rejetée',
        ProductStatus.sold     => 'Vendue',
      };

  // ─── Theme ────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        surface: surface,
        background: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: divider, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        labelStyle: GoogleFonts.inter(color: textGrey, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: textGrey, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        selectedColor: primary.withOpacity(0.12),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
