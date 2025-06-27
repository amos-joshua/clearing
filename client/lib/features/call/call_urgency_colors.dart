import 'package:flutter/material.dart';

import 'model/call_event.dart';

extension CallUrgencyExtensions on CallUrgency {
  Color get backgroundColor => switch (this) {
    CallUrgency.leisure => Colors.green,
    CallUrgency.important => Colors.orange,
    CallUrgency.urgent => Colors.red,
  };

  Color get textColor => switch (this) {
    CallUrgency.leisure => Colors.white,
    CallUrgency.important => Colors.white,
    CallUrgency.urgent => Colors.white,
  };

  String label() => switch (this) {
    CallUrgency.leisure => 'Leisure',
    CallUrgency.important => 'Important',
    CallUrgency.urgent => 'Urgent',
  };
}
