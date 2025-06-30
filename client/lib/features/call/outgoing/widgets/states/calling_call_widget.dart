import 'package:flutter/material.dart';
import '../hang_up_button.dart';
import '../call_header_widget.dart';

class CallingCallWidget extends StatelessWidget {
  const CallingCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutgoingCallHeaderWidget(
          stateIcon: Icons.call,
          iconColor: Colors.blue,
          stateText: 'Calling...',
        ),
        SizedBox(height: 40),
        HangUpButton(isOutgoing: true),
      ],
    );
  }
}
