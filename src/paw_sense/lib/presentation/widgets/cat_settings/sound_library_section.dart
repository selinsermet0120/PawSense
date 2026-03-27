import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/deterrent_sound.dart';
import '../common/paw_card.dart';

class SoundLibrarySection extends StatelessWidget {
  final DeterrentSound selectedSound;
  final ValueChanged<DeterrentSound> onSoundSelected;

  const SoundLibrarySection({
    super.key,
    required this.selectedSound,
    required this.onSoundSelected,
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
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.library_music_outlined,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ses Kütüphanesi', style: AppTextStyles.headlineSmall),
                  Text(
                    'Caydırıcı Ses Tipi',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...DeterrentSound.values.map((sound) {
            final isSelected = selectedSound == sound;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SoundOptionTile(
                sound: sound,
                isSelected: isSelected,
                onTap: () => onSoundSelected(sound),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SoundOptionTile extends StatelessWidget {
  final DeterrentSound sound;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundOptionTile({
    required this.sound,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.neutral,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.tertiary.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                sound.icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sound.label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.safe,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
