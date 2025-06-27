import 'package:flutter/material.dart';

import '../../../widgets/dismiss_call_button.dart';
import '../call_header_widget.dart';

class RejectedCallWidget extends StatelessWidget {
  const RejectedCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutgoingCallHeaderWidget(
          stateIcon: Icons.phone_disabled,
          iconColor: Colors.red.shade500,
          stateText: 'Call Rejected',
        ),
        const SizedBox(height: 20),
        const DismissCallButton(),
      ],
    );
  }
}
