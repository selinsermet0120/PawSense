import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        backgroundColor: AppColors.neutral,
        title: Text(
          'Ayarlar',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.primary,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Bildirimler
              _buildSectionHeader('Bildirimler'),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.notifications_outlined,
                  iconColor: AppColors.primary,
                  title: 'Anlık Bildirimler',
                  subtitle: 'İhlal tespit edildiğinde bildir',
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotifications,
                ),
              ]),

              const SizedBox(height: 20),

              // Hassasiyet
              _buildSectionHeader('Hassasiyet'),
              _buildCard([
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.tertiary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Genel Hassasiyet',
                                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                _sensitivityLabel(settings.sensitivityLevel),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _sensitivityButton(context, settings, 0, 'Düşük'),
                          const SizedBox(width: 8),
                          _sensitivityButton(context, settings, 1, 'Orta'),
                          const SizedBox(width: 8),
                          _sensitivityButton(context, settings, 2, 'Yüksek'),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),

              const SizedBox(height: 20),

              // Görünüm
              _buildSectionHeader('Görünüm'),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  iconColor: const Color(0xFF5C6BC0),
                  title: 'Karanlık Mod',
                  subtitle: 'Koyu tema kullan',
                  value: settings.darkMode,
                  onChanged: settings.setDarkMode,
                ),
              ]),

              const SizedBox(height: 20),

              // Hesap
              _buildSectionHeader('Hesap'),
              _buildCard([
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                      ),
                      title: Text(
                        'Çıkış Yap',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                      subtitle: auth.user?.email != null
                          ? Text(auth.user!.email!, style: AppTextStyles.bodySmall)
                          : null,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Çıkış Yap'),
                            content: const Text('Hesabınızdan çıkmak istediğinizden emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('İptal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Çıkış Yap'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          final ok = await auth.signOut();
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(auth.errorMessage ?? 'Çıkış yapılamadı'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _sensitivityButton(
    BuildContext context,
    SettingsProvider settings,
    int level,
    String label,
  ) {
    final isSelected = settings.sensitivityLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () => settings.setSensitivity(level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.neutral,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  String _sensitivityLabel(int level) {
    switch (level) {
      case 0: return 'Düşük — Yalnızca yakın mesafe';
      case 1: return 'Orta — Önerilen ayar';
      case 2: return 'Yüksek — Geniş alan taraması';
      default: return '';
    }
  }
}
