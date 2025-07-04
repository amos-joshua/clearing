import 'package:freezed_annotation/freezed_annotation.dart';

import '../../call/model/call_event.dart';

part 'state.freezed.dart';

@freezed
sealed class CallComposerState with _$CallComposerState {
  const factory CallComposerState({
    required String? displayName,
    required List<String> contactPhoneNumbers,
    required CallUrgency urgency,
    required String subject,
  }) = _CallComposerState;

  static CallComposerState forContact({
    required String? displayName,
    required List<String> contactPhoneNumbers,
    CallUrgency? urgency,
  }) => CallComposerState(
    displayName: displayName,
    contactPhoneNumbers: contactPhoneNumbers,
    urgency: urgency ?? CallUrgency.leisure,
    subject: '',
  );
}
