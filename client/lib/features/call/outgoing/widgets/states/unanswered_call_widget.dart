import 'package:flutter/material.dart';

import '../../../widgets/dismiss_call_button.dart';
import '../call_header_widget.dart';

class UnansweredCallWidget extends StatelessWidget {
  const UnansweredCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutgoingCallHeaderWidget(
          stateIcon: Icons.phone_missed,
          iconColor: Colors.orange.shade300,
          stateText: 'Call Unanswered',
        ),
        const SizedBox(height: 20),
        const DismissCallButton(),
      ],
    );
  }
}
