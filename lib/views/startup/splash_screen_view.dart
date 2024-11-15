import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/constants.dart';
import '../../utils/secure_storage.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
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
