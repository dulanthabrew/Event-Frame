import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_theme.dart';
import '../../auth/domain/app_user.dart';
import '../data/user_repository.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserListItem(user: user);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _UserListItem extends ConsumerWidget {
  final AppUser user;
  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM d, y').format(user.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(
          user.displayName,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: GoogleFonts.inter(fontSize: 12)),
            Text('Joined on $dateStr',
                style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
          ],
        ),
        trailing: _RoleSelector(user: user),
      ),
    );
  }
}

class _RoleSelector extends ConsumerWidget {
  final AppUser user;
  const _RoleSelector({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(user.role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getRoleColor(user.role).withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: user.role,
          icon: const Icon(Icons.arrow_drop_down, size: 16),
          style: GoogleFonts.inter(
            color: _getRoleColor(user.role),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          onChanged: (newRole) {
            if (newRole != null && newRole != user.role) {
              ref
                  .read(userRepositoryProvider)
                  .updateUserRole(user.uid, newRole);
            }
          },
          items: UserRole.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role.name.toUpperCase()),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppTheme.primary;
      case UserRole.photographer:
        return AppTheme.accent;
      case UserRole.user:
        return Colors.grey;
    }
  }
}
