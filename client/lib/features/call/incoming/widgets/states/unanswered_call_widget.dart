import 'package:flutter/material.dart';

import '../../../widgets/dismiss_call_button.dart';
import '../call_header_widget.dart';

class UnansweredCallWidget extends StatelessWidget {
  const UnansweredCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IncomingCallHeaderWidget(
          stateIcon: Icons.phone_missed,
          iconColor: Colors.orange,
          stateText: 'Call Unanswered',
        ),
        SizedBox(height: 20),
        DismissCallButton(),
      ],
    );
  }
}
