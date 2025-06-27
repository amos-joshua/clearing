import 'package:flutter/material.dart';
import '../../outgoing_call_widget.dart';
import 'outgoing_event_button_bar_widget.dart';

class OutgoingCallStagingWidget extends StatelessWidget {
  const OutgoingCallStagingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top 2/4 of the screen - OutgoingCall widget
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const OutgoingCallWidget(),
        ),

        // Bottom 1/4 of the screen - Event buttons
        const Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Call Events',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  OutgoingEventButtonBarWidget(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
