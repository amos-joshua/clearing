import 'package:clearing_client/features/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../../services/active_call/active_call.dart';

class DiagnosticStartCallForm extends StatefulWidget {
  const DiagnosticStartCallForm({super.key});

  @override
  State<DiagnosticStartCallForm> createState() =>
      _DiagnosticStartCallFormState();
}

class _DiagnosticStartCallFormState extends State<DiagnosticStartCallForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _uuidController;
  late final TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController(text: const Uuid().v4());
    _phoneNumberController = TextEditingController(text: '+15552345');
  }

  @override
  void dispose() {
    _uuidController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleStartCall() async {
    if (_formKey.currentState?.validate() ?? false) {
      final call = Call(
        callUuid: _uuidController.text,
        contactPhoneNumbers: [_phoneNumberController.text],
      );
      final activeCallService = context.read<ActiveCallService>();
      await activeCallService.startOutgoingCall(
        context,
        call: call,
        pushInsteadOfRoute: true,
        useWebrtc: false,
      );
    }
  }

  void _copyUuidToClipboard() {
    Clipboard.setData(ClipboardData(text: _uuidController.text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('UUID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
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
                icon: const Icon(Icons.copy),
                onPressed: _copyUuidToClipboard,
                tooltip: 'Copy UUID',
              ),
              prefixIcon: IconButton(
                onPressed: () {
                  _uuidController.text = const Uuid().v4();
                },
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumberController,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _handleStartCall,
            icon: const Icon(Icons.headset_mic),
            label: const Text('Call'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
