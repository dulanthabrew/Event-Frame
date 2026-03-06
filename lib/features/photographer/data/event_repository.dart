import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/providers/auth_provider.dart';
import '../domain/event.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(FirebaseFirestore.instance);
});

final photographerEventsProvider = StreamProvider<List<Event>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);

  return ref.watch(eventRepositoryProvider).getEventsByPhotographer(user.uid);
});

class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository(this._firestore);

  Stream<List<Event>> getEventsByPhotographer(String photographerUid) {
    debugPrint('DEBUG: Fetching events for photographer UID: $photographerUid');
    return _firestore
        .collection('events')
        .where('photographerUid', isEqualTo: photographerUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Event.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> createEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Future<Event?> getEventByCode(String code) async {
    final snapshot = await _firestore
        .collection('events')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Event.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  Stream<Event?> getEventById(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .snapshots()
        .map((doc) => doc.exists ? Event.fromMap(doc.id, doc.data()!) : null);
  }
}

final eventProvider = StreamProvider.family<Event?, String>((ref, eventId) {
  return ref.watch(eventRepositoryProvider).getEventById(eventId);
});
