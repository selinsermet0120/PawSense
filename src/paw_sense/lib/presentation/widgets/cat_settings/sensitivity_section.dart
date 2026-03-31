import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../common/paw_card.dart';

class SensitivitySection extends StatelessWidget {
  final int rssiThreshold;
  final ValueChanged<int> onChanged;

  const SensitivitySection({
    super.key,
    required this.rssiThreshold,
    required this.onChanged,
  });

  /// -30 (en yakın/kırmızı) → -80 (en uzak/yeşil) arasında renk hesapla
  Color _colorForValue(double value) {
    // value: -30 → -80
    // normalize: 0.0 (danger, -30) → 1.0 (safe, -80)
    final t = (value - (-30)) / (-80 - (-30)); // 0..1

    if (t < 0.4) {
      // Kırmızı → Turuncu
      return Color.lerp(AppColors.danger, AppColors.warning, t / 0.4)!;
    } else if (t < 0.65) {
      // Turuncu → Sarı
      return Color.lerp(
          AppColors.warning, const Color(0xFFFFD54F), (t - 0.4) / 0.25)!;
    } else {
      // Sarı → Yeşil
      return Color.lerp(
          const Color(0xFFFFD54F), AppColors.safe, (t - 0.65) / 0.35)!;
    }
  }

  String _zoneLabel(int value) {
    if (value > -52) return 'DANGER';
    if (value >= -60) return 'NEAR';
    return 'FAR';
  }

  Color _zoneBadgeColor(int value) {
    if (value > -52) return AppColors.danger;
    if (value >= -60) return AppColors.warning;
    return AppColors.safe;
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _colorForValue(rssiThreshold.toDouble());
    final zoneLabel = _zoneLabel(rssiThreshold);
    final zoneBadgeColor = _zoneBadgeColor(rssiThreshold);

    return PawCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hassasiyet Ayarı',
                        style: AppTextStyles.headlineSmall),
                    Text(
                      'RSSI Eşik Değeri',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Seçili değer gösterimi
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: currentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.signal_cellular_alt,
                      size: 18, color: currentColor),
                  const SizedBox(width: 8),
                  Text(
                    '$rssiThreshold dBm',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: currentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: zoneBadgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      zoneLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bölge göstergeleri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                _ZoneIndicator(
                  label: 'DANGER',
                  subtitle: '> -52 dBm',
                  color: AppColors.danger,
                ),
                _ZoneIndicator(
                  label: 'NEAR',
                  subtitle: '-52 ~ -60',
                  color: AppColors.warning,
                ),
                _ZoneIndicator(
                  label: 'FAR',
                  subtitle: '< -60 dBm',
                  color: AppColors.safe,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: currentColor,
              inactiveTrackColor: currentColor.withValues(alpha: 0.15),
              thumbColor: currentColor,
              overlayColor: currentColor.withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 3,
              ),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 22),
            ),
            child: Slider(
              value: rssiThreshold.toDouble(),
              min: -80,
              max: -30,
              divisions: 50,
              onChanged: (value) => onChanged(value.round()),
            ),
          ),

          // Min/max etiketleri
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('-80 dBm', style: AppTextStyles.labelSmall),
                Text('Uzak ← → Yakın', style: AppTextStyles.labelSmall),
                Text('-30 dBm', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneIndicator extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;

  const _ZoneIndicator({
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
