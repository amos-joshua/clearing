import 'package:flutter/material.dart';
import '../../incoming_call_widget.dart';
import 'incoming_event_button_bar_widget.dart';

class IncomingCallStagingWidget extends StatelessWidget {
  const IncomingCallStagingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: const IncomingCallWidget(),
        ),
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
                  IncomingEventButtonBarWidget(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
