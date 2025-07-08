import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../services/active_call/active_call.dart';
import '../../../../services/firebase/service.dart';
import '../../../../services/logging/logging_service.dart';
import '../../../../services/storage/database.dart';
import '../../../settings/bloc/bloc.dart';
import '../../model/call.dart';
import '../../model/call_event.dart';

class CallStarter extends StatefulWidget {
  const CallStarter({super.key, required this.child});

  final Widget child;

  @override
  State<CallStarter> createState() => _CallStarterState();
}

class _CallStarterState extends State<CallStarter> {
  late final LoggingService logger;
  late final ActiveCallService activeCallService;
  late final Database database;
  StreamSubscription<Call>? _callStreamSubscription;
  StreamSubscription<FirebaseRemoteMessage>? _firebaseMessageSubscription;

  @override
  void initState() {
    super.initState();
    logger = context.read<LoggingService>();
    activeCallService = context.read<ActiveCallService>();
    database = context.read<Database>();
    final firebaseService = context.read<FirebaseServiceBase>();
    _firebaseMessageSubscription = firebaseService.firebaseMessageStream.listen(
      processFirebaseMessage,
    );
    _callStreamSubscription = activeCallService.outgoingCallStream.listen(
      processOutgoingCall,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void processOutgoingCall(Call call) {
    final context = this.context;
    if (context.mounted) {
      activeCallService.startOutgoingCall(context, call: call, useWebrtc: true);
    }
  }

  void processFirebaseMessage(FirebaseRemoteMessage message) async {
    final event = message.callEvent;
    if (event is IncomingCallInit) {
      final context = this.context;
      final enableServersideDebug = context.read<AppSettingsCubit>().state.appSettings.enableServersideDebug;
      final contact = await database.contactForPhoneNumbers([event.callerPhoneNumber]);


      if (context.mounted) {
        final call = Call(
          outgoing: false,
          callUuid: event.callUuid,
          contactPhoneNumbers: [event.callerPhoneNumber],
          urgency: event.urgency,
          subject: event.subject,
          startTime: DateTime.now(),
        );
        call.contact.target = contact;
        activeCallService.startIncomingCall(
          context,
          call: call,
          sdpOffer: event.sdpOffer,
          turnServers: event.turnServers,
          useWebrtc: true,
          enableServersideDebug: enableServersideDebug,
        );
      } else {
        logger.warning(
          'Received incoming call init event but context is not mounted',
        );
      }
    } else {
      logger.warning(
        'Received unexpected call event from firebase, expected IncomingCallInit but got: ${message.callEvent}',
      );
    }
  }

  @override
  void dispose() {
    _callStreamSubscription?.cancel();
    _callStreamSubscription = null;
    _firebaseMessageSubscription?.cancel();
    _firebaseMessageSubscription = null;
    super.dispose();
  }
}
