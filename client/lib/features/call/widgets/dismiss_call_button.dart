import 'package:flutter/material.dart';

import 'call_action_button.dart';

class DismissCallButton extends StatelessWidget {
  const DismissCallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CallActionButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icons.check_circle,
      label: 'Done',
      backgroundColor: Colors.blue.shade500,
    );
  }
}
