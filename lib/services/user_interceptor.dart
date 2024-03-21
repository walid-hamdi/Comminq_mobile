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
