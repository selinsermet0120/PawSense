import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/cat_status.dart';
import '../common/cat_avatar.dart';

class EventLogTile extends StatelessWidget {
  final String catName;
  final String? avatarPath;
  final String zoneName;
  final DateTime timestamp;
  final int durationSeconds;
  final CatStatus status;

  const EventLogTile({
    super.key,
    required this.catName,
    this.avatarPath,
    required this.zoneName,
    required this.timestamp,
    required this.durationSeconds,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM', 'tr_TR');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: status.color,
            width: 3,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CatAvatar(
            name: catName,
            imagePath: avatarPath,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  zoneName,
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeFormat.format(timestamp),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                dateFormat.format(timestamp),
                style: AppTextStyles.labelSmall,
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${durationSeconds}SN ${status == CatStatus.ihlal ? "CAYDIRICI" : status.label}',
              style: AppTextStyles.labelSmall.copyWith(
                color: status.color,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
