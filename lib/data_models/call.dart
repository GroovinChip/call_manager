import 'package:flutter/foundation.dart';

class Call {
  Call({
    this.id,
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

  String id;
  String name;
  String phoneNumber;
  String avatar;
  String description;
  String reminderDate;
  String reminderTime;


  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'PhoneNumber': phoneNumber,
      'Avatar': avatar,
      'Description': description,
      'ReminderDate': reminderDate?.toString() ?? '',
      'ReminderTime': reminderTime?.toString() ?? '',
    };
  }
}

extension CallX on Call {
  bool get hasAvatar => avatar != null && avatar.isNotEmpty;
  bool get hasDescription => description != null && description.isNotEmpty;
}