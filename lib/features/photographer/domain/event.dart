import 'package:cloud_firestore/cloud_firestore.dart';

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
      'date': Timestamp.fromDate(date),
      'photographerUid': photographerUid,
      'watermarkEnabled': watermarkEnabled,
      'photoCount': photoCount,
      'clientCount': clientCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Event.fromMap(String id, Map<String, dynamic> map) {
    return Event(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      photographerUid: map['photographerUid'] ?? '',
      watermarkEnabled: map['watermarkEnabled'] ?? true,
      photoCount: map['photoCount'] ?? 0,
      clientCount: map['clientCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
