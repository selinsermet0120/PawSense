import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LiveBadge extends StatefulWidget {
  final String label;
  final Color color;
  final double fontSize;

  const LiveBadge({
    super.key,
    this.label = 'CANLI',
    this.color = AppColors.danger,
    this.fontSize = 10,
  });

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final glow = 0.25 + (0.55 * t);
        final dotOpacity = 0.55 + (0.45 * t);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: glow),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: dotOpacity,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
