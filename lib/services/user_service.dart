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
}

final String endpoint = Environment.endPoint;
final userHttpService = create<ResponseProfile, String>("${endpoint}api/user");

