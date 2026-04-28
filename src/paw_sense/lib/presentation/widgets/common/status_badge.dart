import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;
  final double fontSize;
  final IconData? icon;
  final bool dot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.backgroundColor,
    this.fontSize = 11,
    this.icon,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(icon, size: fontSize + 2, color: color),
            ),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
