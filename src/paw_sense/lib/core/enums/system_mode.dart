import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SystemMode {
  tarama,
  caydirici,
  bekle;

  String get label {
    switch (this) {
      case SystemMode.tarama:
        return 'TARAMA';
      case SystemMode.caydirici:
        return 'CAYDIRICI';
      case SystemMode.bekle:
        return 'BEKLE';
    }
  }

  Color get color {
    switch (this) {
      case SystemMode.tarama:
        return AppColors.safe;
      case SystemMode.caydirici:
        return AppColors.warning;
      case SystemMode.bekle:
        return Colors.grey;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case SystemMode.tarama:
        return AppColors.badgeSafe;
      case SystemMode.caydirici:
        return AppColors.badgeWarning;
      case SystemMode.bekle:
        return AppColors.badgeIdle;
    }
  }
}
