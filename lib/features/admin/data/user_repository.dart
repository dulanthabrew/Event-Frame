import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/domain/app_user.dart';

final _supabase = Supabase.instance.client;

class UserRepository {
  Future<List<AppUser>> getAllUsers() async {
    final rows = await _supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);

    return rows.map((row) => AppUser.fromMap(row['id'], row)).toList();
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _supabase.from('profiles').update({
      'role': role.name,
    }).eq('id', uid);
  }

  Future<void> deleteUser(String uid) async {
    // Delete the profile row (auth.users deletion requires service role / admin API)
    await _supabase.from('profiles').delete().eq('id', uid);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  return ref.watch(userRepositoryProvider).getAllUsers();
});
