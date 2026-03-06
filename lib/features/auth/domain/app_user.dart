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
      displayName: map['displayName'] as String,
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] as String),
        orElse: () => UserRole.user,
      ),
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'role': role.name,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  bool get isAdmin => role == UserRole.admin;
  bool get isPhotographer => role == UserRole.photographer;
  bool get isUser => role == UserRole.user;
}
