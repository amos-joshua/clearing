import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../call/model/call.dart';
import '../../../settings/bloc/bloc.dart';
import '../../../../utils/dialogs.dart';
import '../bloc.dart';

class WebRTCCallStatusWidget extends StatelessWidget {
  const WebRTCCallStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettingsState = context.watch<AppSettingsCubit>().state;
    final isDeveloperMode = appSettingsState.appSettings.isDeveloper;
    final webrtcState = context.watch<WebRTCSessionBloc>().state;

    final call = webrtcState.call;
    if (!isDeveloperMode) {
      if (call.webRTCConnectionFailed) {
        return _rtcConnectionError(context, call);
      }
      return const SizedBox.shrink();
    }

    return _buildDeveloperStatusContainer(context, call);
  }

  Widget _errorStatusContainer(
    BuildContext context,
    String message,
    void Function()? onTap,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(168),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox(
        width: 250,
        child: ListTile(
          title: Text(
            message,
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.info, color: Colors.red.shade400, size: 24),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _rtcConnectionError(BuildContext context, Call call) {
    return _errorStatusContainer(context, 'no audio connection', () {
      final rtcDebugInfo =
          "peerConnectionState: ${call.webRTCPeerConnectionState}\n"
          "iceConnectionState: ${call.webRTCIceConnectionState}\n"
          "iceGatheringState: ${call.webRTCIceGatheringState}\n"
          "signalingState: ${call.webRTCSignalingState}";
      AlertMessageDialog(context).show(
        title: 'Connection Issue',
        message:
            'A direct audio link could not be established, this call may require a relay server. Please report this bug.\n\n$rtcDebugInfo',
      );
    });
  }

  Widget _buildDeveloperStatusContainer(BuildContext context, Call call) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'WebRTC Status',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          if (call.webRTCConnectionFailed) _rtcConnectionError(context, call),
          const SizedBox(height: 2),
          _buildStatusRow('Peer Connection', call.webRTCPeerConnectionState),
          _buildStatusRow('ICE Connection', call.webRTCIceConnectionState),
          _buildStatusRow('ICE Gathering', call.webRTCIceGatheringState),
          _buildStatusRow('Signaling', call.webRTCSignalingState),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String state) {
    final hasState = state.isNotEmpty;
    final stateColor = hasState ? Colors.green : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey[600], fontSize: 9),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: stateColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hasState ? state : 'disconnected',
            style: TextStyle(
              color: stateColor,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
