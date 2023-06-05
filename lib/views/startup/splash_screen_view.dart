import 'dart:async';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      // Home or login
      // if (true) {
      //   navigateToRoute(context, Routes.login);
      // } else {
      //   navigateToRoute(context, Routes.home);
      // }
      navigateToRoute(context, Routes.login);
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
