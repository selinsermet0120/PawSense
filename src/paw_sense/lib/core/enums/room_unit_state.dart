enum RoomUnitState {
  idle,
  active,
  cooldown;

  String get label {
    switch (this) {
      case RoomUnitState.idle:
        return 'BEKLEMEDE';
      case RoomUnitState.active:
        return 'AKTİF';
      case RoomUnitState.cooldown:
        return 'SOĞUMA';
    }
  }
}
