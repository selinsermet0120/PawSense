import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CatStatus {
  guvenli,
  uyari,
  ihlal;

  String get label {
    switch (this) {
      case CatStatus.guvenli:
        return 'GÜVENLİ';
      case CatStatus.uyari:
        return 'UYARI';
      case CatStatus.ihlal:
        return 'İHLAL';
    }
  }

  Color get color {
    switch (this) {
      case CatStatus.guvenli:
        return AppColors.safe;
      case CatStatus.uyari:
        return AppColors.warning;
      case CatStatus.ihlal:
        return AppColors.danger;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CatStatus.guvenli:
        return AppColors.badgeSafe;
      case CatStatus.uyari:
        return AppColors.badgeWarning;
      case CatStatus.ihlal:
        return AppColors.badgeDanger;
    }
  }
}
