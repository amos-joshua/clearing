import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/logging/logging_service.dart';
import '../../model/call.dart';
import '../../model/call_event.dart';

class IncomingCallHeaderWidget extends StatelessWidget {
  const IncomingCallHeaderWidget({
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
    final logger = context.read<LoggingService>();
    String sender = '';
    if (call.contactEmails.length != 1) {
      sender = call.contactEmails[0];
    } else {
      logger.warning(
        'Call ${call.callUuid} has ${call.contactEmails.length} contact emails, expected 1',
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(stateIcon, size: iconSize, color: iconColor),
        const SizedBox(height: 8),
        Text(stateText, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(sender, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 4),
        Text(switch (call.urgency) {
          CallUrgency.leisure => call.subject,
          _ => '${call.urgency.name}: ${call.subject}',
        }, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
