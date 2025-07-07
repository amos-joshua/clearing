import 'package:flutter_webrtc/flutter_webrtc.dart' show RTCPeerConnectionState;
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

import '../../contacts/model/contact.dart';
import 'call_event.dart';

@Entity()
class Call {
  @Id()
  int id;

  String callUuid;
  final logEntries = ToMany<LogEntry>();

  final contact = ToOne<Contact>();
  List<String> contactPhoneNumbers;

  bool get incoming => !outgoing;
  bool outgoing;

  @Transient()
  CallUrgency urgency;

  String subject;
  String state;

  DateTime startTime;
  DateTime? endTime;

  String sdpOffer;
  String sdpAnswer;
  String webRTCPeerConnectionState;
  String webRTCIceConnectionState;
  String webRTCIceGatheringState;
  String webRTCSignalingState;

  int get dbUrgency => urgency.index;
  set dbUrgency(int index) {
    urgency = CallUrgency.values[index];
  }

  Call({
    this.id = 0,
    required this.callUuid,
    this.state = 'idle',
    this.outgoing = true,
    this.urgency = CallUrgency.leisure,
    this.contactPhoneNumbers = const [],
    this.subject = '',
    DateTime? startTime,
    this.endTime,
    this.sdpOffer = '',
    this.sdpAnswer = '',
    this.webRTCPeerConnectionState = '',
    this.webRTCIceConnectionState = '',
    this.webRTCIceGatheringState = '',
    this.webRTCSignalingState = '',
  }) : startTime = startTime ?? DateTime.now();

  @override
  String toString() =>
      'Call(id $id, contactPhoneNumbers: $contactPhoneNumbers, subject: $subject, urgency: $urgency)';

  static Call createOutgoing() =>
      Call(callUuid: const Uuid().v4(), outgoing: true);
  static Call createIncoming() =>
      Call(callUuid: const Uuid().v4(), outgoing: false);

  void addLog(String eventType, String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = LogEntry(
      timestamp: timestamp,
      eventType: eventType,
      message: message,
    );
    logEntries.add(logEntry);
  }

  bool get webRTCConnectionFailed =>
      webRTCPeerConnectionState ==
      RTCPeerConnectionState.RTCPeerConnectionStateFailed.name;

  void sanitizePhoneNumbers() {
    contactPhoneNumbers = contactPhoneNumbers
        .map((number) => Contact.sanitizePhoneNumber(number))
        .toList();
  }
}

@Entity()
class LogEntry {
  @Id()
  int id;

  String timestamp;
  String eventType;
  String message;

  LogEntry({
    this.id = 0,
    required this.timestamp,
    required this.eventType,
    required this.message,
  });

  String render() => '[$timestamp|$eventType] $message';
}
