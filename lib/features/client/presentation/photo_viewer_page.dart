import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/services/google_drive_service.dart';
import '../../photographer/data/event_repository.dart';
import '../../photographer/data/photo_repository.dart';

class PhotoViewerPage extends ConsumerWidget {
  final String eventId;
  final String photoId;
  const PhotoViewerPage({
    super.key,
    required this.eventId,
    required this.photoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(eventPhotosProvider(eventId));

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          // Download button
          photosAsync.when(
            data: (photos) {
              final photo = photos.where((p) => p.id == photoId).firstOrNull;
              if (photo == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.download_rounded),
                tooltip: 'Download Photo',
                onPressed: () => _downloadPhoto(context, photo.url),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),

          // Save to Drive button
          photosAsync.when(
            data: (photos) {
              final photo = photos.where((p) => p.id == photoId).firstOrNull;
              if (photo == null) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.add_to_drive_rounded),
                tooltip: 'Save to Google Drive',
                onPressed: () =>
                    _saveToDrive(context, ref, photo.url, photo.fileName),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: photosAsync.when(
        data: (photos) {
          final photo = photos.firstWhere(
            (p) => p.id == photoId,
            orElse: () => throw Exception('Photo not found'),
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Hero(
                  tag: 'photo_${photo.id}',
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        photo.fileName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(photo.size / (1024 * 1024)).toStringAsFixed(2)}MB • ${DateFormat('yyyy-MM-dd HH:mm').format(photo.uploadedAt)}',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Download photo — opens the URL in a new tab (web) or launches browser (mobile).
  void _downloadPhoto(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open download link')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download error: $e')),
        );
      }
    }
  }

  /// Save a single photo to Google Drive.
  void _saveToDrive(
      BuildContext context, WidgetRef ref, String url, String fileName) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving to Google Drive...')),
    );

    final eventAsync = ref.read(eventProvider(eventId));
    final eventName = eventAsync.valueOrNull?.name ?? 'EventFrame';

    final success = await GoogleDriveService.uploadPhotoToDrive(
      eventName: eventName,
      photoUrl: url,
      fileName: fileName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Photo saved to Google Drive → EventFrame/$eventName/'
                : '❌ Failed to save to Drive',
          ),
        ),
      );
    }
  }
}
