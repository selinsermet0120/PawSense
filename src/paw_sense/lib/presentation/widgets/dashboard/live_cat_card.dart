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

  /// Referanstaki gibi durum bazlı kart arka plan rengi
  Color get _cardBackground {
    switch (status) {
      case CatStatus.ihlal:
        return const Color(0xFFFFF0F0); // Pembe/kırmızımsı arka plan
      case CatStatus.uyari:
        return const Color(0xFFFFFCF0); // Sarımsı arka plan
      case CatStatus.guvenli:
        return const Color(0xFFF0FFF4); // Yeşilimsi arka plan
    }
  }

  @override
  Widget build(BuildContext context) {
    final isViolation = status == CatStatus.ihlal;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isViolation
              ? AppColors.danger.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.8),
          width: isViolation ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isViolation
                ? AppColors.danger.withValues(alpha: 0.12)
                : AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sol: Kedi avatarı
          CatAvatar(
            name: catName,
            imagePath: avatarPath,
            radius: 26,
          ),
          const SizedBox(width: 14),

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
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      zoneName,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sağ: RSSI + durum badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // RSSI sinyal gösterimi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _rssiColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 14,
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
              // Durum badge
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
