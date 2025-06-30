import 'package:clearing_client/features/call_composer/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/call/bloc/widgets.dart';
import '../features/call/call_urgency_colors.dart';
import '../features/call/model/call.dart';
import '../features/call/model/call_event.dart';
import '../features/contacts/bloc/cubit.dart';
import '../features/contacts/model/contact.dart';
import '../features/contacts/widgets/list_with_filter.dart';
import '../features/settings/bloc/bloc.dart';
import '../repositories/contacts/all.dart';
import '../services/storage/database.dart';
import '../utils/json.dart';

class AlertMessageDialog {
  final BuildContext context;
  AlertMessageDialog(this.context);

  Future<void> show({required String title, String? message}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message ?? ''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}

class PromptDialog {
  final BuildContext context;
  PromptDialog(this.context);

  Future<String?> show({
    required String title,
    Future<String?> Function(String)? validator,
    String? value,
  }) {
    final textFieldController = TextEditingController(text: value ?? '');
    final validate = validator ?? (value) => Future.value(null);
    final errorMessage = ValueNotifier<String?>(null);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: ValueListenableBuilder(
          valueListenable: errorMessage,
          builder: (context, errMsg, tree) => TextField(
            controller: textFieldController,
            decoration: InputDecoration(errorText: errMsg),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final value = textFieldController.text;
              final err = await validate(value);
              if (err != null) {
                errorMessage.value = err;
              } else if (context.mounted) {
                Navigator.of(context).pop(value);
              }
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}

class SelectContactsDialog {
  final BuildContext context;
  SelectContactsDialog(this.context);

  Future<List<Contact>?> show(
    List<Contact> selected, {
    bool singleChoice = false,
  }) {
    final contactsRepository = context.read<AllContactsRepository>();
    final contactsCubit = ContactsCubit(contactsRepository: contactsRepository);
    for (final contact in selected) {
      contactsCubit.toggleSelection(contact);
    }

    return showDialog<List<Contact>>(
      context: context,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);

        return AlertDialog(
          title: singleChoice
              ? const Text('Select contact...')
              : const Text('Select contacts...'),
          content: SizedBox(
            height: mediaQuery.size.height,
            width: mediaQuery.size.width,
            child: BlocProvider.value(
              value: contactsCubit,
              child: ContactsListWithFilter(
                allowSelection: true,
                onSelect: singleChoice
                    ? (contact) => Navigator.of(context).pop([contact])
                    : null,
              ),
            ),
          ),
          actionsAlignment: singleChoice
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            if (!singleChoice)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(contactsCubit.state.selected);
                },
                child: const Text('Ok'),
              ),
          ],
        );
      },
    );
  }
}

class ConfirmDialog {
  final BuildContext context;
  ConfirmDialog(this.context);

  Future<bool> show({required String title, String? message}) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message ?? ''),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }
}

class DurationSelectDialog {
  final BuildContext context;
  DurationSelectDialog(this.context);

  DropdownMenuItem<Duration> _option(int minutes, String label) =>
      DropdownMenuItem(
        value: Duration(minutes: minutes),
        child: Text(label),
      );

  Future<Duration?> show({required String title, String? message}) {
    final durationNotifier = ValueNotifier(const Duration(hours: 1));

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: ValueListenableBuilder(
          valueListenable: durationNotifier,
          builder: (context, duration, tree) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message ?? ''),
              DropdownButton(
                value: duration,
                items: [
                  _option(5, '5 Minutes'),
                  _option(10, '10 minutes'),
                  _option(15, '15 minutes'),
                  _option(30, '30 minutes'),
                  _option(45, '45 minutes'),
                  _option(60, '1 hour'),
                  _option(90, '1.5 hours'),
                  _option(120, '2 hours'),
                  _option(180, '3 hours'),
                ].toList(growable: false),
                onChanged: (newValue) {
                  if (newValue != null) {
                    durationNotifier.value = newValue;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(durationNotifier.value);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}

class StartCallDialog {
  final BuildContext context;
  StartCallDialog(this.context);

  Future<Call?> show({
    required List<String> emails,
    required String displayName,
    CallUrgency? urgency,
  }) async {
    //final currentCallCubit = context.read<CurrentCallCubit>();
    if (emails.isEmpty) {
      AlertMessageDialog(context).show(
        title: 'Cannot call $displayName',
        message: 'The contact has no email address',
      );
      return null;
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call $displayName'),
        content: BlocProvider(
          create: (context) => CallComposerBloc(
            database: context.read<Database>(),
            emails: emails,
            displayName: displayName,
            urgency: urgency,
          ),
          child: CallConfigurationPane(
            onCall: (call) {
              Navigator.of(context).pop(call);
            },
          ),
        ),
        actions: const [],
      ),
    );
  }

  Future<Call?> showForContact(Contact contact) async {
    final call = await show(
      emails: contact.emails,
      displayName: contact.displayName,
    );
    call?.contact.target = contact;
    return call;
  }
}

class CallInfoDialog {
  final BuildContext context;
  CallInfoDialog(this.context);

  Future<void> show(Call call) async {
    final appSettings = context.read<AppSettingsCubit>();
    final database = context.read<Database>();
    final duration = call.endTime?.difference(call.startTime);
    final isDeveloperMode = appSettings.state.appSettings.isDeveloper;

    final refreshedCall = database.refetchCall(call);
    if (refreshedCall != null) {
      call = refreshedCall;
    }
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                call.outgoing ? 'Recipients:' : 'Caller:',
                call.contactEmails.join(', '),
              ),
              _InfoRow('Status:', call.state),
              _InfoRow('Urgency:', call.urgency.label()),
              if (call.subject.isNotEmpty) _InfoRow('Subject:', call.subject),
              _InfoRow('Start Time:', _formatDateTime(call.startTime)),
              if (call.endTime != null)
                _InfoRow('End Time:', _formatDateTime(call.endTime!)),
              if (duration != null)
                _InfoRow('Duration:', _formatDuration(duration)),
              _InfoRow('Direction:', call.outgoing ? 'Outgoing' : 'Incoming'),
              if (isDeveloperMode) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Debug Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _SDPExpansionTile(title: 'SDP Offer', sdpData: call.sdpOffer),
                _SDPExpansionTile(title: 'SDP Answer', sdpData: call.sdpAnswer),
                _InfoRow(
                  'WebRTC Peer Connection State:',
                  call.webRTCPeerConnectionState,
                ),
                _InfoRow(
                  'WebRTC ICE Connection State:',
                  call.webRTCIceConnectionState,
                ),
                _InfoRow(
                  'WebRTC ICE Gathering State:',
                  call.webRTCIceGatheringState,
                ),
                _InfoRow('WebRTC Signaling State:', call.webRTCSignalingState),
                const SizedBox(height: 16),
                _LogsExpansionTile(logs: call.logEntries),
              ],
            ],
          ),
        ),
        actions: [
          if (isDeveloperMode)
            TextButton(
              onPressed: () => _copyDebugInfo(call, duration),
              child: const Text('Copy Debug Info'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _copyDebugInfo(Call call, Duration? duration) {
    final debugInfo = StringBuffer();
    debugInfo.writeln('Call Information');
    debugInfo.writeln('===============');
    debugInfo.writeln('contactEmails: ${call.contactEmails.join(', ')}');
    debugInfo.writeln('Status: ${call.state}');
    debugInfo.writeln('Urgency: ${call.urgency.label()}');
    if (call.subject.isNotEmpty) debugInfo.writeln('Subject: ${call.subject}');
    debugInfo.writeln('Start Time: ${_formatDateTime(call.startTime)}');
    if (call.endTime != null)
      debugInfo.writeln('End Time: ${_formatDateTime(call.endTime!)}');
    if (duration != null)
      debugInfo.writeln('Duration: ${_formatDuration(duration)}');
    debugInfo.writeln('Direction: ${call.outgoing ? 'Outgoing' : 'Incoming'}');

    debugInfo.writeln('\nDebug Information');
    debugInfo.writeln('=================');
    if (call.sdpOffer.isNotEmpty) {
      debugInfo.writeln('\nSDP Offer:');
      try {
        final decodedSdp = JsonUtils.unBase64AndGzip(call.sdpOffer);
        final sortedKeys = decodedSdp.keys.toList()..sort();
        for (final key in sortedKeys) {
          debugInfo.writeln('  $key: ${decodedSdp[key]}');
        }
      } catch (e) {
        debugInfo.writeln('  Error decoding SDP offer: $e');
      }
    }

    if (call.sdpAnswer.isNotEmpty) {
      debugInfo.writeln('\nSDP Answer:');
      try {
        final decodedSdp = JsonUtils.unBase64AndGzip(call.sdpAnswer);
        final sortedKeys = decodedSdp.keys.toList()..sort();
        for (final key in sortedKeys) {
          debugInfo.writeln('  $key: ${decodedSdp[key]}');
        }
      } catch (e) {
        debugInfo.writeln('  Error decoding SDP answer: $e');
      }
    }

    if (call.webRTCPeerConnectionState.isNotEmpty) {
      debugInfo.writeln(
        'WebRTC Peer Connection State: ${call.webRTCPeerConnectionState}',
      );
    }
    if (call.webRTCIceConnectionState.isNotEmpty) {
      debugInfo.writeln(
        'WebRTC ICE Connection State: ${call.webRTCIceConnectionState}',
      );
    }
    if (call.webRTCIceGatheringState.isNotEmpty) {
      debugInfo.writeln(
        'WebRTC ICE Gathering State: ${call.webRTCIceGatheringState}',
      );
    }
    if (call.webRTCSignalingState.isNotEmpty) {
      debugInfo.writeln('WebRTC Signaling State: ${call.webRTCSignalingState}');
    }

    if (call.logEntries.isNotEmpty) {
      debugInfo.writeln('\nLogs:');
      for (final logEntry in call.logEntries) {
        debugInfo.writeln('  ${logEntry.render()}');
      }
    }

    Clipboard.setData(ClipboardData(text: debugInfo.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Debug information copied to clipboard')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _SDPExpansionTile extends StatelessWidget {
  final String title;
  final String sdpData;

  const _SDPExpansionTile({required this.title, required this.sdpData});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? decodedSdp;
    String? errorMessage;

    try {
      decodedSdp = JsonUtils.unBase64AndGzip(sdpData);
    } catch (e) {
      errorMessage = 'Error decoding SDP: $e';
    }

    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage != null)
                Text(errorMessage, style: const TextStyle(color: Colors.red))
              else if (decodedSdp != null) ...[
                ...(() {
                  final sortedKeys = decodedSdp!.keys.toList()..sort();
                  return sortedKeys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              '$key:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              decodedSdp![key].toString(),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LogsExpansionTile extends StatelessWidget {
  final List<LogEntry> logs;

  const _LogsExpansionTile({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Logs'),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: logs
                .map(
                  (logEntry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                    child: Text(
                      logEntry.render(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
