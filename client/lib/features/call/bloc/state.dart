
import 'package:equatable/equatable.dart';

import '../model/call.dart';

class CallsState extends Equatable {
  final List<Call> calls;

  const CallsState({
    this.calls = const [],
  });

  CallsState copyWith({
    List<Call>? calls,
  }) => CallsState(calls: calls ?? this.calls);

  @override
  List<Object> get props => [...calls.map((call) => call.id)];
}

