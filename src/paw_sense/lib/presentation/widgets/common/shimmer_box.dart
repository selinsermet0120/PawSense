import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    this.baseColor = const Color(0xFFE9ECEC),
    this.highlightColor = const Color(0xFFF6F9F8),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
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
        final dx = -1.0 + 3.0 * _controller.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(dx - 1, 0),
                end: Alignment(dx, 0),
                colors: [
                  widget.baseColor,
                  widget.highlightColor,
                  widget.baseColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              color: widget.baseColor,
            ),
          ),
        );
      },
    );
  }
}

class CatCardSkeleton extends StatelessWidget {
  const CatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 56, height: 56, borderRadius: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 110, height: 14),
                const SizedBox(height: 8),
                ShimmerBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 11,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: const [
              ShimmerBox(width: 66, height: 22, borderRadius: 12),
              SizedBox(height: 8),
              ShimmerBox(width: 70, height: 20, borderRadius: 999),
            ],
          ),
        ],
      ),
    );
  }
}
