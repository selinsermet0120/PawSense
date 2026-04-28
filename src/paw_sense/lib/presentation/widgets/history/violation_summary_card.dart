import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ViolationSummaryCard extends StatelessWidget {
  final String topViolatorName;
  final int totalViolations;
  final String peakHours;

  const ViolationSummaryCard({
    super.key,
    required this.topViolatorName,
    required this.totalViolations,
    required this.peakHours,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'İhlal Karnesi',
                  style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
                ),
              ),
              Text(
                'Son 7 Gün',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryTile(
            icon: Icons.pets,
            label: 'En Çok İhlal Yapan',
            value: topViolatorName,
            accent: AppColors.primary,
            tint: AppColors.primary.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 10),
          _SummaryTile(
            icon: Icons.access_time,
            label: 'En Sık İhlal Saati',
            value: peakHours,
            accent: const Color(0xFFE08A5F),
            tint: AppColors.secondary.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final Color tint;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
