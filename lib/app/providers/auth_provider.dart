import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/domain/app_user.dart';

// ── Raw Firebase auth state stream ──────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ── Resolved AppUser (with Firestore role) ───────────────────────────────────
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    print('DEBUG: appUserProvider - No Firebase user found.');
    return null;
  }

  print(
      'DEBUG: appUserProvider - Firebase user found (UID: ${user.uid}), fetching Firestore doc...');
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      print(
          'DEBUG: appUserProvider - Firestore doc NOT FOUND for UID: ${user.uid}');
      return null;
    }
    print(
        'DEBUG: appUserProvider - Firestore doc found! Role: ${doc.data()?['role']}');
    return AppUser.fromMap(user.uid, doc.data()!);
  } catch (e) {
    print('DEBUG: appUserProvider - ERROR fetching Firestore doc: $e');
    rethrow;
  }
});

// ── Auth Repository ──────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '21331862028-g8itj68ee8lcmm9ann3bolsgt1e761dd.apps.googleusercontent.com'
        : null,
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/drive.file',
      'https://www.googleapis.com/auth/drive.appdata',
    ],
  );

  /// Google Sign-In → creates Firestore user doc if new
  Future<AppUser?> signInWithGoogle() async {
    print('DEBUG: Starting Google Sign-In...');
    User? user;

    if (kIsWeb) {
      print('DEBUG: Web platform detected. Using signInWithPopup...');
      try {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.addScope('https://www.googleapis.com/auth/drive.file');
        googleProvider
            .addScope('https://www.googleapis.com/auth/drive.appdata');

        final userCredential = await _auth.signInWithPopup(googleProvider);
        user = userCredential.user;
        print('DEBUG: Web signInWithPopup success for UID: ${user?.uid}');
      } catch (e) {
        print('DEBUG: Web signInWithPopup ERROR: $e');
        rethrow;
      }
    } else {
      print('DEBUG: Mobile/Desktop platform detected. Using google_sign_in...');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('DEBUG: Google Sign-In canceled by user.');
        return null;
      }

      print('DEBUG: Google User retrieved: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      print('DEBUG: Google Auth tokens retrieved.');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('DEBUG: Signing in to Firebase with credential...');
      final userCredential = await _auth.signInWithCredential(credential);
      user = userCredential.user;
      print('DEBUG: Firebase Auth success for UID: ${user?.uid}');
    }

    if (user == null) return null;

    // Create user doc if first time
    final docRef = _firestore.collection('users').doc(user.uid);
    print('DEBUG: Checking for existing Firestore user document...');
    final doc = await docRef.get();

    if (!doc.exists) {
      print('DEBUG: Creating new Firestore user document...');
      await docRef.set({
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL,
        'role': 'user', // Default role
        'createdAt': DateTime.now().toIso8601String(),
      });
      print('DEBUG: Firestore user document created.');
    } else {
      print('DEBUG: Existing Firestore user document found.');
    }

    final fresh = await docRef.get();
    print('DEBUG: Returning AppUser with role: ${fresh.data()?['role']}');
    return AppUser.fromMap(user.uid, fresh.data()!);
  }

  /// Email OTP Sign-In (for clients without Google account)
  Future<void> sendEmailLink(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://eventframe.page.link/login',
      handleCodeInApp: true,
      androidPackageName: 'com.eventframe.app',
      iOSBundleId: 'com.eventframe.app',
    );
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
