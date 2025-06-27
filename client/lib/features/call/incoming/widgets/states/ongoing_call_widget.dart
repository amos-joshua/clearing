import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../outgoing/widgets/hang_up_button.dart';
import '../../../widgets/rtc_video_mixin.dart';
import '../../bloc/incoming_call_bloc.dart';
import '../../bloc/incoming_call_state.dart';
import '../call_header_widget.dart';
import '../../../widgets/call_timer_widget.dart';

class OngoingCallWidget extends StatefulWidget {
  const OngoingCallWidget({super.key});

  @override
  State<OngoingCallWidget> createState() => _OngoingCallWidgetState();
}

class _OngoingCallWidgetState extends State<OngoingCallWidget>
    with RtcVideoMixin {
  bool micEnabled = false;
  bool speakerphoneOn = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<IncomingCallBloc>();
    final webrtcSession = bloc.webrtcSession;
    if (webrtcSession != null) {
      startWebRTC(webrtcSession);
      setMicEnabled(micEnabled);
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
    return BlocBuilder<IncomingCallBloc, IncomingCallState>(
      builder: (context, state) {
        if (state is! IncomingCallStateOngoing) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IncomingCallHeaderWidget(
              stateIcon: Icons.phone,
              iconColor: Colors.green,
              stateText: 'Call in Progress',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setMicEnabled(!micEnabled);
                    setState(() {
                      micEnabled = !micEnabled;
                    });
                  },
                  icon: Icon(micEnabled ? Icons.mic : Icons.mic_off),
                ),
                IconButton(
                  onPressed: () {
                    setSpeakerphone(!speakerphoneOn);
                    setState(() {
                      speakerphoneOn = !speakerphoneOn;
                    });
                  },
                  icon: Icon(
                    speakerphoneOn ? Icons.speaker : Icons.speaker_notes_off,
                  ),
                ),
              ],
            ),
            const HangUpButton(),
          ],
        );
      },
    );
  }
}
