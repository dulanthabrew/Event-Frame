import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/services/google_drive_service.dart';
import '../../../app/theme/app_theme.dart';
import '../../photographer/data/event_repository.dart';
import '../../photographer/data/photo_repository.dart';
import '../../photographer/domain/photo.dart';
import '../data/client_repository.dart';

/// Sync all photos to Google Drive with a progress dialog.
Future<void> _syncAllToDrive(
    BuildContext context, WidgetRef ref, List<Photo> photos) async {
  final eventId = (context as Element)
      .findAncestorWidgetOfExactType<GalleryPage>()
      ?.eventId;
  final eventName = eventId != null
      ? ref.read(eventProvider(eventId)).valueOrNull?.name ?? 'EventFrame'
      : 'EventFrame';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DriveSyncDialog(
      eventName: eventName,
      photos: photos,
    ),
  );
}

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
          // Share gallery link
          eventAsync.when(
            data: (event) => IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Event Link',
              onPressed: () {
                if (event != null) {
                  Share.share(
                    'Check out my photos from ${event.name}!\nEvent Code: ${event.code}\nhttps://eventframe.app/event/${event.code}',
                  );
                }
              },
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          // Sync all photos to Google Drive
          photosAsync.when(
            data: (photos) => IconButton(
              icon: const Icon(Icons.add_to_drive_rounded),
              tooltip: 'Sync All to Google Drive',
              onPressed: photos.isEmpty
                  ? null
                  : () => _syncAllToDrive(context, ref, photos),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          // Switch/Join Event
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch Event',
            onPressed: () => _showEventSwitcher(context),
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
              OutlinedButton.icon(
                onPressed: () {
                  final photos =
                      ref.read(eventPhotosProvider(eventId)).valueOrNull ?? [];
                  if (photos.isNotEmpty) {
                    _syncAllToDrive(context, ref, photos);
                  }
                },
                icon: const Icon(Icons.add_to_drive_rounded, size: 16),
                label: const Text('Add to Drive'),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: photo.thumbnailUrl ?? photo.url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                memCacheWidth: 400,
                memCacheHeight: 400,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppTheme.cardDark,
                  highlightColor: AppTheme.primary.withOpacity(0.1),
                  child: Container(color: AppTheme.cardDark),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.cardDark,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.grey, size: 32),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Drive Sync Progress Dialog ─────────────────────────────────────────────
class _DriveSyncDialog extends StatefulWidget {
  final String eventName;
  final List<Photo> photos;

  const _DriveSyncDialog({
    required this.eventName,
    required this.photos,
  });

  @override
  State<_DriveSyncDialog> createState() => _DriveSyncDialogState();
}

class _DriveSyncDialogState extends State<_DriveSyncDialog> {
  int _current = 0;
  int _total = 0;
  bool _done = false;
  int _uploaded = 0;

  @override
  void initState() {
    super.initState();
    _total = widget.photos.length;
    _startSync();
  }

  Future<void> _startSync() async {
    final photoMaps = widget.photos
        .map((p) => {'url': p.url, 'fileName': p.fileName})
        .toList();

    _uploaded = await GoogleDriveService.syncEventToDrive(
      eventName: widget.eventName,
      photos: photoMaps,
      onProgress: (current, total) {
        if (mounted) {
          setState(() {
            _current = current;
            _total = total;
          });
        }
      },
    );

    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_done ? 'Sync Complete!' : 'Syncing to Google Drive...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_done) ...[
            LinearProgressIndicator(
              value: _total > 0 ? _current / _total : null,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 16),
            Text('$_current / $_total photos'),
          ],
          if (_done) ...[
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.success, size: 48),
            const SizedBox(height: 16),
            Text(
              '$_uploaded of $_total photos saved to\nGoogle Drive → EventFrame/${widget.eventName}/',
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        if (_done)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
      ],
    );
  }
}

void _showEventSwitcher(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _EventSwitcherSheet(),
  );
}

class _EventSwitcherSheet extends ConsumerWidget {
  const _EventSwitcherSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientEvents = ref.watch(clientEventsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Events',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          clientEvents.when(
            data: (events) {
              if (events.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No other events accessed yet.'),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.primary,
                        child: Icon(Icons.event_note_rounded,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(event.name),
                      subtitle: Text('Code: ${event.code}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/gallery/${event.id}');
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.go('/event');
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Access a New Event'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
