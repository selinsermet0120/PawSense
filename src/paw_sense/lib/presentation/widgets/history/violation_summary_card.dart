import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../common/paw_card.dart';

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
    return PawCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'İhlal Karnesi (Son 7 Gün)',
                style: AppTextStyles.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.pets,
                  iconColor: AppColors.danger,
                  label: 'En Çok İhlal Yapan',
                  value: topViolatorName,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.textSecondary.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.access_time,
                  iconColor: AppColors.warning,
                  label: 'En Sık İhlal Saati',
                  value: peakHours,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
