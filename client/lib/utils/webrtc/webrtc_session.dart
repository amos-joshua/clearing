import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '../../services/logging/logging_service.dart';
import '../json.dart';
import 'webrtc_session_updates.dart';

class WebRTCSession {
  webrtc.RTCPeerConnection? peerConnection;
  webrtc.MediaStream? localStream;
  final iceCandidates = <webrtc.RTCIceCandidate>[];
  final LoggingService loggingService;

  WebRTCSession({required this.loggingService});

  void Function(String)? onIceCandidate;
  final _stateStreamController =
      StreamController<WebRTCSessionEvent>.broadcast();
  Stream<WebRTCSessionEvent> get stateStream => _stateStreamController.stream;
  List<webrtc.MediaDeviceInfo> mediaDevices = [];

  Future<void> createPeerConnection(
    List<Map<String, dynamic>> turnServers,
  ) async {
    final sessionLocalStream = await webrtc.navigator.mediaDevices.getUserMedia(
      {
        'audio': true,
        'video': false, //{'facingMode': 'user'}
      },
    );


    List validTurnServers = [];
    for (final server in turnServers) {
      if (server['urls'].every(
        (url) => url.startsWith('stun:') || url.startsWith('turn:'),
      )) {
        validTurnServers.add(server);
      } else {
        loggingService.warning('Ignoring invalid turn server: $server');
      }
    }

    if (validTurnServers.isEmpty) {
      throw 'No valid turn servers found';
    }
    
    final currentPeerConnection = await webrtc.createPeerConnection({
      'iceServers': validTurnServers,
    });

    currentPeerConnection.onTrack = (event) {
      _stateStreamController.add(WebRTCSessionEventAddPeerTrack(event.track));
    };

    currentPeerConnection.onConnectionState = (state) {
      _stateStreamController.add(
        WebRTCSessionEventPeerConnectionState(state.name),
      );
    };

    currentPeerConnection.onIceConnectionState = (state) {
      _stateStreamController.add(
        WebRTCSessionEventIceConnectionState(state.name),
      );
    };

    currentPeerConnection.onIceGatheringState = (state) {
      _stateStreamController.add(
        WebRTCSessionEventIceGatheringState(state.name),
      );
    };

    currentPeerConnection.onSignalingState = (state) {
      _stateStreamController.add(WebRTCSessionEventSignalingState(state.name));
    };

    final availableDevices = await webrtc.navigator.mediaDevices
        .enumerateDevices();
    mediaDevices.addAll(
      availableDevices.where((device) => device.kind == 'audioinput'),
    );
    if (mediaDevices.isEmpty) {
      throw 'No audio input devices found';
    }

    currentPeerConnection.onIceCandidate = (iceCandidate) {
      final callback = onIceCandidate;
      if (callback != null) {
        callback(JsonUtils.base64AndGzip(iceCandidate.toMap()));
      } else {
        iceCandidates.add(iceCandidate);
      }
    };
    peerConnection = currentPeerConnection;

    if (peerConnection == null) {
      throw 'No connection to peer';
    }

    sessionLocalStream.getTracks().forEach((track) {
      _stateStreamController.add(
        WebRTCSessionEventAddLocalStreamTrack(sessionLocalStream),
      );
      currentPeerConnection.addTrack(track, sessionLocalStream);
    });
    localStream = sessionLocalStream;
  }

  Future<String> senderCreateSDPOffer() async {
    final currentPeerConnection = peerConnection;
    if (currentPeerConnection == null) {
      throw 'Error creating SDP Offer, current RTC peer connection is null';
    }

    final offer = await currentPeerConnection.createOffer();
    currentPeerConnection.setLocalDescription(offer);

    final sdpOffer = JsonUtils.base64AndGzip(offer.toMap());
    _stateStreamController.add(WebRTCSessionEventSDPOffer(sdpOffer));
    return sdpOffer;
  }

  Future<String> receiverProcessSDPOfferAndCreateAnswer(String sdpOffer) async {
    final sdpOfferMap = JsonUtils.unBase64AndGzip(sdpOffer);
    _stateStreamController.add(WebRTCSessionEventSDPOffer(sdpOffer));

    final currentPeerConnection = peerConnection;
    if (currentPeerConnection == null) {
      throw 'peer connection is unexpectedly null while receiving SDP offer';
    }

    await currentPeerConnection.setRemoteDescription(
      webrtc.RTCSessionDescription(sdpOfferMap["sdp"], sdpOfferMap["type"]),
    );

    final sdpAnswer = await currentPeerConnection.createAnswer();
    currentPeerConnection.setLocalDescription(sdpAnswer);

    final sdpAnswerString = JsonUtils.base64AndGzip(sdpAnswer.toMap());
    _stateStreamController.add(WebRTCSessionEventSDPAnswer(sdpAnswerString));

    return sdpAnswerString;
  }

  List<String> senderGetIceCandidates() {
    _stateStreamController.add(
      WebRTCSessionEventGenerateIceCandidates(iceCandidates),
    );

    final currentIceCandidates = iceCandidates
        .map((candidate) => JsonUtils.base64AndGzip(candidate.toMap()))
        .toList(growable: false);

    iceCandidates.clear();

    return currentIceCandidates;
  }

  void senderProcessSDPAnswer(String base64SDPAnswer) {
    final currentPeerConnection = peerConnection;
    if (currentPeerConnection == null) {
      throw 'peer connection is unexpectedly null while processing SDP answer';
    }

    _stateStreamController.add(WebRTCSessionEventSDPAnswer(base64SDPAnswer));

    final sdpAnswer = JsonUtils.unBase64AndGzip(base64SDPAnswer);
    currentPeerConnection.setRemoteDescription(
      webrtc.RTCSessionDescription(sdpAnswer['sdp'], sdpAnswer['type']),
    );
  }

  void receiverAddRemoteIceCandidates(List<String> candidatesBase64) {
    final currentPeerConnection = peerConnection;
    if (currentPeerConnection == null) {
      throw 'peer connection is unexpectedly null while receiving remote ice candidates';
    }

    final List<webrtc.RTCIceCandidate> remoteIceCandidates = [];

    for (final candidateBase64 in candidatesBase64) {
      final candidate = JsonUtils.unBase64AndGzip(candidateBase64);
      final iceCandidate = webrtc.RTCIceCandidate(
        candidate["candidate"],
        candidate["sdpMid"],
        candidate["sdpMLineIndex"],
      );
      remoteIceCandidates.add(iceCandidate);
      currentPeerConnection.addCandidate(iceCandidate);
    }

    _stateStreamController.add(
      WebRTCSessionEventReceiveRemoteIceCandidates(remoteIceCandidates),
    );
  }

  Future<void> close() async {
    /*for (var stream in peerConnectionStreams) {
      stream.dispose();
    }
    peerConnectionStreams.clear();*/
    await peerConnection?.close();
    peerConnection = null;
    localStream?.dispose();
    localStream = null;
    iceCandidates.clear();
  }

  void signalCallAudioProblem() {
    _stateStreamController.add(
      WebRTCSessionEventPeerConnectionState(
        webrtc.RTCPeerConnectionState.RTCPeerConnectionStateFailed.name,
      ),
    );
  }
}
