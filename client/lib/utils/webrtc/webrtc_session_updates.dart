import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

sealed class WebRTCSessionEvent {
  const WebRTCSessionEvent();
}

class WebRTCSessionEventPeerConnectionState extends WebRTCSessionEvent {
  final String state;
  const WebRTCSessionEventPeerConnectionState(this.state);
}

class WebRTCSessionEventIceConnectionState extends WebRTCSessionEvent {
  final String state;
  const WebRTCSessionEventIceConnectionState(this.state);
}

class WebRTCSessionEventIceGatheringState extends WebRTCSessionEvent {
  final String state;
  const WebRTCSessionEventIceGatheringState(this.state);
}

class WebRTCSessionEventSignalingState extends WebRTCSessionEvent {
  final String state;
  const WebRTCSessionEventSignalingState(this.state);
}

class WebRTCSessionEventAddPeerTrack extends WebRTCSessionEvent {
  final webrtc.MediaStreamTrack track;
  const WebRTCSessionEventAddPeerTrack(this.track);
}

class WebRTCSessionEventGenerateIceCandidates extends WebRTCSessionEvent {
  final List<webrtc.RTCIceCandidate> iceCandidates;
  const WebRTCSessionEventGenerateIceCandidates(this.iceCandidates);
}

class WebRTCSessionEventReceiveRemoteIceCandidates extends WebRTCSessionEvent {
  final List<webrtc.RTCIceCandidate> iceCandidates;
  const WebRTCSessionEventReceiveRemoteIceCandidates(this.iceCandidates);
}

class WebRTCSessionEventAddLocalStreamTrack extends WebRTCSessionEvent {
  final webrtc.MediaStream stream;
  const WebRTCSessionEventAddLocalStreamTrack(this.stream);
}

class WebRTCSessionEventSDPOffer extends WebRTCSessionEvent {
  final String sdpOffer;
  const WebRTCSessionEventSDPOffer(this.sdpOffer);
}

class WebRTCSessionEventSDPAnswer extends WebRTCSessionEvent {
  final String sdpAnswer;
  const WebRTCSessionEventSDPAnswer(this.sdpAnswer);
}