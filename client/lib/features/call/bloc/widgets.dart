import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relative_time/relative_time.dart';

import '../../../services/active_call/active_call.dart';
import '../../../services/logging/logging_service.dart';
import '../../../services/storage/database.dart';
import '../../../utils/dialogs.dart';
import '../../call_composer/bloc/bloc.dart';
import '../../contacts/model/contact.dart';
import '../call_urgency_colors.dart';
import '../model/call.dart';
import '../model/call_event.dart';
import '../../../utils/string_utils.dart';
import 'cubit.dart';

class CallConfigurationPane extends StatelessWidget {
  final void Function(Call?) onCall;
  const CallConfigurationPane({required this.onCall, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Make a(n)'),
        //const CallDurationSelector(),
        const CallUrgencySelector(),
        CallButton(onCall: onCall),
        const CallSubjectField(),
      ],
    );
  }
}

class CallUrgencySelector extends StatelessWidget {
  const CallUrgencySelector({super.key});

  ButtonSegment _buttonSegment(CallUrgency urgency, bool selected) =>
      ButtonSegment<CallUrgency>(
        value: urgency,
        label: Text(
          urgency.label().capitalized,
          style: TextStyle(
            color: urgency.backgroundColor.withAlpha(selected ? 255 : 128),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final currentCall = context.watch<CallComposerBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SegmentedButton(
        showSelectedIcon: false,
        segments: [
          _buttonSegment(
            CallUrgency.leisure,
            currentCall.state.urgency == CallUrgency.leisure,
          ),
          _buttonSegment(
            CallUrgency.important,
            currentCall.state.urgency == CallUrgency.important,
          ),
          _buttonSegment(
            CallUrgency.urgent,
            currentCall.state.urgency == CallUrgency.urgent,
          ),
        ],
        selected: {currentCall.state.urgency},
        onSelectionChanged: (selection) {
          currentCall.add(CallComposerEventUrgencyUpdated(selection.first));
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
      ),
    );
  }
}

class CallSubjectField extends StatelessWidget {
  const CallSubjectField({super.key});

  @override
  Widget build(BuildContext context) {
    final currentCall = context.read<CallComposerBloc>();
    final controller = TextEditingController();
    controller.text = currentCall.state.subject;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'About...',
          hintStyle: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
        ),
        onChanged: (newValue) {
          currentCall.add(CallComposerEventSubjectUpdated(newValue.trim()));
        },
      ),
    );
  }
}

class CallButton extends StatelessWidget {
  final void Function(Call?) onCall;
  const CallButton({required this.onCall, super.key});

  @override
  Widget build(BuildContext context) {
    final callComposer = context.watch<CallComposerBloc>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final call = await callComposer.createOutgoing();
            onCall(call);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: callComposer.state.urgency.backgroundColor,
          ),
          child: const Text('call', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class ContactNameFromEmailsTile extends StatelessWidget {
  final List<String> emails;
  const ContactNameFromEmailsTile({required this.emails, super.key});

  @override
  Widget build(BuildContext context) {
    final database = context.read<Database>();
    return FutureBuilder(
      future: database.contactForEmails(emails),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('...');
        }
        final contact = snapshot.data;
        return Text(contact?.displayName ?? emails.firstOrNull ?? '(unknown)');
      },
    );
  }
}

class CallTile extends StatelessWidget {
  final Call call;
  const CallTile({required this.call, super.key});

  @override
  Widget build(BuildContext context) {
    final logger = context.read<LoggingService>();
    return ListTile(
      onLongPress: () {
        CallInfoDialog(context).show(call);
      },
      leading: const Icon(Icons.account_circle_rounded),
      title: ContactNameFromEmailsTile(emails: call.contactEmails),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: call.outgoing
                ? const Icon(Icons.call_made, size: 16.0)
                : const Icon(Icons.call_received, size: 16.0),
          ),
          Text(
            '${call.urgency.label()}: ',
            style: TextStyle(color: call.urgency.backgroundColor),
          ),
          Expanded(child: Text(RelativeTime(context).format(call.startTime))),
        ],
      ),
      trailing: IconButton(
        onPressed: () async {
          final activeCallService = context.read<ActiveCallService>();
          final contact = await context.read<Database>().contactForEmails(
            call.contactEmails,
          );
          final displayName = switch (contact) {
            Contact() => contact.displayName,
            null => call.contactEmails.firstOrNull ?? '(unknown)',
          };

          if (!context.mounted) {
            logger.warning(
              'Cannot open start call dialog, context is not mounted',
            );
            return;
          }

          final newCall = await StartCallDialog(context).show(
            emails: call.contactEmails,
            displayName: displayName,
            urgency: call.urgency,
          );
          if (newCall == null) return;

          activeCallService.requestOutgoingCallStart(newCall);
        },
        icon: const Icon(Icons.call),
      ),
    );
  }
}

class CallsList extends StatelessWidget {
  const CallsList({super.key});

  @override
  Widget build(BuildContext context) {
    final callsCubit = context.watch<CallsCubit>();

    if (callsCubit.state.calls.isEmpty) {
      return const Center(
        child: Text('(no calls)', style: TextStyle(color: Colors.grey)),
      );
    }

    final calls = callsCubit.state.calls.reversed.toList();
    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return CallTile(key: ValueKey('call_${call.id}'), call: call);
      },
    );
  }
}
