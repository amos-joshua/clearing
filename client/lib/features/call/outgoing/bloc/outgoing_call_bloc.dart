import 'dart:async';

import 'package:clearing_client/features/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/logging/logging_service.dart';
import '../../../../services/storage/database.dart';
import '../../../../utils/webrtc/webrtc_session.dart';
import '../../../webrtc/bloc/bloc.dart';
import '../../model/call_event.dart';
import '../../call_gateway.dart';
import 'outgoing_call_state.dart';

class OutgoingCallBloc extends Bloc<CallEvent, OutgoingCallState> {
  final Call _call;
  final CallGateway _callGateway;
  final LoggingService _logger;
  final WebRTCSession? webrtcSession;
  final Database _database;
  StreamSubscription<CallEvent>? _subscription;

  OutgoingCallBloc(
    this._call,
    this._callGateway, {
    required LoggingService logger,
    required this.webrtcSession,
    required Database database,
  }) : _logger = logger,
       _database = database,
       super(const OutgoingCallState.idle()) {
    on<SenderAuthorize>(_onSenderAuthorize);
    on<TurnServers>(_onTurnServers);
    on<SenderCallInit>(_onSenderCallInit);
    on<SenderHangUp>(_onSenderHangUp);
    on<ReceiverAck>(_onReceiverAck);
    on<ReceiverReject>(_onReceiverReject);
    on<ReceiverAccept>(_onReceiverAccept);
    on<ReceiverHangUp>(_onReceiverHangUp);
    on<CallTimeout>(_onCallTimeout);
    on<CallError>(_onCallError);

    _subscription = _callGateway.events.listen((event) async {
      _call.addLog('incoming_remote_call_event', event.runtimeType.toString());
      await _database.saveCall(_call, notify: false);
      add(event);
    });
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await webrtcSession?.close();
    return super.close();
  }

  // NOTE: sender events get forwarded to the call gateway
  Future<void> _sendEvent(CallEvent event) async {
    _call.addLog('outgoing_remote_call_event', event.runtimeType.toString());
    await _database.saveCall(_call, notify: false);
    _callGateway.sendEvent(event);
  }

  void _onSenderAuthorize(
    SenderAuthorize event,
    Emitter<OutgoingCallState> emit,
  ) {
    _sendEvent(event);
  }

  void _onTurnServers(
    TurnServers event,
    Emitter<OutgoingCallState> emit,
  ) async {
    final webrtcSession = this.webrtcSession;
    String sdpOffer = '';
    if (webrtcSession != null) {
      await webrtcSession.createPeerConnection(event.turnServers);
      sdpOffer = await webrtcSession.senderCreateSDPOffer();
    }
    add(
      SenderCallInit(
        receiverEmails: _call.contactEmails,
        urgency: _call.urgency,
        subject: _call.subject,
        sdpOffer: sdpOffer,
      ),
    );
    emit(OutgoingCallState.authorized());
  }

  void _onSenderCallInit(
    SenderCallInit event,
    Emitter<OutgoingCallState> emit,
  ) {
    _call.subject = event.subject;
    _call.urgency = event.urgency;
    _call.contactEmails = event.receiverEmails;
    _sendEvent(event);
    emit(const OutgoingCallState.calling());
  }

  void _onSenderHangUp(
    SenderHangUp event,
    Emitter<OutgoingCallState> emit,
  ) async {
    _sendEvent(event);
    await webrtcSession?.close();
    emit(const OutgoingCallState.ended());
  }

  void _onReceiverAck(
    ReceiverAck event,
    Emitter<OutgoingCallState> emit,
  ) async {
    final webrtcSession = this.webrtcSession;
    if (webrtcSession != null) {
      _call.sdpAnswer = event.sdpAnswer;
      await _database.saveCall(_call);
      _sendBufferedIceCandidatesAndSwitchToStreaming(webrtcSession);
    }
    if (state is OutgoingCallStateCalling) {
      emit(const OutgoingCallState.ringing());
    }
  }

  void _onReceiverReject(
    ReceiverReject event,
    Emitter<OutgoingCallState> emit,
  ) {
    if (state is OutgoingCallStateCalling ||
        state is OutgoingCallStateRinging) {
      emit(const OutgoingCallState.rejected());
    }
  }

  void _onReceiverAccept(
    ReceiverAccept event,
    Emitter<OutgoingCallState> emit,
  ) {
    final webrtcSession = this.webrtcSession;
    if (webrtcSession != null) {
      webrtcSession.senderProcessSDPAnswer(_call.sdpAnswer);
    }
    if (state is OutgoingCallStateRinging) {
      final (startedAt, error) = event.parseTimestamp();
      if (error != null) {
        _logger.warning(
          '[call ${_call.callUuid}] Error parsing timestamp (defaulting to now for accept timestamp): $error',
          error,
        );
      }
      emit(OutgoingCallState.ongoing(startedAt: startedAt));
    }
  }

  void _onReceiverHangUp(
    ReceiverHangUp event,
    Emitter<OutgoingCallState> emit,
  ) async {
    if (state is OutgoingCallStateOngoing) {
      _logger.info('Call ended by receiver');
      await webrtcSession?.close();
      emit(const OutgoingCallState.ended());
    }
  }

  void _onCallTimeout(CallTimeout event, Emitter<OutgoingCallState> emit) {
    if (state is OutgoingCallStateCalling ||
        state is OutgoingCallStateRinging) {
      _logger.warning('Call timed out');
      emit(const OutgoingCallState.unanswered());
    }
  }

  void _onCallError(CallError event, Emitter<OutgoingCallState> emit) {
    if (state is OutgoingCallStateCalling ||
        state is OutgoingCallStateRinging) {
      _logger.error('Call error: ${event.errorCode}', null, StackTrace.current);
      emit(
        OutgoingCallState.ended(
          error: "${event.errorCode}: ${event.errorMessage}",
        ),
      );
    }
  }

  void _sendBufferedIceCandidatesAndSwitchToStreaming(
    WebRTCSession webrtcSession,
  ) {
    final iceCandidates = webrtcSession.senderGetIceCandidates();
    webrtcSession.onIceCandidate = (iceCandidate) {
      _sendEvent(SenderIceCandidates(iceCandidates: [iceCandidate]));
    };
    _sendEvent(SenderIceCandidates(iceCandidates: iceCandidates));
  }

  static provider({
    required Call call,
    required OutgoingCallBloc callBloc,
    required Widget child,
    required Database database,
    required LoggingService logger,
    required WebRTCSession? webrtcSession,
  }) {
    return RepositoryProvider.value(
      value: call,
      child: BlocProvider(
        create: (context) => WebRTCSessionBloc(
          call,
          database: database,
          logger: logger,
          webrtcSession: webrtcSession,
        ),
        child: BlocProvider.value(
          value: callBloc,
          child: BlocListener<OutgoingCallBloc, OutgoingCallState>(
            listener: (context, state) async {
              call.state = state.runtimeType.toString();
              await database.saveCall(call, notify: false);
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
