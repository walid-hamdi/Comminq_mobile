import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// import '../utils/constants.dart';
// import '../utils/helpers.dart';
import '../utils/secure_storage.dart';
// import 'user_service.dart';

class ApiInterceptors extends Interceptor {
  final TokenManager _tokenManager;
  ApiInterceptors() : _tokenManager = TokenManager();

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenManager.getToken();
    debugPrint("token from Interceptor: $token");

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}

class HttpService<TProfile, TAuth> {
  final String endpoint;
  final Dio _client;

  HttpService(this.endpoint) : _client = Dio() {
    _client.interceptors.add(ApiInterceptors());
  }

  Future<Response<dynamic>> profile() async {
    return await _client.get<dynamic>('$endpoint/profile');
  }

  Future<Response<dynamic>> updateProfile(String? id, dynamic data,
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

    return await _client.patch<dynamic>(
      '$endpoint/$id',
      data: formData,
    );
  }

  Future<Response<TAuth>> login(Map<String, dynamic> data) {
    return _client.post<TAuth>('$endpoint/login', data: data);
  }

  Future<Response<TAuth>> googleLogin(String accessToken) {
    final data = {
      'access_token': accessToken,
    };

    debugPrint("EndPoint $endpoint");

    return _client.post<TAuth>('$endpoint/google-login', data: data);
  }

  Future<Response<TAuth>> register(Map<String, dynamic> data) {
    return _client.post<TAuth>('$endpoint/register', data: data);
  }

  Future<Response> logout() {
    return _client.get('$endpoint/logout');
  }

  Future<Response<dynamic>> resendVerificationEmail(String email) async {
    final data = {'email': email};
    return await _client.post<dynamic>('$endpoint/resend-verification-email',
        data: data);
  }

  Future<Response<dynamic>> forgotPassword(String email) async {
    final data = {'email': email};
    return await _client.post<dynamic>('$endpoint/forgot-password', data: data);
  }

  Future<Response<dynamic>> verifyCode(String email, String code) async {
    final data = {'email': email, 'code': code};
    return await _client.post<dynamic>('$endpoint/verify-code', data: data);
  }

  Future<Response<dynamic>> changePasswordByCode(
      String code, String newPassword) async {
    final data = {'code': code, 'newPassword': newPassword};
    return await _client.post<dynamic>('$endpoint/password/reset', data: data);
  }

  Future<Response<dynamic>> changePassword(
      String? id, String currentPassword, String newPassword) async {
    final data = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };

    return await _client.put<dynamic>(
      '$endpoint/$id/password',
      data: data,
    );
  }

  // Factory method to create an instance of HttpService
  static HttpService<TProfile, TAuth> create<TProfile, TAuth>(String endpoint) {
    return HttpService<TProfile, TAuth>(endpoint);
  }
}
