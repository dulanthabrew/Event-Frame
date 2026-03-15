import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/role_gate_page.dart';

// Admin
import '../../features/admin/presentation/admin_dashboard_page.dart';
import '../../features/admin/presentation/studio_management_page.dart';
import '../../features/admin/presentation/membership_mgmt_page.dart';
import '../../features/admin/presentation/user_management_page.dart';

// Photographer
import '../../features/photographer/presentation/photographer_dashboard_page.dart';
import '../../features/photographer/presentation/event_list_page.dart';
import '../../features/photographer/presentation/event_create_page.dart';
import '../../features/photographer/presentation/client_management_page.dart';
import '../../features/photographer/presentation/photo_upload_page.dart';
import '../../features/photographer/presentation/subscription_page.dart';

// Client
import '../../features/client/presentation/event_code_entry_page.dart';
import '../../features/client/presentation/gallery_page.dart';
import '../../features/client/presentation/photo_viewer_page.dart';

import '../providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // While we are loading the initial auth state, don't redirect anywhere
      if (authState.isLoading && !authState.hasValue) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/gate';
      return null;
    },
    routes: [
      // Public
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

      // Role gate — reads Firestore role and redirects
      GoRoute(path: '/gate', builder: (_, __) => const RoleGatePage()),

      // ─── Admin ───────────────────────────────────
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'studios',
            builder: (_, __) => const StudioManagementPage(),
          ),
          GoRoute(
            path: 'plans',
            builder: (_, __) => const MembershipMgmtPage(),
          ),
          GoRoute(
            path: 'users',
            builder: (_, __) => const UserManagementPage(),
          ),
        ],
      ),

      // ─── Photographer ─────────────────────────────
      GoRoute(
        path: '/photographer',
        builder: (_, __) => const PhotographerDashboardPage(),
        routes: [
          GoRoute(path: 'events', builder: (_, __) => const EventListPage()),
          GoRoute(
            path: 'events/new',
            builder: (_, __) => const EventCreatePage(),
          ),
          GoRoute(
            path: 'events/:eventId/clients',
            builder: (_, state) =>
                ClientManagementPage(eventId: state.pathParameters['eventId']!),
          ),
          GoRoute(
            path: 'events/:eventId/upload',
            builder: (_, state) =>
                PhotoUploadPage(eventId: state.pathParameters['eventId']!),
          ),
          GoRoute(
            path: 'subscription',
            builder: (_, __) => const SubscriptionPage(),
          ),
        ],
      ),

      // ─── Client (Regular User) ────────────────────
      GoRoute(
        path: '/event',
        builder: (_, __) => const EventCodeEntryPage(),
      ),
      GoRoute(
        path: '/event/:code',
        builder: (_, state) =>
            EventCodeEntryPage(prefilledCode: state.pathParameters['code']),
      ),
      GoRoute(
        path: '/gallery/:eventId',
        builder: (_, state) =>
            GalleryPage(eventId: state.pathParameters['eventId']!),
        routes: [
          GoRoute(
            path: 'photo/:photoId',
            builder: (_, state) => PhotoViewerPage(
              eventId: state.pathParameters['eventId']!,
              photoId: state.pathParameters['photoId']!,
            ),
          ),
        ],
      ),
    ],
  );
});
