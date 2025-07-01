import 'package:clearing_client/features/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/call/model/call_event.dart';
import '../features/call/outgoing/bloc/outgoing_call_bloc.dart';
import '../features/call/outgoing/outgoing_call_widget.dart';
import '../services/logging/logging_service.dart';
import '../services/storage/database.dart';

class OutgoingCallPage extends StatelessWidget {
  final bool inScaffold;
  const OutgoingCallPage({
    super.key,
    required this.callBloc,
    required this.call,
    required this.inScaffold,
  });

  final Call call;
  final OutgoingCallBloc callBloc;

  @override
  Widget build(BuildContext context) {
    return OutgoingCallBloc.provider(
      call: call,
      callBloc: callBloc,
      database: context.read<Database>(),
      logger: context.read<LoggingService>(),
      webrtcSession: callBloc.webrtcSession,
      child: Builder(
        builder: (context) => _scaffold(
          context,
          child: const OutgoingCallWidget(),
          withAppBar: inScaffold,
        ),
      ),
    );
  }

  Widget _scaffold(
    BuildContext context, {
    required Widget child,
    required bool withAppBar,
  }) => Scaffold(
    appBar: withAppBar
        ? AppBar(
            title: const Text('Outgoing Call'),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<OutgoingCallBloc>().add(const SenderHangUp());
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          )
        : null,
    body: child,
  );
}
