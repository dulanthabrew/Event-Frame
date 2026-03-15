import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/app_user.dart';

// ── Supabase client shortcut ────────────────────────────────────────────────
final _supabase = Supabase.instance.client;

// ── Raw Supabase auth state stream ──────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

// ── Resolved AppUser (with profile role from DB) ────────────────────────────
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    debugPrint('DEBUG: appUserProvider - No Supabase user found.');
    return null;
  }

  debugPrint(
      'DEBUG: appUserProvider - Supabase user found (UID: ${user.id}), fetching profile...');
  try {
    final data =
        await _supabase.from('profiles').select().eq('id', user.id).single();

    debugPrint('DEBUG: appUserProvider - Profile found! Role: ${data['role']}');
    return AppUser.fromMap(user.id, data);
  } catch (e) {
    debugPrint('DEBUG: appUserProvider - ERROR fetching profile: $e');
    // Profile might not exist yet (trigger delay), retry once
    await Future.delayed(const Duration(seconds: 1));
    try {
      final data =
          await _supabase.from('profiles').select().eq('id', user.id).single();
      return AppUser.fromMap(user.id, data);
    } catch (e2) {
      debugPrint('DEBUG: appUserProvider - Retry also failed: $e2');
      return null;
    }
  }
});

// ── Auth Repository ─────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

class AuthRepository {
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

  /// Google Sign-In → Supabase Auth
  Future<AppUser?> signInWithGoogle() async {
    debugPrint('DEBUG: Starting Google Sign-In...');

    if (kIsWeb) {
      // Web: Use Supabase OAuth redirect
      debugPrint('DEBUG: Web platform detected. Using Supabase OAuth...');

      // Redirect back to the current web app URL after auth
      // In dev this is typically http://localhost:<port>
      final redirectUrl = Uri.base.origin;
      debugPrint('DEBUG: OAuth redirect URL: $redirectUrl');

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
      // On web, this redirects — the auth state listener will pick up the session
      return null;
    } else {
      // Mobile: Native Google Sign-In → Supabase signInWithIdToken
      debugPrint(
          'DEBUG: Mobile/Desktop platform detected. Using native google_sign_in...');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('DEBUG: Google Sign-In canceled by user.');
        return null;
      }

      debugPrint('DEBUG: Google User retrieved: ${googleUser.email}');
      final googleAuth = await googleUser.authentication;
      debugPrint('DEBUG: Google Auth tokens retrieved.');

      // Sign in to Supabase with the Google ID token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      final user = response.user;
      debugPrint('DEBUG: Supabase Auth success for UID: ${user?.id}');

      if (user == null) return null;

      // Check if profile exists (should be auto-created by trigger)
      try {
        final data = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        debugPrint('DEBUG: Profile found with role: ${data['role']}');
        return AppUser.fromMap(user.id, data);
      } catch (e) {
        // Profile might not exist yet if trigger hasn't fired
        debugPrint('DEBUG: Profile not found, creating manually...');
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'email': user.email ?? '',
          'display_name':
              user.userMetadata?['full_name'] ?? googleUser.displayName ?? '',
          'photo_url': user.userMetadata?['avatar_url'] ?? googleUser.photoUrl,
          'role': 'user',
          'created_at': DateTime.now().toIso8601String(),
        });

        final data = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        return AppUser.fromMap(user.id, data);
      }
    }
  }

  /// Email OTP Sign-In (magic link for clients without Google)
  Future<void> sendEmailLink(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'com.eventframe.app://login-callback/',
    );
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
