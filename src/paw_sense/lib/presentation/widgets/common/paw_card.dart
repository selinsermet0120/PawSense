import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'tap_scale.dart';

class PawCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const PawCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return TapScale(onTap: onTap, child: card);
  }
}
