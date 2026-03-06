import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';
import '../../photographer/data/event_repository.dart';
import '../../photographer/data/photo_repository.dart';
import '../../photographer/domain/photo.dart';

class GalleryPage extends ConsumerWidget {
  final String eventId;
  const GalleryPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));
    final photosAsync = ref.watch(eventPhotosProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: eventAsync.when(
          data: (event) => Text(event?.name ?? 'Gallery'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Share gallery link
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            onPressed: () {
              // TODO: Sync to Google Drive
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Event Banner
          _EventInfoBanner(eventId: eventId)
              .animate()
              .fadeIn()
              .slideY(begin: -0.2),

          // Photo Grid
          Expanded(
            child: photosAsync.when(
              data: (photos) {
                if (photos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No photos in this gallery yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 5 : 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return _GalleryPhotoItem(
                      photo: photo,
                      onTap: () =>
                          context.go('/gallery/$eventId/photo/${photo.id}'),
                    ).animate(delay: (index * 20).ms).fadeIn().scale();
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventInfoBanner extends ConsumerWidget {
  final String eventId;
  const _EventInfoBanner({required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));

    return eventAsync.when(
      data: (event) {
        if (event == null) return const SizedBox();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withOpacity(0.1),
                AppTheme.accent.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_note_rounded,
                    color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Captured by Photographer • ${event.date.day}/${event.date.month}/${event.date.year}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Add to Drive'),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _GalleryPhotoItem extends StatelessWidget {
  final Photo photo;
  final VoidCallback onTap;

  const _GalleryPhotoItem({required this.photo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'photo_${photo.id}',
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(photo.url),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            padding: const EdgeInsets.all(8),
            alignment: Alignment.bottomRight,
            child: const Icon(
              Icons.star_border_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
