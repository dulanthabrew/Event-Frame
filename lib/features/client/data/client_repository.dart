import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../photographer/domain/event.dart';
import '../../../app/providers/auth_provider.dart';

final _supabase = Supabase.instance.client;

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository();
});

/// Fetches events the current client has accessed.
final clientEventsProvider = FutureProvider<List<Event>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];

  return ref.watch(clientRepositoryProvider).getAccessedEvents(user.id);
});

class ClientRepository {
  /// Records that the user has accessed a specific event.
  Future<void> addEventAccess(String userId, String eventId) async {
    try {
      debugPrint(
          'DEBUG: ClientRepository - Adding access for user $userId to event $eventId');

      // Fetch specifically for the current user
      final rows = await _supabase
          .from('clients')
          .select('event_access')
          .eq('user_id', userId);

      List<String> currentAccess = [];
      if (rows.isNotEmpty && rows.first['event_access'] != null) {
        currentAccess = List<String>.from(rows.first['event_access']);
      }

      debugPrint('DEBUG: ClientRepository - Current access: $currentAccess');

      // Add if not already present
      if (!currentAccess.contains(eventId)) {
        currentAccess.add(eventId);

        // Use upsert with onConflict to be safe
        await _supabase.from('clients').upsert({
          'user_id': userId,
          'event_access': currentAccess,
        }, onConflict: 'user_id');

        debugPrint(
            'DEBUG: ClientRepository - Access successfully updated for $eventId');
      } else {
        debugPrint(
            'DEBUG: ClientRepository - Event $eventId already in history.');
      }
    } catch (e) {
      debugPrint('DEBUG: ClientRepository - ERROR in addEventAccess: $e');
    }
  }

  /// Retrieves full event details for all events accessed by the user.
  Future<List<Event>> getAccessedEvents(String userId) async {
    try {
      debugPrint(
          'DEBUG: ClientRepository - Fetching accessed events for user $userId');

      final rows = await _supabase
          .from('clients')
          .select('event_access')
          .eq('user_id', userId);

      if (rows.isEmpty || rows.first['event_access'] == null) {
        debugPrint('DEBUG: ClientRepository - No history found for user.');
        return [];
      }

      final List<String> eventIds =
          List<String>.from(rows.first['event_access']);
      debugPrint(
          'DEBUG: ClientRepository - Found ${eventIds.length} event IDs in history: $eventIds');

      if (eventIds.isEmpty) return [];

      // Fetch event details for these IDs
      final eventRows =
          await _supabase.from('events').select().inFilter('id', eventIds);

      debugPrint(
          'DEBUG: ClientRepository - Successfully fetched ${eventRows.length} event objects.');

      // Sort by date manually as inFilter order is unpredictable
      final events =
          eventRows.map((row) => Event.fromMap(row['id'], row)).toList();
      events.sort((a, b) => b.date.compareTo(a.date));

      return events;
    } catch (e) {
      debugPrint('DEBUG: ClientRepository - ERROR in getAccessedEvents: $e');
      return [];
    }
  }
}
