import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/ble_constants.dart';
import '../../../core/enums/cat_status.dart';
import '../common/cat_avatar.dart';
import '../common/tap_scale.dart';

class EventLogTile extends StatelessWidget {
  final String catName;
  final String? avatarPath;
  final String zoneName;
  final DateTime timestamp;
  final int durationSeconds;
  final CatStatus status;
  final VoidCallback? onTap;

  const EventLogTile({
    super.key,
    required this.catName,
    this.avatarPath,
    required this.zoneName,
    required this.timestamp,
    required this.durationSeconds,
    required this.status,
    this.onTap,
  });

  String _badgeLabel() {
    if (status == CatStatus.ihlal) {
      final seconds = durationSeconds > 0
          ? durationSeconds
          : BleConstants.deterrentDurationSeconds;
      return '${seconds}SN CAYDIRICI';
    }
    return status.label;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM', 'tr_TR');

    return TapScale(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color: status.statusColor,
              width: 3,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: status.statusColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
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
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: status.backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _badgeLabel(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
