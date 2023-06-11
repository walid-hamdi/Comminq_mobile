import 'package:comminq/services/user_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../utils/secure_storage.dart';

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

  Future<ResponseProfile> profile() async {
    // try {
    final response =
        await _client.get<Map<String, dynamic>>('$endpoint/profile');

    final userProfileData = response.data;
    final userProfile = ResponseProfile.fromJson(userProfileData!);

    return userProfile;
  }

  Future<Response<TProfile>> updateProfile(
      String? id, Map<String, dynamic> data) {
    return _client.patch<TProfile>('$endpoint/$id', data: data);
  }

  Future<Response<TAuth>> login(Map<String, dynamic> data) {
    return _client.post<TAuth>('$endpoint/login', data: data);
  }

  Future<Response<TAuth>> googleLogin(String accessToken) {
    final data = {
      'access_token': accessToken,
    };

    return _client.post<TAuth>('$endpoint/google-login', data: data);
  }

  Future<Response<TAuth>> register(Map<String, dynamic> data) {
    return _client.post<TAuth>('$endpoint/register', data: data);
  }

  Future<Response> logout() {
    return _client.get('$endpoint/logout');
  }

  // Factory method to create an instance of HttpService
  static HttpService<TProfile, TAuth> create<TProfile, TAuth>(String endpoint) {
    return HttpService<TProfile, TAuth>(endpoint);
  }
}
