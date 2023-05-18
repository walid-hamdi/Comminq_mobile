import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../views/splash_screen/splash_screen_view.dart';
import '../views/home_screen/home_screen_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comminq',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splashScreen,
      routes: {
        Routes.splashScreen: (context) => const SplashScreenView(),
        Routes.home: (context) => const HomeView(),
      },
    );
  }
}
