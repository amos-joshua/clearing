import 'package:flutter/material.dart';
import '../hang_up_button.dart';
import '../call_header_widget.dart';

class CallingCallWidget extends StatelessWidget {
  final bool showHangUpButton;
  const CallingCallWidget({super.key, this.showHangUpButton = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const OutgoingCallHeaderWidget(
          stateIcon: Icons.call,
          iconColor: Colors.blue,
          stateText: 'Calling...',
        ),
        const SizedBox(height: 40),
        if (showHangUpButton) const HangUpButton(isOutgoing: true),
      ],
    );
  }
}
