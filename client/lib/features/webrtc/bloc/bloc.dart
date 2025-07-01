import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/logging/logging_service.dart';
import '../../../services/storage/database.dart';
import '../../../utils/webrtc/webrtc_session.dart';
import '../../../utils/webrtc/webrtc_session_updates.dart';
import '../../call/model/call.dart';
import 'state.dart';

class WebRTCSessionBloc extends Bloc<WebRTCSessionEvent, WebRTCSessionState> {
  final Database _database;
  final Call _call;
  final WebRTCSession? _webrtcSession;
  final LoggingService _logger;

  StreamSubscription<WebRTCSessionEvent>? _eventSubscription;

  WebRTCSessionBloc(this._call, {required Database database, required LoggingService logger, required WebRTCSession? webrtcSession}) : _database = database, _logger = logger, _webrtcSession = webrtcSession, super(WebRTCSessionState(call: _call, nonce: 0)) {
    on<WebRTCSessionEventPeerConnectionState>(_handleEvent);
    on<WebRTCSessionEventIceConnectionState>(_handleEvent);
    on<WebRTCSessionEventIceGatheringState>(_handleEvent);
    on<WebRTCSessionEventSignalingState>(_handleEvent);
    on<WebRTCSessionEventSDPOffer>(_handleEvent);
    on<WebRTCSessionEventSDPAnswer>(_handleEvent);
    on<WebRTCSessionEventGenerateIceCandidates>(_handleEvent);

    _eventSubscription = _webrtcSession?.stateStream.listen((event) {
      add(event);
    });
  }

  void _handleEvent(WebRTCSessionEvent event, Emitter<WebRTCSessionState> emit) {

    switch (event) {
      case WebRTCSessionEventPeerConnectionState():
        _call.webRTCPeerConnectionState = event.state;
        _call.addLog('peer_connection_state', 'State: ${event.state}');

      case WebRTCSessionEventIceConnectionState():
        _call.webRTCIceConnectionState = event.state;
        _call.addLog('ice_connection_state', 'State: ${event.state}');

      case WebRTCSessionEventIceGatheringState():
        _call.webRTCIceGatheringState = event.state;
        _call.addLog('ice_gathering_state', 'State: ${event.state}');

      case WebRTCSessionEventSignalingState():
        _call.webRTCSignalingState = event.state;
        _call.addLog('signaling_state', 'State: ${event.state}');

      case WebRTCSessionEventSDPOffer():
        _call.sdpOffer = event.sdpOffer;
        _call.addLog('sdp_offer', 'SDP offer received');

      case WebRTCSessionEventSDPAnswer():
        _call.sdpAnswer = event.sdpAnswer;
        _call.addLog('sdp_answer', 'SDP answer received');

      case WebRTCSessionEventGenerateIceCandidates():
        _call.addLog('generate_ice_candidates',
            'Generated ${event.iceCandidates.length} ICE candidates');

      case WebRTCSessionEventReceiveRemoteIceCandidates():
        _call.addLog('receive_remote_ice_candidates',
            'Received ${event.iceCandidates.length} remote ICE candidates');

      case WebRTCSessionEventAddPeerTrack():
        final trackType = event.track.kind;
        final description =
            'id: ${event.track.id}, kind: $trackType, label: ${event.track.label}, enabled: ${event.track.enabled}, muted: ${event.track.muted}';
        _call.addLog('add_peer_track', 'Added peer track: $description');

      case WebRTCSessionEventAddLocalStreamTrack():
        final description =
            'id: ${event.stream.id}, ownerTag: ${event.stream.ownerTag}, active: ${event.stream.active}, #audioTracks: ${event.stream.getAudioTracks().length}, #videoTracks: ${event.stream.getVideoTracks().length}';
        _call.addLog('add_local_stream_track', 'Added local stream: $description');
    }
    _saveCall();
    emit(state.copyWith(call: _call, nonce: state.nonce + 1));
  }

  Future<void> _saveCall() async {
    try {
      await _database.saveCall(_call, notify: false);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to save call after WebRTC event update',
        e,
        stackTrace,
      );
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
  }
}