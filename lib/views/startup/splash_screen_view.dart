import 'dart:async';
import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/secure_storage.dart';
import 'package:flutter/material.dart';

import '../../utils/helpers.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  final TokenManager tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      // Home or login
      tokenManager.getToken().then((token) {
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
      body: Center(
        child: Image.asset(
          'assets/icons/icon.png',
          width: 250,
          height: 250,
        ),
      ),
    );
  }
}
