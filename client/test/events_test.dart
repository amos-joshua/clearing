import 'package:flutter_test/flutter_test.dart';
import 'package:clearing_client/features/call/model/call_event.dart';

void main() {
  group('CallEvent', () {
    test('should parse error event JSON correctly', () {
      const json = {
        'call_event': 'error',
        'error_code': 'CallParticipantAuthenticationFailure',
        'error_message': 'Caller could not be authenticated'
      };

      final event = CallEvent.fromJson(json);

      expect(event, isA<CallError>());
      
      final errorEvent = event as CallError;
      expect(errorEvent.errorCode, equals('CallParticipantAuthenticationFailure'));
      expect(errorEvent.errorMessage, equals('Caller could not be authenticated'));
    });
  });
}
