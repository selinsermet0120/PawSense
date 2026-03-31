import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/violation_record.dart';
import '../common/paw_card.dart';

class BehaviorAnalysisSection extends StatelessWidget {
  final List<ViolationRecord> violations;

  const BehaviorAnalysisSection({
    super.key,
    required this.violations,
  });

  int get _totalAttempts => violations.length;

  double get _deterrenceRate {
    if (violations.isEmpty) return 0;
    final deterred =
        violations.where((v) => v.durationSeconds > 0).length;
    return (deterred / violations.length) * 100;
  }

  String get _personalityType {
    if (violations.isEmpty) return 'Sakin';

    final now = DateTime.now();
    final last7Days = violations
        .where((v) => v.timestamp.isAfter(now.subtract(const Duration(days: 7))))
        .toList();

    if (last7Days.isEmpty) return 'Sakin';

    // Günlük ortalama
    final daySpan = now.difference(last7Days.last.timestamp).inDays.clamp(1, 7);
    final dailyAvg = last7Days.length / daySpan;

    // Farklı bölge sayısı
    final uniqueZones = last7Days.map((v) => v.zoneName).toSet().length;

    // Cooldown sonrası hemen tekrar deneme kontrolü
    // Aynı kedinin aynı bölgede 2 dakika içinde tekrar denemesi
    int quickRetries = 0;
    final sorted = List.of(last7Days)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (int i = 1; i < sorted.length; i++) {
      final gap = sorted[i].timestamp.difference(sorted[i - 1].timestamp);
      if (gap.inMinutes <= 2 && sorted[i].zoneName == sorted[i - 1].zoneName) {
        quickRetries++;
      }
    }

    // İnatçı: caydırıcıya rağmen hemen tekrar deniyor
    if (quickRetries >= 3) return 'İnatçı';

    // Keşifçi: farklı bölgelerde deniyor
    if (uniqueZones >= 3) return 'Keşifçi';

    // Maceracı: günde 3+ ihlal
    if (dailyAvg >= 3) return 'Maceracı';

    // Fırsatçı: günde 1-2
    if (dailyAvg >= 1) return 'Fırsatçı';

    // Sakin: haftada 1-2
    return 'Sakin';
  }

  IconData get _personalityIcon {
    switch (_personalityType) {
      case 'Maceracı':
        return Icons.explore;
      case 'Fırsatçı':
        return Icons.access_time;
      case 'İnatçı':
        return Icons.repeat;
      case 'Keşifçi':
        return Icons.travel_explore;
      default:
        return Icons.spa;
    }
  }

  Color get _personalityColor {
    switch (_personalityType) {
      case 'Maceracı':
        return AppColors.danger;
      case 'Fırsatçı':
        return AppColors.warning;
      case 'İnatçı':
        return const Color(0xFFAB47BC);
      case 'Keşifçi':
        return const Color(0xFF42A5F5);
      default:
        return AppColors.safe;
    }
  }

  /// Son 7 günün günlük ihlal sayıları (bugünden geriye)
  List<int> get _weeklyData {
    final now = DateTime.now();
    final counts = List.filled(7, 0);
    for (final v in violations) {
      final daysAgo = now.difference(v.timestamp).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        counts[6 - daysAgo] += 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Davranış Analizi', style: AppTextStyles.headlineSmall),
                  Text(
                    'İhlal verilerine dayalı analiz',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Kişilik tipi kartı
          _buildPersonalityCard(),

          const SizedBox(height: 16),

          // İstatistik satırı
          Row(
            children: [
              Expanded(child: _buildStatTile('Toplam Deneme', '$_totalAttempts', Icons.warning_amber_rounded, AppColors.warning)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatTile('Caydırma Oranı', '${_deterrenceRate.toStringAsFixed(0)}%', Icons.shield_outlined, AppColors.safe)),
            ],
          ),

          const SizedBox(height: 16),

          // 7 günlük bar chart
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildPersonalityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _personalityColor.withValues(alpha: 0.08),
            _personalityColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _personalityColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _personalityColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _personalityIcon,
              color: _personalityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kedi Kişiliği',
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  _personalityType,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 18,
                    color: _personalityColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _personalityDescription,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _personalityDescription {
    switch (_personalityType) {
      case 'Maceracı':
        return 'Çok sık ihlal, kısa aralıklarla tekrar deniyor';
      case 'Fırsatçı':
        return 'Belirli saatlerde, orta sıklıkla deniyor';
      case 'İnatçı':
        return 'Caydırıcıya rağmen hemen tekrar deniyor';
      case 'Keşifçi':
        return 'Farklı bölgelerde keşif yapıyor';
      default:
        return 'Nadir ihlal, caydırıcıya iyi yanıt veriyor';
    }
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final data = _weeklyData;
    final maxVal = data.reduce((a, b) => a > b ? a : b).clamp(1, 999);
    final now = DateTime.now();
    final dayLabels = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'][d.weekday - 1];
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son 7 Gün',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final barHeight = maxVal > 0 ? (data[i] / maxVal) * 56 : 0.0;
              final hasData = data[i] > 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasData)
                        Text(
                          '${data[i]}',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Container(
                        height: hasData ? barHeight.clamp(4, 56) : 4,
                        decoration: BoxDecoration(
                          color: hasData
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayLabels[i],
                        style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
