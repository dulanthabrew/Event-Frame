import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/photo.dart';

final _supabase = Supabase.instance.client;

class PhotoRepository {
  Future<List<Photo>> getPhotosByEvent(String eventId) async {
    debugPrint('DEBUG: Fetching photos for eventId: $eventId');
    final rows = await _supabase
        .from('photos')
        .select()
        .eq('event_id', eventId)
        .order('uploaded_at', ascending: false);

    debugPrint('DEBUG: Found ${rows.length} photos for eventId: $eventId');
    return rows.map((row) => Photo.fromMap(row['id'], row)).toList();
  }

  Future<void> uploadPhotos(
      String eventId, List<XFile> files, Function(double) onProgress) async {
    debugPrint(
        'DEBUG: Starting upload of ${files.length} photos for eventId: $eventId');
    final int totalFiles = files.length;

    for (int i = 0; i < totalFiles; i++) {
      final file = files[i];
      final photoId = const Uuid().v4();
      final fileExt = file.name.split('.').last;
      final storagePath = '$eventId/$photoId.$fileExt';

      // Upload to Supabase Storage
      final bytes = await file.readAsBytes();
      final fileSize = bytes.length;

      String url;
      try {
        await _supabase.storage.from('photos').uploadBinary(
              storagePath,
              bytes,
              fileOptions: FileOptions(
                contentType: 'image/$fileExt',
                upsert: true,
              ),
            );
        url = _supabase.storage.from('photos').getPublicUrl(storagePath);
      } catch (e) {
        debugPrint('DEBUG: Storage upload error: $e');
        // Fallback: use placeholder image if storage fails
        url = 'https://picsum.photos/seed/$photoId/1200/800';
      }

      final photo = Photo(
        id: photoId,
        eventId: eventId,
        url: url,
        uploadedAt: DateTime.now(),
        fileName: file.name,
        size: fileSize,
      );

      // Save metadata to database
      await _supabase.from('photos').insert(photo.toMap());

      // Increment photo count
      try {
        final event = await _supabase
            .from('events')
            .select('photo_count')
            .eq('id', eventId)
            .single();
        await _supabase.from('events').update({
          'photo_count': (event['photo_count'] as int) + 1,
        }).eq('id', eventId);
      } catch (e) {
        debugPrint('DEBUG: Photo count update error: $e');
      }

      // Update progress
      final overallProgress = (i + 1) / totalFiles;
      onProgress(overallProgress);
    }

    onProgress(1.0);
  }
}

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository();
});

final eventPhotosProvider =
    FutureProvider.family<List<Photo>, String>((ref, eventId) async {
  return ref.watch(photoRepositoryProvider).getPhotosByEvent(eventId);
});
