import 'package:flutter/material.dart';

import '../../../widgets/dismiss_call_button.dart';
import '../call_header_widget.dart';

class RejectedCallWidget extends StatelessWidget {
  const RejectedCallWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IncomingCallHeaderWidget(
          stateIcon: Icons.phone_disabled,
          iconColor: Colors.red,
          stateText: 'Call Rejected',
        ),
        SizedBox(height: 20),
        DismissCallButton(),
      ],
    );
  }
}
