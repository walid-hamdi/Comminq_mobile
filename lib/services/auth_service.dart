import 'package:dio/dio.dart';

import '../environment.dart';

class AuthService {
  final String endpoint;
  final Dio _client;

  AuthService(this.endpoint) : _client = Dio();

  Future<Response<dynamic>> login(Map<String, dynamic> data) {
    return _client.post('$endpoint/login', data: data);
  }

  Future<Response<dynamic>> register(Map<String, dynamic> data) {
    return _client.post('$endpoint/register', data: data);
  }

  Future<Response<dynamic>> googleLogin(String accessToken) {
    final data = {
      'access_token': accessToken,
    };

    return _client.post('$endpoint/google-login', data: data);
  }

  Future<Response> logout() {
    return _client.get('$endpoint/logout');
  }

  // Future<Response<dynamic>> forgotPassword(String email) async {
  //   final data = {'email': email};
  //   return await _client.post<dynamic>('$endpoint/forgot-password', data: data);
  // }

  // Future<Response<dynamic>> verifyCode(String email, String code) async {
  //   final data = {'email': email, 'code': code};
  //   return await _client.post<dynamic>('$endpoint/verify-code', data: data);
  // }
}

final authService = AuthService('${Environment.endPoint}/api/user');
