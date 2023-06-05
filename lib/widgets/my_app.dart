import 'package:comminq/views/auth/login/login_view.dart';
import 'package:comminq/views/auth/register/register_view.dart';
import 'package:comminq/views/startup/splash_screen_view.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../views/home/home_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comminq',
      // debugShowCheckedModeBanner: false,
      initialRoute: Routes.splashScreen,
      routes: {
        Routes.splashScreen: (context) => const SplashScreenView(),
        Routes.home: (context) => const HomeView(),
        Routes.login: (context) => const LoginView(),
        Routes.register: (context) => const RegisterView(),
      },
    );
  }
}
