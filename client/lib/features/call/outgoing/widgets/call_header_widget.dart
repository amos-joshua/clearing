import 'package:clearing_client/features/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/call_event.dart';

class OutgoingCallHeaderWidget extends StatelessWidget {
  const OutgoingCallHeaderWidget({
    super.key,
    required this.stateIcon,
    required this.stateText,
    this.iconSize = 64,
    this.iconColor = Colors.blue,
  });

  final IconData stateIcon;
  final String stateText;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final call = RepositoryProvider.of<Call>(context);

    final displayName =
        call.contact.target?.displayName ?? call.contactPhoneNumbers.join(', ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(stateIcon, size: iconSize, color: iconColor),
        const SizedBox(height: 8),
        Text(stateText, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(displayName, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text(switch (call.urgency) {
          CallUrgency.leisure => call.subject,
          _ => '${call.urgency.name}: ${call.subject}',
        }, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
