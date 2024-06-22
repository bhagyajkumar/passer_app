import 'dart:convert';

class Event {
  final int id;
  final String name;
  final String description;
  final DateTime date;
  final String owner;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.owner,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      owner: json['owner'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'owner': owner,
    };
  }
}
