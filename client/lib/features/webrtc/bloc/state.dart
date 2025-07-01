import 'package:equatable/equatable.dart';

import '../../call/model/call.dart';

class WebRTCSessionState extends Equatable {
  final Call call;
  final int nonce;

  WebRTCSessionState({
    required this.call,
    required this.nonce,
  });

  WebRTCSessionState copyWith({
    Call? call,
    int? nonce,
  }) => WebRTCSessionState(call: call ?? this.call, nonce: nonce ?? this.nonce);


  @override
  List<Object?> get props => [call, nonce];
}
