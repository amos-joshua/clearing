import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/logging/logging_service.dart';
import '../../../../services/notifications/native.dart';
import '../../../../services/storage/database.dart';
import '../../../../utils/webrtc/webrtc_session.dart';
import '../../../presets/model/enums.dart';
import '../../../webrtc/bloc/bloc.dart';
import '../../model/call.dart';
import '../../model/call_event.dart';
import '../../call_gateway.dart';
import 'incoming_call_state.dart';

class IncomingCallBloc extends Bloc<CallEvent, IncomingCallState> {
  final CallGateway _callGateway;
  final Call _call;
  final LoggingService _logger;
  final NativeNotifications _nativeNotifications;
  final WebRTCSession? webrtcSession;
  final Database database;
  StreamSubscription<CallEvent>? _callEventSubscription;

  IncomingCallBloc(
    this._callGateway,
    this._call, {
    required LoggingService logger,
    required this.webrtcSession,
    required this.database,
    required NativeNotifications nativeNotifications,
  }) : _logger = logger,
       _nativeNotifications = nativeNotifications,
       super(const IncomingCallState.idle()) {
    on<ReceiverAck>(_onReceiverAck);
    on<ReceiverReject>(_onReceiverReject);
    on<ReceiverAccept>(_onReceiverAccept);
    on<SenderHangUp>(_onSenderHangUp);
    on<ReceiverHangUp>(_onReceiverHangUp);
    on<CallTimeout>(_onCallTimeout);
    on<CallError>(_onCallError);
    on<SenderIceCandidates>(_onSenderIceCandidates);
    _callEventSubscription = _callGateway.events.listen((event) async {
      _call.addLog('incoming_remote_call_event', event.runtimeType.toString());
      await database.saveCall(_call, notify: false);
      add(event);
    });
    _nativeNotifications.showCallNotification(
      _call.callUuid,
      _call.contactPhoneNumbers.first,
      _call.subject,
      _call.urgency,
      RingType.ring,
    );
  }

  @override
  Future<void> close() async {
    try {
      _callEventSubscription?.cancel();
      _callEventSubscription = null;
      await webrtcSession?.close();
    } catch (e, stackTrace) {
      _logger.error('Error during incoming call bloc cleanup', e, stackTrace);
    }
    return super.close();
  }

  // NOTE: receiver events get forwarded to the call gateway
  Future<void> _sendEvent(CallEvent event) async {
    _call.addLog('outgoing_remote_call_event', event.runtimeType.toString());
    await database.saveCall(_call, notify: false);
    _callGateway.sendEvent(event);
  }

  void _onReceiverAck(
    ReceiverAck event,
    Emitter<IncomingCallState> emit,
  ) async {
    _sendEvent(event);
    if (state is IncomingCallStateIdle) {
      emit(const IncomingCallState.ringing());
    }
  }

  void _onReceiverReject(
    ReceiverReject event,
    Emitter<IncomingCallState> emit,
  ) {
    _nativeNotifications.cancelCallNotification(_call.callUuid);
    _sendEvent(event);
    if (state is IncomingCallStateRinging) {
      emit(const IncomingCallState.rejected());
    }
  }

  void _onSenderIceCandidates(
    SenderIceCandidates event,
    Emitter<IncomingCallState> emit,
  ) {
    try {
      webrtcSession?.receiverAddRemoteIceCandidates(event.iceCandidates);
    } catch (e, stackTrace) {
      _logger.error('Failed to add remote ICE candidates', e, stackTrace);
      // Continue without WebRTC if it fails
      webrtcSession?.close();
    }
  }

  void _onReceiverAccept(
    ReceiverAccept event,
    Emitter<IncomingCallState> emit,
  ) {
    _nativeNotifications.cancelCallNotification(_call.callUuid);
    _callGateway.sendEvent(event);
    if (state is IncomingCallStateRinging) {
      final (startedAt, error) = event.parseTimestamp();
      if (error != null) {
        _logger.warning(
          '[call ${_call.callUuid}] Error parsing timestamp (defaulting to now for accept timestamp): $error',
        );
      }
      emit(IncomingCallState.ongoing(startedAt: startedAt));
    }
  }

  void _onReceiverHangUp(
    ReceiverHangUp event,
    Emitter<IncomingCallState> emit,
  ) async {
    _nativeNotifications.cancelCallNotification(_call.callUuid);
    _callGateway.sendEvent(event);
    if (state is IncomingCallStateRinging ||
        state is IncomingCallStateOngoing) {
      try {
        await webrtcSession?.close();
      } catch (e, stackTrace) {
        _logger.error('Error closing WebRTC session during receiver hang up', e, stackTrace);
      }
      emit(const IncomingCallState.ended());
    }
  }

  void _onSenderHangUp(
    SenderHangUp event,
    Emitter<IncomingCallState> emit,
  ) async {
    _nativeNotifications.cancelCallNotification(_call.callUuid);
    if (state is IncomingCallStateRinging ||
        state is IncomingCallStateOngoing) {
      try {
        await webrtcSession?.close();
      } catch (e, stackTrace) {
        _logger.error('Error closing WebRTC session during sender hang up', e, stackTrace);
      }
      emit(const IncomingCallState.ended());
    }
  }

  void _onCallTimeout(CallTimeout event, Emitter<IncomingCallState> emit) {
    _nativeNotifications.cancelCallNotification(_call.callUuid);
    if (state is IncomingCallStateRinging) {
      emit(const IncomingCallState.unanswered());
    }
  }

  void _onCallError(CallError event, Emitter<IncomingCallState> emit) {
    _nativeNotifications.cancelCallNotification(_call.callUuid);
    if (state is IncomingCallStateRinging ||
        state is IncomingCallStateOngoing) {
      emit(IncomingCallState.ended(error: event.errorMessage));
    }
  }

  static provider({
    required Call call,
    required IncomingCallBloc callBloc,
    required Widget child,
    required Database database,
    required LoggingService logger,
    required WebRTCSession? webrtcSession,
  }) => RepositoryProvider.value(
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
        child: BlocListener<IncomingCallBloc, IncomingCallState>(
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
