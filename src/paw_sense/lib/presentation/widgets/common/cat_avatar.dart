import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CatAvatar extends StatelessWidget {
  final String name;
  final String? imagePath;
  final double radius;
  final Color? backgroundColor;

  const CatAvatar({
    super.key,
    required this.name,
    this.imagePath,
    this.radius = 24,
    this.backgroundColor,
  });

  // Her kediye özel renk ve emoji
  static const _catProfiles = {
    'Luna': {'emoji': '\u{1F431}', 'color': 0xFFFFCDD2},    // Kedi yüzü, pembe
    'Oliver': {'emoji': '\u{1F63A}', 'color': 0xFFFFE0B2},  // Gülen kedi, turuncu
    'Mochi': {'emoji': '\u{1F638}', 'color': 0xFFC8E6C9},   // Sırıtan kedi, yeşil
  };

  @override
  Widget build(BuildContext context) {
    final profile = _catProfiles[name];
    final bgColor = backgroundColor ??
        (profile != null ? Color(profile['color'] as int) : AppColors.tertiary);
    final emoji = profile?['emoji'] as String? ?? '\u{1F431}';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imagePath != null && imagePath!.isNotEmpty
          ? ClipOval(
              child: Image.asset(
                imagePath!,
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
              ),
            )
          : Center(
              child: Text(
                emoji,
                style: TextStyle(fontSize: radius * 0.85),
              ),
            ),
    );
  }
}
