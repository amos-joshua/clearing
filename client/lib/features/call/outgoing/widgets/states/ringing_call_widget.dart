import 'package:flutter/material.dart';
import '../call_header_widget.dart';
import '../hang_up_button.dart';

class RingingCallWidget extends StatelessWidget {
  const RingingCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutgoingCallHeaderWidget(
          stateIcon: Icons.phone_in_talk,
          iconColor: Colors.blue.shade300,
          stateText: 'Ringing...',
        ),
        const SizedBox(height: 40),
        const HangUpButton(isOutgoing: true),
      ],
    );
  }
}
