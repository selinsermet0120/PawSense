import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/cat_status.dart';
import '../common/cat_avatar.dart';
import '../common/status_badge.dart';
import '../common/tap_scale.dart';

class LiveCatCard extends StatefulWidget {
  final String catName;
  final String? avatarPath;
  final String zoneName;
  final int rssi;
  final CatStatus status;
  final VoidCallback? onTap;

  const LiveCatCard({
    super.key,
    required this.catName,
    this.avatarPath,
    required this.zoneName,
    required this.rssi,
    required this.status,
    this.onTap,
  });

  @override
  State<LiveCatCard> createState() => _LiveCatCardState();
}

class _LiveCatCardState extends State<LiveCatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color get _rssiColor {
    if (widget.rssi > -52) return AppColors.danger;
    if (widget.rssi >= -60) return AppColors.warning;
    return AppColors.safe;
  }

  Color get _cardBackground {
    switch (widget.status) {
      case CatStatus.ihlal:
        return const Color(0xFFFFF0F0);
      case CatStatus.uyari:
        return const Color(0xFFFFFBF0);
      case CatStatus.guvenli:
        return Colors.white;
    }
  }

  Color get _borderColor {
    switch (widget.status) {
      case CatStatus.ihlal:
        return AppColors.danger.withValues(alpha: 0.55);
      case CatStatus.uyari:
        return AppColors.warning.withValues(alpha: 0.4);
      case CatStatus.guvenli:
        return Colors.grey.withValues(alpha: 0.12);
    }
  }

  double get _borderWidth {
    switch (widget.status) {
      case CatStatus.ihlal:
        return 1.5;
      case CatStatus.uyari:
        return 1.0;
      case CatStatus.guvenli:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: widget.onTap ?? () {},
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_glowController.value);
          final glowColor = widget.status.statusColor;
          // Breathing glow intensity — stronger for ihlal, subtle for guvenli
          final baseAlpha = switch (widget.status) {
            CatStatus.ihlal => 0.22 + 0.20 * t,
            CatStatus.uyari => 0.14 + 0.12 * t,
            CatStatus.guvenli => 0.08 + 0.06 * t,
          };
          final blur = switch (widget.status) {
            CatStatus.ihlal => 22.0 + 10 * t,
            CatStatus.uyari => 18.0 + 6 * t,
            CatStatus.guvenli => 14.0,
          };
          final spread = switch (widget.status) {
            CatStatus.ihlal => 1.0 + 1.0 * t,
            CatStatus.uyari => 0.5,
            CatStatus.guvenli => 0.0,
          };

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: _cardBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor, width: _borderWidth),
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: baseAlpha),
                  blurRadius: blur,
                  spreadRadius: spread,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      children: [
        CatAvatar(
          name: widget.catName,
          imagePath: widget.avatarPath,
          radius: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.catName,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      widget.zoneName,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _rssiColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.signal_cellular_alt,
                    size: 12,
                    color: _rssiColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.rssi} dBm',
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
            StatusBadge(
              label: widget.status.label,
              color: widget.status.color,
              backgroundColor: widget.status.backgroundColor,
              fontSize: 10,
              dot: true,
            ),
          ],
        ),
      ],
    );
  }
}
