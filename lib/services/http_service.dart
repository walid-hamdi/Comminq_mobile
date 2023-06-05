import 'package:dio/dio.dart';

class HttpService<TProfile, TAuth> {
  final String endpoint;
  final Dio _client;

  HttpService(this.endpoint) : _client = Dio();

  Future<Response<TProfile>> profile() {
    return _client.get<TProfile>(
      '$endpoint/profile',
      // options: Options(
      //   withCredentials: true,
      // ),
    );
  }

  Future<Response<TAuth>> login(Map<String, dynamic> data) {
    return _client.post<TAuth>(
      '$endpoint/login',
      data: data,
      // options: Options(
      //   withCredentials: true,
      // ),
    );
  }

  Future<Response<TAuth>> googleLogin(String accessToken) {
    final data = {
      'access_token': accessToken,
    };

    return _client.post<TAuth>(
      '$endpoint/google-login',
      data: data,
      // options: Options(
      //   withCredentials: true,
      // ),
    );
  }

  Future<Response<TAuth>> register(Map<String, dynamic> data) {
    return _client.post<TAuth>(
      '$endpoint/register',
      data: data,
      // options: Options(
      //   withCredentials: true,
      // ),
    );
  }

  Future<Response> logout() {
    return _client.get(
      '$endpoint/logout',
      // options: Options(
      //   withCredentials: true,
      // ),
    );
  }
}

create<TProfile, TAuth>(String endpoint) =>
    HttpService<TProfile, TAuth>(endpoint);
