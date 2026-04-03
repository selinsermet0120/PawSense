import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/dashboard/system_mode_card.dart';
import '../../widgets/dashboard/live_cat_card.dart';
import '../../widgets/dashboard/quick_action_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToHistory;
  final VoidCallback? onOpenSettings;

  const DashboardScreen({
    super.key,
    this.onNavigateToHistory,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        backgroundColor: AppColors.neutral,
        title: Text(
          'PawSense',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.primary,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // Sistem Modu
                const SystemModeCard(),

                const SizedBox(height: 20),

                // Aktif İhlal Kontrolü başlığı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Aktif İhlal Kontrolü',
                        style: AppTextStyles.headlineSmall.copyWith(fontSize: 17),
                      ),
                      const SizedBox(width: 8),
                      const StatusBadge(
                        label: 'CANLI',
                        color: Colors.white,
                        backgroundColor: AppColors.danger,
                        fontSize: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Canlı kedi listesi
                if (dashboard.liveCats.isEmpty)
                  _buildEmptyState()
                else
                  ...dashboard.liveCats.map((cat) {
                    return LiveCatCard(
                      catName: cat.catName,
                      zoneName: cat.zoneName,
                      rssi: cat.rssi,
                      status: cat.status,
                    );
                  }),

                const SizedBox(height: 20),

                // Hızlı işlem kartları
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      QuickActionCard(
                        icon: Icons.assignment_outlined,
                        title: 'İhlal Kaydı',
                        subtitle: 'Son 24 saat analizi',
                        iconBackgroundColor: AppColors.secondary,
                        onTap: onNavigateToHistory,
                      ),
                      QuickActionCard(
                        icon: Icons.tune,
                        title: 'Ayarlar',
                        subtitle: 'Hassasiyet modları',
                        iconBackgroundColor: AppColors.tertiary,
                        onTap: onOpenSettings,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.pets,
              size: 48,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz kedi eklenmedi',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            const Text(
              '"Kedilerim" sekmesinden kedi ekleyebilirsiniz',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
