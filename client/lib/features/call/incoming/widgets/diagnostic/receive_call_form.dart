import 'package:clearing_client/features/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../services/active_call/active_call.dart';


class DiagnosticReceiveCallForm extends StatefulWidget {
  const DiagnosticReceiveCallForm({super.key});

  @override
  State<DiagnosticReceiveCallForm> createState() =>
      _DiagnosticReceiveCallFormState();
}

class _DiagnosticReceiveCallFormState extends State<DiagnosticReceiveCallForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _uuidController;

  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _uuidController.dispose();
    super.dispose();
  }

  void _handleAckCall() async {
    final call = Call(callUuid: _uuidController.text);
    final activeCallService = context.read<ActiveCallService>();
    await activeCallService.startIncomingCall(
      context,
      call: call,
      sdpOffer: 'sdp-offer',
      pushInsteadOfRoute: true,
      useWebrtc: false,
    );
  }

  void _handleRejectCall() {
    if (_formKey.currentState?.validate() ?? false) {
      print('Reject call with UUID: ${_uuidController.text}');
    }
  }

  void _pasteUuidFromClipboard() {
    Clipboard.getData(Clipboard.kTextPlain).then((data) {
      setState(() {
        _uuidController.text = data?.text ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _uuidController,
            decoration: InputDecoration(
              labelText: 'UUID',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste),
                onPressed: _pasteUuidFromClipboard,
                tooltip: 'Paste UUID',
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleAckCall,
            icon: const Icon(Icons.headset_mic),
            label: const Text('Ack'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleRejectCall,
            icon: const Icon(Icons.call_end),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
