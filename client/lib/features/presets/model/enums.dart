import 'package:flutter/material.dart';
import '../../../utils/string_utils.dart';

enum RingType {
  silent, vibrate, ring
}

extension RingTypeUtils on RingType {
  String get label => toString().replaceFirst('RingType.', '');

  IconData get icon => switch(this) {
    RingType.silent => Icons.volume_off,
    RingType.vibrate => Icons.vibration,
    RingType.ring => Icons.volume_up
  };

  RingType get nextRingType => switch(this) {
    RingType.silent => RingType.vibrate,
    RingType.vibrate => RingType.ring,
    RingType.ring => RingType.silent
  };
}

enum Days {
  sunday, monday, tuesday, wednesday, thursday, friday, saturday
}

extension DaysUtils on Days {
  String label() => toString().replaceFirst('Days.', '').capitalized;
  String shortLabel() => label().substring(0, 2);
}

enum CallStatus {
  idle, calling, ringing, answered, rejected, notAnswered, recipientNotRegistered, error, ongoing
}

extension CallStatusUtils on CallStatus {
  String label() => toString().replaceFirst('CallStatus.', '');
}