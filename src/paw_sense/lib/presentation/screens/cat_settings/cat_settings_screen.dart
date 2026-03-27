import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/deterrent_sound.dart';
import '../../../domain/entities/cat_profile.dart';
import '../../providers/cat_provider.dart';
import '../../widgets/common/cat_avatar.dart';
import '../../widgets/cat_settings/beacon_section.dart';
import '../../widgets/cat_settings/sound_library_section.dart';

class CatSettingsScreen extends StatefulWidget {
  const CatSettingsScreen({super.key});

  @override
  State<CatSettingsScreen> createState() => _CatSettingsScreenState();
}

class _CatSettingsScreenState extends State<CatSettingsScreen> {
  int _selectedCatIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        title: const Text('Kedilerim', style: AppTextStyles.headline),
      ),
      body: Consumer<CatProvider>(
        builder: (context, catProvider, _) {
          if (catProvider.cats.isEmpty) {
            return _buildEmptyState(context, catProvider);
          }

          final cat = catProvider.cats[_selectedCatIndex];

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Kedi seçim çipsleri
                if (catProvider.cats.length > 1)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: catProvider.cats.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedCatIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(catProvider.cats[index].name),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color:
                                  isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) {
                              setState(() => _selectedCatIndex = index);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Profil alanı
                _buildProfileHeader(cat),

                const SizedBox(height: 20),

                // Beacon Tanımlama
                BeaconSection(
                  beaconId: cat.beaconId.isNotEmpty ? cat.beaconId : null,
                  onScanPressed: () {
                    // QR tarama işlevi
                  },
                ),

                const SizedBox(height: 12),

                // Ses Kütüphanesi
                SoundLibrarySection(
                  selectedSound: cat.deterrentSound,
                  onSoundSelected: (sound) {
                    final updated = cat.copyWith(deterrentSound: sound);
                    catProvider.cats[_selectedCatIndex] = updated;
                    // Veritabanına da kaydet
                    setState(() {});
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

  Widget _buildProfileHeader(CatProfile cat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
          child: CatAvatar(
            name: cat.name,
            imagePath: cat.avatarPath,
            radius: 48,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          cat.name,
          style: AppTextStyles.headline,
        ),
        const SizedBox(height: 4),
        Text(
          'Evcil Dostunuzun Akıllı Güvenlik Ayarları',
          style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, CatProvider catProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz kedi eklenmedi',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Kedini ekleyerek güvenlik sistemini\nkullanmaya başla!',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCatDialog(context, catProvider),
              icon: const Icon(Icons.add),
              label: const Text('Kedi Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCatDialog(BuildContext context, CatProvider catProvider) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yeni Kedi Ekle'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Kedi Adı',
            hintText: 'ör. Luna',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final cat = CatProfile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  avatarPath: '',
                  beaconId: '',
                  deterrentSound: DeterrentSound.bip,
                );
                catProvider.addCat(cat);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
