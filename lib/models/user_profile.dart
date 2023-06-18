class UserProfile {
  final String? id;
  final String username;
  final String email;
  final String? password;
  final String? picture;

  UserProfile({
    this.id,
    required this.username,
    required this.email,
    this.password,
    this.picture,
  });
}
