import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ana palet — style-guide.png referansı
  static const Color primary = Color(0xFF4ECDC4);     // Teal/Mint
  static const Color secondary = Color(0xFFFFCBA4);    // Sıcak şeftali
  static const Color tertiary = Color(0xFFE6E6FA);     // Açık lavanta
  static const Color neutral = Color(0xFFFFFDD0);      // Krem arka plan

  // Durum renkleri
  static const Color safe = Color(0xFF4CAF50);         // Güvenli — yeşil
  static const Color warning = Color(0xFFFFA726);      // Uyarı — turuncu
  static const Color danger = Color(0xFFEF5350);       // İhlal — kırmızı

  // Metin
  static const Color textPrimary = Color(0xFF2D2D2D);  // Koyu gri
  static const Color textSecondary = Color(0xFF757575); // Orta gri
  static const Color textOnPrimary = Colors.white;

  // Kart
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1A000000);

  // Badge arka planları
  static const Color badgeSafe = Color(0xFFE8F5E9);
  static const Color badgeWarning = Color(0xFFFFF3E0);
  static const Color badgeDanger = Color(0xFFFFEBEE);
  static const Color badgeIdle = Color(0xFFEEEEEE);
}
