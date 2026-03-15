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
      'event_id': eventId,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'uploaded_at': uploadedAt.toIso8601String(),
      'file_name': fileName,
      'size': size,
    };
  }

  factory Photo.fromMap(String id, Map<String, dynamic> map) {
    return Photo(
      id: id,
      eventId: map['event_id'] ?? '',
      url: map['url'] ?? '',
      thumbnailUrl: map['thumbnail_url'],
      uploadedAt: map['uploaded_at'] != null
          ? DateTime.parse(map['uploaded_at'])
          : DateTime.now(),
      fileName: map['file_name'] ?? '',
      size: map['size'] ?? 0,
    );
  }
}
