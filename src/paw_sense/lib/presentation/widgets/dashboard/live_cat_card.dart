import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/cat_status.dart';
import '../common/cat_avatar.dart';
import '../common/status_badge.dart';

class LiveCatCard extends StatelessWidget {
  final String catName;
  final String? avatarPath;
  final String zoneName;
  final int rssi;
  final CatStatus status;

  const LiveCatCard({
    super.key,
    required this.catName,
    this.avatarPath,
    required this.zoneName,
    required this.rssi,
    required this.status,
  });

  Color get _rssiColor {
    if (rssi > -52) return AppColors.danger;
    if (rssi >= -60) return AppColors.warning;
    return AppColors.safe;
  }

  Color get _cardBackground {
    switch (status) {
      case CatStatus.ihlal:
        return const Color(0xFFFFF0F0);
      case CatStatus.uyari:
        return const Color(0xFFFFFBF0);
      case CatStatus.guvenli:
        return Colors.white;
    }
  }

  Color get _borderColor {
    switch (status) {
      case CatStatus.ihlal:
        return AppColors.danger;
      case CatStatus.uyari:
        return AppColors.warning.withValues(alpha: 0.4);
      case CatStatus.guvenli:
        return Colors.grey.withValues(alpha: 0.12);
    }
  }

  double get _borderWidth {
    switch (status) {
      case CatStatus.ihlal:
        return 1.5;
      case CatStatus.uyari:
        return 1.0;
      case CatStatus.guvenli:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: _borderWidth),
        boxShadow: [
          BoxShadow(
            color: status == CatStatus.ihlal
                ? AppColors.danger.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol: Kedi avatarı (büyütüldü)
          CatAvatar(
            name: catName,
            imagePath: avatarPath,
            radius: 28,
          ),
          const SizedBox(width: 12),

          // Orta: İsim ve bölge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  catName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        zoneName,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Sağ: RSSI badge + durum badge (ayrı ayrı)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // RSSI badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _rssiColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 12,
                      color: _rssiColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rssi dBm',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _rssiColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Durum badge (dolgulu)
              StatusBadge(
                label: status.label,
                color: status.color,
                backgroundColor: status.backgroundColor,
                fontSize: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
