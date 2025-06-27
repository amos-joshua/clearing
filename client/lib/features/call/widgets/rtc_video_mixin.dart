import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../../utils/webrtc/webrtc_session.dart';

mixin RtcVideoMixin {
  RTCVideoRenderer? remoteRtc;
  RTCVideoRenderer? localRtc;

  void startWebRTC(WebRTCSession webrtcSession) async {
    remoteRtc = RTCVideoRenderer();
    localRtc = RTCVideoRenderer();

    await remoteRtc?.initialize();
    await localRtc?.initialize();

    final localStream = webrtcSession.localStream;
    if (localStream != null) {
      localRtc?.srcObject = localStream;

      /*
      for (final track in localStream.getAudioTracks()) {
        webrtcSession.peerConnection?.addTrack(track, localStream);
      }*/
    }

    // NOTE: sanity check
    Future.delayed(const Duration(seconds: 1), () {
      final stream = remoteRtc?.srcObject;
      if (stream == null || stream.getAudioTracks().isEmpty) {
        print('⚠️ No remote audio tracks found even after connection!');
      } else {
        print('✅ Remote audio tracks: ${stream.getAudioTracks().length}');
      }
    });
  }

  void disposeWebRTC() {
    localRtc?.srcObject?.getTracks().forEach((track) => track.stop());
    remoteRtc?.srcObject?.dispose();
    remoteRtc?.dispose();
    remoteRtc = null;
    localRtc?.srcObject?.dispose();
    localRtc?.dispose();
    localRtc = null;
  }

  void setMicEnabled(bool enabled) {
    final localStream = localRtc?.srcObject;
    if (localStream == null) {
      return;
    }
    localStream.getAudioTracks().forEach((track) {
      Helper.setMicrophoneMute(!enabled, track);
    });
  }

  void setSpeakerphone(bool enabled) {
    Helper.setSpeakerphoneOn(enabled);
  }
}
