class Event {
  final String id;
  final String name;
  final String code;
  final DateTime date;
  final String photographerUid;
  final bool watermarkEnabled;
  final int photoCount;
  final int clientCount;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.name,
    required this.code,
    required this.date,
    required this.photographerUid,
    this.watermarkEnabled = true,
    this.photoCount = 0,
    this.clientCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code.toUpperCase(),
      'date': date.toIso8601String(),
      'photographer_uid': photographerUid,
      'watermark_enabled': watermarkEnabled,
      'photo_count': photoCount,
      'client_count': clientCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      date: DateTime.parse(map['date']),
      photographerUid: map['photographer_uid'] ?? '',
      watermarkEnabled: map['watermark_enabled'] ?? true,
      photoCount: map['photo_count'] ?? 0,
      clientCount: map['client_count'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
