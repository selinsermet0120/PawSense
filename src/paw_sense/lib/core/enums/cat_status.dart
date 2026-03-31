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

  /// Badge metin rengi — dolgulu badge'lerde beyaz
  Color get color {
    return Colors.white;
  }

  /// Badge arka plan rengi — dolgulu (filled) renk
  Color get backgroundColor {
    switch (this) {
      case CatStatus.guvenli:
        return AppColors.safe;
      case CatStatus.uyari:
        return AppColors.warning;
      case CatStatus.ihlal:
        return AppColors.danger;
    }
  }

  /// Kart border / ince vurgu gibi yerlerde kullanılacak ham durum rengi
  Color get statusColor {
    switch (this) {
      case CatStatus.guvenli:
        return AppColors.safe;
      case CatStatus.uyari:
        return AppColors.warning;
      case CatStatus.ihlal:
        return AppColors.danger;
    }
  }
}
