import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../common/paw_card.dart';

class BeaconSection extends StatefulWidget {
  final String? beaconId;
  final ValueChanged<String>? onBeaconIdChanged;

  const BeaconSection({
    super.key,
    this.beaconId,
    this.onBeaconIdChanged,
  });

  @override
  State<BeaconSection> createState() => _BeaconSectionState();
}

class _BeaconSectionState extends State<BeaconSection> {
  late TextEditingController _manualController;
  bool _showManualInput = false;

  @override
  void initState() {
    super.initState();
    _manualController = TextEditingController(text: widget.beaconId ?? '');
  }

  @override
  void didUpdateWidget(BeaconSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beaconId != widget.beaconId) {
      _manualController.text = widget.beaconId ?? '';
    }
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _showBleScanDialog() {
    // Simüle edilmiş BLE tarama sonuçları
    final mockDevices = [
      {'id': 'PX-9921-A', 'rssi': -45, 'name': 'PawSense Beacon #1'},
      {'id': 'PX-8832-B', 'rssi': -62, 'name': 'PawSense Beacon #2'},
      {'id': 'PX-7743-C', 'rssi': -71, 'name': 'PawSense Beacon #3'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bluetooth_searching,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Bulunan Cihazlar',
                      style: AppTextStyles.headlineSmall),
                ],
              ),
              const SizedBox(height: 16),
              ...mockDevices.map((device) {
                final isCurrentDevice = widget.beaconId == device['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      widget.onBeaconIdChanged?.call(device['id'] as String);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCurrentDevice
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrentDevice
                              ? AppColors.primary
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bluetooth,
                            color: isCurrentDevice
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device['name'] as String,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  device['id'] as String,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${device['rssi']} dBm',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (isCurrentDevice) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle,
                                color: AppColors.safe, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bluetooth,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Beacon Tanımlama',
                  style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: 14),

          // Mevcut Beacon ID gösterimi
          const Text('nRF52810 Modül ID', style: AppTextStyles.bodySmall),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.neutral,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              widget.beaconId != null && widget.beaconId!.isNotEmpty
                  ? widget.beaconId!
                  : '—',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.beaconId != null && widget.beaconId!.isNotEmpty
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // İki eşleştirme yöntemi
          Row(
            children: [
              // BLE Tarama butonu
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showBleScanDialog,
                  icon: const Icon(Icons.bluetooth_searching, size: 18),
                  label: const Text('Cihaz Tara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Manuel Giriş butonu
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _showManualInput = !_showManualInput;
                  }),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Manuel Giriş'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Manuel giriş alanı
          if (_showManualInput) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualController,
                    decoration: InputDecoration(
                      hintText: 'ör. PX-9921-A',
                      hintStyle: AppTextStyles.bodySmall,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.textSecondary
                                .withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    style: AppTextStyles.body.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final text = _manualController.text.trim();
                    if (text.isNotEmpty) {
                      widget.onBeaconIdChanged?.call(text);
                      setState(() => _showManualInput = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          Text(
            "Modül ID'si tasmanın iç kısmında yer alan QR kodun altındaki benzersiz numaradır.",
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
