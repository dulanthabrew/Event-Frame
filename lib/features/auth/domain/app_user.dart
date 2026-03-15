enum UserRole { admin, photographer, user }

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'] as String,
      displayName: map['display_name'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] as String),
        orElse: () => UserRole.user,
      ),
      photoUrl: map['photo_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'display_name': displayName,
        'role': role.name,
        'photo_url': photoUrl,
        'created_at': createdAt.toIso8601String(),
      };

  bool get isAdmin => role == UserRole.admin;
  bool get isPhotographer => role == UserRole.photographer;
  bool get isUser => role == UserRole.user;
}
