import 'package:flutter/material.dart';

import "../../services/my_service.dart";

class HomeView extends StatelessWidget {
  final MyService _myService = MyService();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: _myService.fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Text('Message from backend: ${snapshot.data}');
            }
          },
        ),
      ),
    );
  }
}
