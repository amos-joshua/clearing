import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'model/call_event.dart';

abstract class CallGateway {
  void sendEvent(CallEvent event);
  Stream<CallEvent> get events;
}

class CallGatewayWebsocket implements CallGateway {
  static const connectionTimeoutSeconds = 10;
  final WebSocketChannel websocket;

  CallGatewayWebsocket({required this.websocket});

  @override
  void sendEvent(CallEvent event) {
    try {
      final encodedEvent = jsonEncode(event.toJson());
      websocket.sink.add(encodedEvent);
    } catch (exc, stackTrace) {
      print("Failed to send event $event: $exc\n$stackTrace");
    }
  }

  @override
  Stream<CallEvent> get events => websocket.stream.map((event) {
    try {
      return CallEvent.fromJson(jsonDecode(event));
    } catch (exc, stackTrace) {
      print("Failed to parse received event $event: $exc\n$stackTrace");
      return CallEvent.error(
        errorCode: 'PARSE_ERROR',
        errorMessage:
            'Failed to parse received event $event: $exc\n$stackTrace',
      );
    }
  });

  static Future<CallGatewayWebsocket> connect(String endpoint) async {
    final url = Uri.parse(endpoint);
    final channel = WebSocketChannel.connect(url);
    await channel.ready.timeout(
      const Duration(seconds: connectionTimeoutSeconds),
      onTimeout: () {
        throw TimeoutException(
          'Connection timed out after $connectionTimeoutSeconds seconds',
        );
      },
    );

    return CallGatewayWebsocket(websocket: channel);
  }
}
