import 'dart:async';

import 'package:clearing_client/services/firebase/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/app/config.dart';
import '../../features/auth/bloc.dart';
import '../../features/call/call_gateway.dart';
import '../../features/call/incoming/bloc/incoming_call_bloc.dart';
import '../../features/call/model/call.dart';
import '../../features/call/model/call_event.dart';
import '../../features/call/outgoing/bloc/outgoing_call_bloc.dart';
import '../../features/settings/bloc/bloc.dart';
import '../../pages/incoming_call_page.dart';
import '../../pages/outgoing_call_page.dart';
import '../../utils/webrtc/webrtc_session.dart';
import '../logging/logging_service.dart';
import '../notifications/native.dart';
import '../storage/database.dart';

class ActiveCallService {
  final AppConfig appConfig;
  final LoggingService logger;
  final FirebaseServiceBase firebaseService;
  final Database database;
  final NativeNotifications nativeNotifications;
  final StreamController<Call> _outgoingCallStream =
      StreamController<Call>.broadcast();

  ActiveCallService({
    required this.appConfig,
    required this.logger,
    required this.firebaseService,
    required this.database,
    required this.nativeNotifications,
  });

  Stream<Call> get outgoingCallStream => _outgoingCallStream.stream;

  void requestOutgoingCallStart(Call call) {
    _outgoingCallStream.add(call);
  }

  Future<void> startOutgoingCall(
    BuildContext context, {
    required Call call,
    bool pushInsteadOfRoute = false,
    bool useWebrtc = true,
  }) async {
    useWebrtc =
        useWebrtc &&
        !context.read<AppSettingsCubit>().state.appSettings.disableWebRTC;
    try {
      final authState = context.read<AuthBloc>().state;

      if (authState is! AuthStateSignedIn) {
        throw Exception('Diagnostic call requires a signed in user');
      }

      await database.saveCall(call);

      final callBloc = await _connectAndCreateOutgoingCallBloc(
        call,
        authState.currentUser.authToken,
        useWebrtc: useWebrtc,
      );

      if (context.mounted) {
        if (pushInsteadOfRoute) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OutgoingCallPage(
                callBloc: callBloc,
                call: call,
                inScaffold: true,
              ),
            ),
          );
        } else {
          context.go(
            "/calls/outgoing_call",
            extra: (call: call, callBloc: callBloc),
          );
        }
      }
    } catch (exc, stackTrace) {
      logger.error('Failed to start outgoing call', exc, stackTrace);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed to start call'),
            content: Text('$exc\n$stackTrace'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<OutgoingCallBloc> _connectAndCreateOutgoingCallBloc(
    Call call,
    String clientTokenId, {
    required bool useWebrtc,
  }) async {
    final callGateway = await CallGatewayWebsocket.connect(
      appConfig.callEndpoint(callUuid: call.callUuid),
    );

    WebRTCSession? webrtcSession;
    if (useWebrtc) {
      webrtcSession = WebRTCSession();
    }
    final callBloc = OutgoingCallBloc(
      database: database,
      call,
      callGateway,
      logger: logger,
      webrtcSession: webrtcSession,
    );
    callBloc.add(SenderAuthorize(clientTokenId: clientTokenId));
    return callBloc;
  }

  Future<void> startIncomingCall(
    BuildContext context, {
    required Call call,
    required String sdpOffer,
    required bool useWebrtc,
    bool pushInsteadOfRoute = false,
  }) async {
    try {
      final authState = context.read<AuthBloc>().state;

      if (authState is! AuthStateSignedIn) {
        throw Exception('Diagnostic call requires a signed in user');
      }

      await database.saveCall(call);

      final callBloc = await _connectAndCreateIncomingCallBloc(
        call,
        authState.currentUser.authToken,
        sdpOffer,
        useWebrtc: useWebrtc,
      );

      if (context.mounted) {
        if (pushInsteadOfRoute) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => IncomingCallPage(
                callBloc: callBloc,
                call: call,
                inScaffold: true,
              ),
            ),
          );
        } else {
          context.go(
            "/calls/incoming_call",
            extra: (call: call, callBloc: callBloc),
          );
        }
      }
    } catch (exc, stackTrace) {
      logger.error('Failed to start incoming call', exc, stackTrace);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Failed to start call'),
            content: Text('$exc\n$stackTrace'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<IncomingCallBloc> _connectAndCreateIncomingCallBloc(
    Call call,
    String clientTokenId,
    String sdpOffer, {
    required bool useWebrtc,
  }) async {
    final callGateway = await CallGatewayWebsocket.connect(
      appConfig.answerEndpoint(callUuid: call.callUuid),
    );
    WebRTCSession? webrtcSession;
    String sdpAnswer = '';
    if (useWebrtc && sdpOffer != 'sdp-offer-mock') {
      try {
        if (sdpOffer.isEmpty) {
          throw Exception('SDP offer is empty');
        }
        call.sdpOffer = sdpOffer;
        await database.saveCall(call);
        webrtcSession = WebRTCSession();
        await webrtcSession.createPeerConnection([]);
        sdpAnswer = await webrtcSession.receiverProcessSDPOfferAndCreateAnswer(
          sdpOffer,
        );
        call.sdpAnswer = sdpAnswer;
        await database.saveCall(call);
      } catch (exc, stackTrace) {
        logger.error('Failed to create peer connection', exc, stackTrace);
        await webrtcSession?.close();
        webrtcSession = null;
      }
    }
    final callBloc = IncomingCallBloc(
      callGateway,
      call,
      logger: logger,
      webrtcSession: webrtcSession,
      database: database,
      nativeNotifications: nativeNotifications,
    );
    callBloc.add(
      ReceiverAck(clientTokenId: clientTokenId, sdpAnswer: sdpAnswer),
    );
    return callBloc;
  }
}
