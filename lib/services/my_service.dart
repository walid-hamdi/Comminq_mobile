import 'package:comminq/models/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class MyService {
  final Dio _dio = Dio();

  Future<String> fetchData() async {
    try {
      final response = await _dio.get(Environment.endPoint);
      debugPrint("${Environment.endPoint} Hello");

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['msg'] as String;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      throw Exception('Failed to connect to the server');
    }
  }
}
