import 'package:flutter/material.dart';
import '../common/shimmer_box.dart';

class EventLogSkeleton extends StatelessWidget {
  const EventLogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 36, height: 36, borderRadius: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 90, height: 13),
                SizedBox(height: 6),
                ShimmerBox(width: 60, height: 10),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              ShimmerBox(width: 40, height: 12),
              SizedBox(height: 6),
              ShimmerBox(width: 34, height: 10),
            ],
          ),
          const SizedBox(width: 10),
          const ShimmerBox(width: 72, height: 18, borderRadius: 999),
        ],
      ),
    );
  }
}
