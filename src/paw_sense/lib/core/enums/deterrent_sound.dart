import 'package:flutter/material.dart';

enum DeterrentSound {
  bip,
  fislama,
  yuksekFrekans;

  String get label {
    switch (this) {
      case DeterrentSound.bip:
        return 'Bip';
      case DeterrentSound.fislama:
        return 'Fıslama';
      case DeterrentSound.yuksekFrekans:
        return 'Yüksek Frekans';
    }
  }

  IconData get icon {
    switch (this) {
      case DeterrentSound.bip:
        return Icons.volume_up;
      case DeterrentSound.fislama:
        return Icons.volume_down;
      case DeterrentSound.yuksekFrekans:
        return Icons.hearing;
    }
  }
}
