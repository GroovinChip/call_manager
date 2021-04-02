import 'package:flutter/foundation.dart';

class Call {
  Call({
    this.avatar,
    this.description,
    this.id,
    @required this.name,
    @required this.phoneNumber,
    this.reminderDate,
    this.reminderTime,
  });

  factory Call.fromJsonWithDocId(Map<String, dynamic> json, String docId) {
    return Call(
      avatar: json['Avatar'] ?? '',
      description: json['Description'],
      id: docId,
      name: json['Name'],
      phoneNumber: json['PhoneNumber'],
      reminderDate: json['ReminderDate'],
      reminderTime: json['ReminderTime'],
    );
  }

  String avatar;
  String description;
  String id;
  String name;
  String phoneNumber;
  String reminderDate;
  String reminderTime;


  Map<String, dynamic> toJson() {
    return {
      'Avatar': avatar,
      'Description': description,
      'Name': name,
      'PhoneNumber': phoneNumber,
      'ReminderDate': reminderDate?.toString() ?? '',
      'ReminderTime': reminderTime?.toString() ?? '',
    };
  }
}

extension CallX on Call {
  bool get hasAvatar => avatar != null && avatar.isNotEmpty;
  bool get hasDescription => description != null && description.isNotEmpty;
}