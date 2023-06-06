import "package:comminq/models/environment.dart";

import "./http_service.dart";

class ResponseProfile {
  final String name;
  final String email;
  final String password;
  final String picture;

  ResponseProfile({
    required this.name,
    required this.email,
    required this.password,
    required this.picture,
  });

  factory ResponseProfile.fromJson(Map<String, dynamic> json) {
    return ResponseProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      picture: json['picture'] ?? '',
    );
  }
}

final String endpoint = Environment.endPoint;
final userHttpService =
    HttpService.create<ResponseProfile, String>("${endpoint}api/user");
