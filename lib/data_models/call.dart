class Call {
  Call({
    this.avatar,
    this.description,
    this.id,
    required this.name,
    required this.phoneNumber,
    this.reminderDate,
    this.reminderTime,
    this.completedAt,
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
      completedAt: json['CompletedAt'],
    );
  }

  String? avatar;
  String? description;
  String? id;
  String? name;
  String? phoneNumber;
  String? reminderDate;
  String? reminderTime;
  String? completedAt;

  Map<String, dynamic> toJson() {
    return {
      'Avatar': avatar,
      'Description': description,
      'Name': name,
      'PhoneNumber': phoneNumber,
      'ReminderDate': reminderDate?.toString() ?? '',
      'ReminderTime': reminderTime?.toString() ?? '',
      'CompletedAt': completedAt ?? '',
    };
  }
}

extension CallX on Call {
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get isCompleted => completedAt != '';
}
