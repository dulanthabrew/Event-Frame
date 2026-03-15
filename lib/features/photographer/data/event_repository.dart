import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/providers/auth_provider.dart';
import '../domain/event.dart';

final _supabase = Supabase.instance.client;

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

/// FutureProvider that fetches events — call ref.invalidate() to refresh.
final photographerEventsProvider = FutureProvider<List<Event>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];

  return ref.watch(eventRepositoryProvider).getEventsByPhotographer(user.id);
});

class EventRepository {
  Future<List<Event>> getEventsByPhotographer(String photographerUid) async {
    debugPrint('DEBUG: Fetching events for photographer UID: $photographerUid');
    final rows = await _supabase
        .from('events')
        .select()
        .eq('photographer_uid', photographerUid)
        .order('created_at', ascending: false);

    return rows.map((row) => Event.fromMap(row['id'], row)).toList();
  }

  Future<void> createEvent(Event event) async {
    await _supabase.from('events').insert(event.toMap());
  }

  Future<Event?> getEventByCode(String code) async {
    final response = await _supabase
        .from('events')
        .select()
        .eq('code', code.toUpperCase())
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return Event.fromMap(response['id'], response);
  }

  Future<Event?> getEventById(String eventId) async {
    final response =
        await _supabase.from('events').select().eq('id', eventId).maybeSingle();

    if (response == null) return null;
    return Event.fromMap(response['id'], response);
  }
}

final eventProvider =
    FutureProvider.family<Event?, String>((ref, eventId) async {
  return ref.watch(eventRepositoryProvider).getEventById(eventId);
});
