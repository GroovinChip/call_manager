class Call {
  Call({
    this.avatar,
    this.description,
    this.id,
    required this.name,
    required this.phoneNumber,
    this.reminderDate,
    this.reminderTime,
    this.timeCreated,
    this.lastEdited,
    this.completedAt,
  });

  factory Call.fromJsonWithDocId(Map<String, dynamic> json, String docId) {
    DateTime? timestamp;
    DateTime? _lastEdited;
    if (json['TimeCreated'] != 'null' && json['TimeCreated'] != null) {
      timestamp = DateTime.parse(json['TimeCreated']);
    }

    if (json['LastEdited'] != 'null' && json['LastEdited'] != null) {
      _lastEdited = DateTime.parse(json['LastEdited']);
    }

    return Call(
      avatar: json['Avatar'] ?? '',
      description: json['Description'],
      id: docId,
      name: json['Name'],
      phoneNumber: json['PhoneNumber'],
      reminderDate: json['ReminderDate'],
      reminderTime: json['ReminderTime'],
      timeCreated: timestamp,
      lastEdited: _lastEdited,
      completedAt: json['CompletedAt'],
    );
  }

  String? avatar;
  String? completedAt;
  String? description;
  String? id;
  DateTime? lastEdited;
  String? name;
  String? phoneNumber;
  String? reminderDate;
  String? reminderTime;
  DateTime? timeCreated;

  Map<String, dynamic> toJson() {
    return {
      'Avatar': avatar,
      'Description': description,
      'Name': name,
      'PhoneNumber': phoneNumber,
      'ReminderDate': reminderDate?.toString() ?? '',
      'ReminderTime': reminderTime?.toString() ?? '',
      'TimeCreated': timeCreated.toString(),
      'LastEdited': lastEdited.toString(),
      'CompletedAt': completedAt ?? '',
    };
  }
}

extension CallX on Call {
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;
  bool get hasDescription => description != null && description!.isNotEmpty;
  bool get isNotCompleted => completedAt == null || completedAt!.isEmpty;
}
