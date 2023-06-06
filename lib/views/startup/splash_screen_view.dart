import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      // Home or login
      _secureStorage.read(key: 'token').then((token) {
        if (token != null) {
          navigateToRoute(context, Routes.home);
        } else {
          navigateToRoute(context, Routes.login);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.blue[600],
        child: Center(
          child: Image.asset('assets/icons/icon.png'),
        ),
      ),
    );
  }
}
