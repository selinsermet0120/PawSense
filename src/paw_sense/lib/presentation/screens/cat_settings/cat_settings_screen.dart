import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/deterrent_sound.dart';
import '../../../domain/entities/cat_profile.dart';
import '../../providers/cat_provider.dart';
import '../../providers/violation_provider.dart';
import '../../widgets/common/cat_avatar.dart';
import '../../widgets/cat_settings/beacon_section.dart';
import '../../widgets/cat_settings/behavior_analysis_section.dart';
import '../../widgets/cat_settings/sensitivity_section.dart';
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
        backgroundColor: AppColors.neutral,
        title: Text(
          'Kedilerim',
          style: AppTextStyles.headline.copyWith(
            color: AppColors.primary,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: Consumer<CatProvider>(
        builder: (context, catProvider, _) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddCatDialog(context, catProvider),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Kedi Ekle', style: TextStyle(fontWeight: FontWeight.w600)),
          );
        },
      ),
      body: Consumer2<CatProvider, ViolationProvider>(
        builder: (context, catProvider, violationProvider, _) {
          if (catProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (catProvider.cats.isEmpty) {
            return _buildEmptyState();
          }

          if (_selectedCatIndex >= catProvider.cats.length) {
            _selectedCatIndex = 0;
          }

          final cat = catProvider.cats[_selectedCatIndex];
          final catViolations = violationProvider.allViolations
              .where((v) => v.catId == cat.id)
              .toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 4),

                // Kedi seçim çipsleri
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: catProvider.cats.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedCatIndex == index;
                      final c = catProvider.cats[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCatIndex = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary.withValues(alpha: 0.3),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CatAvatar(name: c.name, radius: 12),
                                const SizedBox(width: 6),
                                Text(
                                  c.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Profil alanı
                _buildProfileHeader(cat),

                const SizedBox(height: 20),

                BeaconSection(
                  beaconId: cat.beaconId.isNotEmpty ? cat.beaconId : null,
                  onBeaconIdChanged: (newId) {
                    final updated = cat.copyWith(beaconId: newId);
                    catProvider.cats[_selectedCatIndex] = updated;
                    setState(() {});
                  },
                ),

                const SizedBox(height: 12),

                SensitivitySection(
                  rssiThreshold: cat.rssiThreshold,
                  onChanged: (value) {
                    final updated = cat.copyWith(rssiThreshold: value);
                    catProvider.cats[_selectedCatIndex] = updated;
                    setState(() {});
                  },
                ),

                const SizedBox(height: 12),

                SoundLibrarySection(
                  selectedSound: cat.deterrentSound,
                  onSoundSelected: (sound) {
                    final updated = cat.copyWith(deterrentSound: sound);
                    catProvider.cats[_selectedCatIndex] = updated;
                    setState(() {});
                  },
                ),

                const SizedBox(height: 12),

                BehaviorAnalysisSection(violations: catViolations),

                const SizedBox(height: 100),
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
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 3,
            ),
          ),
          child: CatAvatar(
            name: cat.name,
            imagePath: cat.avatarPath,
            radius: 52,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 14),
        Text(cat.name, style: AppTextStyles.headline.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          'Evcil Dostunuzun Akıllı Güvenlik Ayarları',
          style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: AppColors.primary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('Henüz kedi eklenmedi', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Aşağıdaki butona basarak\nkedini ekleyebilirsin!',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCatDialog(BuildContext context, CatProvider catProvider) {
    showDialog(
      context: context,
      builder: (ctx) => _AddCatDialog(catProvider: catProvider),
    );
  }
}

// ─── Kedi Ekleme Dialog ───────────────────────────────────────────────────────

class _AddCatDialog extends StatefulWidget {
  final CatProvider catProvider;
  const _AddCatDialog({required this.catProvider});

  @override
  State<_AddCatDialog> createState() => _AddCatDialogState();
}

class _AddCatDialogState extends State<_AddCatDialog> {
  final _nameController = TextEditingController();
  final _beaconController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _pickedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _beaconController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 512);
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kedi adı girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    Uint8List? imageBytes;
    String? fileName;

    if (_pickedImage != null) {
      imageBytes = await File(_pickedImage!.path).readAsBytes();
      fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    final cat = CatProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      avatarPath: '',
      beaconId: _beaconController.text.trim(),
      deterrentSound: DeterrentSound.bip,
    );

    await widget.catProvider.addCatWithImage(
      cat: cat,
      imageBytes: imageBytes,
      fileName: fileName,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('Yeni Kedi Ekle'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fotoğraf seçici
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: _pickedImage != null
                    ? ClipOval(
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: AppColors.primary.withValues(alpha: 0.7), size: 26),
                          const SizedBox(height: 4),
                          Text(
                            'Fotoğraf Ekle',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // Kedi adı
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Kedi Adı *',
                hintText: 'ör. Luna',
                prefixIcon: const Icon(Icons.pets_outlined, size: 18, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            // Beacon ID
            TextField(
              controller: _beaconController,
              decoration: InputDecoration(
                labelText: 'Beacon ID (isteğe bağlı)',
                hintText: 'ör. PX-9921-A',
                prefixIcon: const Icon(Icons.bluetooth_outlined, size: 18, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Ekle'),
        ),
      ],
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              ),
              title: const Text('Galeriden Seç', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Colors.brown),
              ),
              title: const Text('Kamera ile Çek', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
