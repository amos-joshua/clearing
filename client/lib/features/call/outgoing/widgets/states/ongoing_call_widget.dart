import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../webrtc/bloc/bloc.dart';
import '../../../../webrtc/bloc/widgets/webrtc_call_status_widget.dart';
import '../../../widgets/rtc_video_mixin.dart';
import '../../bloc/outgoing_call_bloc.dart';
import '../../bloc/outgoing_call_state.dart';
import '../call_header_widget.dart';
import '../hang_up_button.dart';
import '../../../widgets/call_timer_widget.dart';

class OngoingCallWidget extends StatefulWidget {
  const OngoingCallWidget({super.key});

  @override
  State<OngoingCallWidget> createState() => _OngoingCallWidgetState();
}

class _OngoingCallWidgetState extends State<OngoingCallWidget>
    with RtcVideoMixin {
  bool micMuted = false;
  bool speakerphoneOn = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<OutgoingCallBloc>();
    final webrtcSession = bloc.webrtcSession;
    if (webrtcSession != null) {
      startWebRTC(webrtcSession);
      setMicMuteEnabled(context, micMuted, showSnackBar: false);
      setSpeakerphone(context, speakerphoneOn, showSnackBar: false);
    }
  }

  @override
  void dispose() {
    disposeWebRTC();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remoteRtc = this.remoteRtc;
    final _ = context.watch<WebRTCSessionBloc>();

    return BlocBuilder<OutgoingCallBloc, OutgoingCallState>(
      builder: (context, state) {
        if (state is! OutgoingCallStateOngoing) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutgoingCallHeaderWidget(
              stateIcon: Icons.call,
              iconColor: Colors.green.shade400,
              stateText: 'Call in progress',
            ),
            const SizedBox(height: 20),
            CallTimerWidget(startedAt: state.startedAt),
            const SizedBox(height: 40),
            if (remoteRtc != null)
              SizedBox(
                width: 100,
                height: 10,
                child: RTCVideoView(remoteRtc, mirror: false),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      micMuted = !micMuted;
                      setMicMuteEnabled(context, micMuted);
                    });
                  },
                  icon: Icon(micMuted ? Icons.mic_off : Icons.mic),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      speakerphoneOn = !speakerphoneOn;
                      setSpeakerphone(context, speakerphoneOn);
                    });
                  },
                  icon: Icon(speakerphoneOn ? Icons.speaker : Icons.headset),
                ),
              ],
            ),
            const HangUpButton(isOutgoing: true),
            const SizedBox(height: 20),
            const WebRTCCallStatusWidget(),
          ],
        );
      },
    );
  }
}
