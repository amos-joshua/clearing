import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/call/model/call.dart';
import '../features/call/model/call_event.dart';
import '../features/call/incoming/bloc/incoming_call_bloc.dart';
import '../features/call/incoming/incoming_call_widget.dart';
import '../services/storage/database.dart';

class IncomingCallPage extends StatelessWidget {
  const IncomingCallPage({
    super.key,
    required this.callBloc,
    required this.call,
    required this.inScaffold,
  });

  final Call call;
  final bool inScaffold;
  final IncomingCallBloc callBloc;

  @override
  Widget build(BuildContext context) {
    return IncomingCallBloc.provider(
      call: call,
      callBloc: callBloc,
      database: context.read<Database>(),
      child: Builder(
        builder: (context) => _scaffold(
          context,
          child: const IncomingCallWidget(),
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
            title: const Text('Incoming Call'),
            actions: [
              IconButton(
                onPressed: () {
                  context.read<IncomingCallBloc>().add(const ReceiverHangUp());
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
