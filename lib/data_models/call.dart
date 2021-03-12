import 'package:flutter/foundation.dart';

class Call {
  Call({
    @required this.id,
    @required this.name,
    @required this.phoneNumber,
    this.avatar,
    this.description,
    this.reminderDate,
    this.reminderTime,
  });

  factory Call.fromJsonWithDocId(Map<String, dynamic> json, String docId) {
    return Call(
      id: docId,
      name: json['Name'],
      phoneNumber: json['PhoneNumber'],
      avatar: json['Avatar'] ?? '',
      description: json['Description'],
      reminderDate: json['ReminderDate'],
      reminderTime: json['ReminderTime'],
    );
  }

  final String id;
  final String name;
  final String phoneNumber;
  final String avatar;
  final String description;
  final String reminderDate;
  final String reminderTime;

  bool get hasAvatar => avatar.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'Call': {
        'id': id,
        'name': name,
        'phone': phoneNumber,
        'hasAvatar': avatar.isNotEmpty,
        'description': description,
        'reminderDate': reminderDate,
        'reminderTime': reminderTime,
      }
    };
  }
}
