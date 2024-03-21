class UserProfile {
  final String id;
  final String username;
  final String email;
  final String picture;
  final bool? googleLogin;
  final bool? isVerified;

  UserProfile(
      {required this.id,
      required this.username,
      required this.email,
      required this.picture,
      this.googleLogin,
      this.isVerified});
}
