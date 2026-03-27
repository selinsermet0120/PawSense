import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/cat_status.dart';
import '../../providers/cat_provider.dart';
import '../../providers/violation_provider.dart';
import '../../widgets/history/violation_summary_card.dart';
import '../../widgets/history/event_log_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? _selectedCatFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViolationProvider>().loadViolations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        title: const Text('Geçmiş', style: AppTextStyles.headline),
      ),
      body: Consumer2<ViolationProvider, CatProvider>(
        builder: (context, violationProvider, catProvider, _) {
          if (violationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final violations = violationProvider.violations;

          // Özet hesaplamaları
          final topViolator = _getTopViolator(violations, catProvider);
          final peakHours = _getPeakHours(violations);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // İhlal Karnesi
                ViolationSummaryCard(
                  topViolatorName: topViolator,
                  totalViolations: violations.length,
                  peakHours: peakHours,
                ),

                const SizedBox(height: 16),

                // Kedi filtre butonları
                _buildCatFilters(catProvider),

                const SizedBox(height: 12),

                // Olay Günlüğü başlığı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.list_alt,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Olay Günlüğü',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Olay listesi
                if (violations.isEmpty)
                  _buildEmptyLog()
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: violations.length,
                    itemBuilder: (context, index) {
                      final v = violations[index];
                      final catName = _getCatName(v.catId, catProvider);

                      return EventLogTile(
                        catName: catName,
                        zoneName: v.zoneName,
                        timestamp: v.timestamp,
                        durationSeconds: v.durationSeconds,
                        status: v.status,
                      );
                    },
                  ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatFilters(CatProvider catProvider) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: 'Hepsi',
            isSelected: _selectedCatFilter == null,
            onTap: () {
              setState(() => _selectedCatFilter = null);
              context.read<ViolationProvider>().filterByCat(null);
            },
          ),
          ...catProvider.cats.map((cat) {
            return _FilterChip(
              label: cat.name,
              isSelected: _selectedCatFilter == cat.id,
              onTap: () {
                setState(() => _selectedCatFilter = cat.id);
                context.read<ViolationProvider>().filterByCat(cat.id);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyLog() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.safe.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Kayıtlı ihlal yok',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tüm kediler güvende!',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _getTopViolator(
    List violations,
    CatProvider catProvider,
  ) {
    if (violations.isEmpty) return '—';
    final counts = <String, int>{};
    for (final v in violations) {
      if (v.status == CatStatus.ihlal) {
        counts[v.catId] = (counts[v.catId] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return '—';
    final topId = counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return _getCatName(topId, catProvider);
  }

  String _getPeakHours(List violations) {
    if (violations.isEmpty) return '—';
    final hourCounts = <int, int>{};
    for (final v in violations) {
      final hour = v.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    if (hourCounts.isEmpty) return '—';
    final peakHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return '${peakHour.toString().padLeft(2, '0')}:00–${(peakHour + 2).toString().padLeft(2, '0')}:00';
  }

  String _getCatName(String catId, CatProvider catProvider) {
    final match = catProvider.cats.where((c) => c.id == catId);
    return match.isNotEmpty ? match.first.name : 'Bilinmeyen';
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
