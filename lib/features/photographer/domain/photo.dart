import 'package:cloud_firestore/cloud_firestore.dart';

class Photo {
  final String id;
  final String eventId;
  final String url;
  final String? thumbnailUrl;
  final DateTime uploadedAt;
  final String fileName;
  final int size;

  Photo({
    required this.id,
    required this.eventId,
    required this.url,
    this.thumbnailUrl,
    required this.uploadedAt,
    required this.fileName,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'uploadedAt': uploadedAt.toIso8601String(),
      'fileName': fileName,
      'size': size,
    };
  }

  factory Photo.fromMap(String id, Map<String, dynamic> map) {
    return Photo(
      id: id,
      eventId: map['eventId'] ?? '',
      url: map['url'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.parse(map['uploadedAt'])
          : DateTime.now(),
      fileName: map['fileName'] ?? '',
      size: map['size'] ?? 0,
    );
  }

  factory Photo.fromFirestore(DocumentSnapshot doc) {
    return Photo.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}
