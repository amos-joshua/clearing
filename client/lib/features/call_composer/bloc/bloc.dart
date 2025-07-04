import 'package:clearing_client/services/storage/database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../call/model/call.dart';
import '../../call/model/call_event.dart';
import 'state.dart';

sealed class CallComposerEvent {}

class CallComposerEventContactUpdated extends CallComposerEvent {
  final List<String> phoneNumbers;
  CallComposerEventContactUpdated(this.phoneNumbers);
}

class CallComposerEventUrgencyUpdated extends CallComposerEvent {
  final CallUrgency urgency;
  CallComposerEventUrgencyUpdated(this.urgency);
}

class CallComposerEventSubjectUpdated extends CallComposerEvent {
  final String subject;
  CallComposerEventSubjectUpdated(this.subject);
}

class CallComposerBloc extends Bloc<CallComposerEvent, CallComposerState> {
  final Database database;

  CallComposerBloc({
    required this.database,
    required List<String> phoneNumbers,
    required String? displayName,
    CallUrgency? urgency,
  }) : super(
         CallComposerState.forContact(
           displayName: displayName,
           contactPhoneNumbers: phoneNumbers,
           urgency: urgency,
         ),
       ) {
    on<CallComposerEventContactUpdated>(_onContactUpdated);
    on<CallComposerEventUrgencyUpdated>(_onUrgencyUpdated);
    on<CallComposerEventSubjectUpdated>(_onSubjectUpdated);
  }

  void _onContactUpdated(
    CallComposerEventContactUpdated event,
    Emitter<CallComposerState> emit,
  ) {
    emit(state.copyWith(contactPhoneNumbers: event.phoneNumbers));
  }

  void _onUrgencyUpdated(
    CallComposerEventUrgencyUpdated event,
    Emitter<CallComposerState> emit,
  ) {
    emit(state.copyWith(urgency: event.urgency));
  }

  void _onSubjectUpdated(
    CallComposerEventSubjectUpdated event,
    Emitter<CallComposerState> emit,
  ) {
    emit(state.copyWith(subject: event.subject));
  }

  Future<Call> createOutgoing() async {
    final call = Call.createOutgoing();
    call.subject = state.subject;
    call.urgency = state.urgency;
    call.contactPhoneNumbers = state.contactPhoneNumbers;
    call.contact.target = await database.contactForPhoneNumbers(state.contactPhoneNumbers);
    await database.saveCall(call);
    return call;
  }
}
