import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/auth_provider.dart';
import '../domain/app_user.dart';

/// After login, reads the user's role from the database and redirects to
/// the appropriate portal without showing any UI.
class RoleGatePage extends ConsumerWidget {
  const RoleGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(appUserProvider);

    return userAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(body: SizedBox());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          switch (user.role) {
            case UserRole.admin:
              context.go('/admin');
            case UserRole.photographer:
              context.go('/photographer');
            case UserRole.user:
              context.go('/event');
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
