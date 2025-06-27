import 'package:freezed_annotation/freezed_annotation.dart';

import '../../call/model/call_event.dart';

part 'state.freezed.dart';

@freezed
sealed class CallComposerState with _$CallComposerState {
  const factory CallComposerState({
    required String? displayName,
    required List<String> contactEmails,
    required CallUrgency urgency,
    required String subject,
  }) = _CallComposerState;

  static CallComposerState forContact({
    required String? displayName,
    required List<String> contactEmails,
    CallUrgency? urgency,
  }) => CallComposerState(
    displayName: displayName,
    contactEmails: contactEmails,
    urgency: urgency ?? CallUrgency.leisure,
    subject: '',
  );
}
