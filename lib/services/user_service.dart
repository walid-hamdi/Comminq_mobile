import '../environment.dart';
import "./http_service.dart";

class ResponseProfile {
  final String id;
  final String name;
  final String email;
  final String password;
  final String picture;

  ResponseProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.picture,
  });

  factory ResponseProfile.fromJson(Map<String, dynamic> json) {
    return ResponseProfile(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      picture: json['picture'] ?? '',
    );
  }
}

const String endpoint = Environment.endPoint;
final userHttpService =
    HttpService.create<ResponseProfile, String>("${endpoint}api/user");
