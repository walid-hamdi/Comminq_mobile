import 'dart:io';

import 'package:dio/dio.dart';

import '../environment.dart';
import 'user_interceptor.dart';

class UserHttpService {
  final String endpoint;
  final Dio _client;

  UserHttpService(this.endpoint) : _client = Dio() {
    _client.interceptors.add(ApiInterceptors());
  }

  Future<Response<dynamic>> profile() {
    return _client.get('$endpoint/profile');
  }

  Future<Response<dynamic>> resendVerificationEmail(
      Map<String, dynamic> data) async {
    return _client.post('$endpoint/resend-verification-email', data: data);
  }

  Future<Response<dynamic>> changePassword(
      String? id, Map<String, dynamic> data) async {
    return await _client.put(
      '$endpoint/$id/password',
      data: data,
    );
  }

  Future<Response<dynamic>> updateProfile(String? id, Map<String, dynamic> data,
      {File? profilePicture}) async {
    FormData formData = FormData.fromMap(data);

    if (profilePicture != null) {
      formData.files.add(
        MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(profilePicture.path),
        ),
      );
    }

    return await _client.patch(
      '$endpoint/$id',
      data: formData,
    );
  }

  Future<Response<dynamic>> forgotPassword(Map<String, dynamic> data) async {
    return await _client.post('$endpoint/forgot-password', data: data);
  }

  Future<Response<dynamic>> verifyCode(Map<String, dynamic> data) async {
    return await _client.post('$endpoint/verify-code', data: data);
  }

  Future<Response<dynamic>> changePasswordByCode(
      Map<String, dynamic> data) async {
    return await _client.post('$endpoint/password/reset', data: data);
  }

  Future<Response<dynamic>> deleteProfile(String? id) async {
    return _client.delete('$endpoint/$id');
  }
}

// class ResponseProfile {
//   final String? id;
//   final String name;
//   final String email;
//   final String? password;
//   final String? picture;

//   ResponseProfile({
//     this.id,
//     required this.name,
//     required this.email,
//     this.password,
//     this.picture,
//   });

//   factory ResponseProfile.fromJson(Map<String, dynamic> json) {
//     return ResponseProfile(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       password: json['password'] ?? '',
//       picture: json['picture'] ?? '',
//     );
//   }
// }

final userHttpService = UserHttpService('${Environment.endPoint}/api/user');
