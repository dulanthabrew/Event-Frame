import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../domain/photo.dart';

class PhotoRepository {
  final FirebaseFirestore _firestore;

  PhotoRepository(this._firestore);

  Stream<List<Photo>> getPhotosByEvent(String eventId) {
    debugPrint('DEBUG: Fetching photos for eventId: $eventId');
    return _firestore
        .collection('photos')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      debugPrint(
          'DEBUG: Found ${snapshot.docs.length} photos for eventId: $eventId');
      return snapshot.docs.map((doc) => Photo.fromFirestore(doc)).toList();
    });
  }

  Future<void> uploadPhotos(
      String eventId, List<XFile> files, Function(double) onProgress) async {
    debugPrint(
        'DEBUG: Starting mock upload of ${files.length} photos for eventId: $eventId');
    final int totalFiles = files.length;

    for (int i = 0; i < totalFiles; i++) {
      final file = files[i];
      final photoId = const Uuid().v4();

      // Simulate progress for the "upload"
      for (int p = 0; p <= 10; p++) {
        await Future.delayed(const Duration(milliseconds: 100));
        final currentFileProgress = p / 10.0;
        final overallProgress = (i + currentFileProgress) / totalFiles;
        onProgress(overallProgress);
      }

      // Use a distinct placeholder image for each photo based on photoId
      final url = 'https://picsum.photos/seed/$photoId/1200/800';

      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;

      final photo = Photo(
        id: photoId,
        eventId: eventId,
        url: url,
        uploadedAt: DateTime.now(),
        fileName: file.name,
        size: fileSize,
      );

      // Save metadata to Firestore (this part is still real)
      await _firestore.collection('photos').add(photo.toMap());

      // Increment photo count in the event document
      await _firestore.collection('events').doc(eventId).update({
        'photoCount': FieldValue.increment(1),
      });
    }

    onProgress(1.0);
  }
}

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(
    FirebaseFirestore.instance,
  );
});

final eventPhotosProvider =
    StreamProvider.family<List<Photo>, String>((ref, eventId) {
  return ref.watch(photoRepositoryProvider).getPhotosByEvent(eventId);
});
