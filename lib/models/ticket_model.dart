import 'dart:convert';
import 'event_model.dart';

class Ticket {
  final String id;
  final Event event;

  Ticket({
    required this.id,
    required this.event,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      event: Event.fromJson(json['event']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event.toJson(),
    };
  }
}
