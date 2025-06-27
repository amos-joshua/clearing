import 'dart:async';

import 'model/call_event.dart';
import 'call_gateway.dart';

class CallGatewayScripted implements CallGateway {
  final _outgoingEvents = <CallEvent>[];
  final _eventsController = StreamController<CallEvent>.broadcast();

  CallGatewayScripted(List<CallEvent> incomingEvents) {
    incomingEvents.forEach(_eventsController.add);
  }
  
  @override
  Stream<CallEvent> get events => _eventsController.stream;

  @override
  void sendEvent(CallEvent event) {
    _outgoingEvents.add(event);
  }

  void dispose() {
    _eventsController.close();
  }
} 