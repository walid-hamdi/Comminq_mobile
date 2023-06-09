import 'dart:async';

import 'package:comminq/views/auth/login/login_view.dart';
import 'package:comminq/views/auth/register/register_view.dart';
import 'package:comminq/views/startup/splash_screen_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../views/auth/profile/profile_view.dart';
import '../views/home/home_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivityPlus;
  ConnectivityResult currentConnectivity = ConnectivityResult.none;
  bool isConnectedToInternet = true;
  bool isInternetUnstable = false;

  @override
  void initState() {
    super.initState();
    connectivityPlus = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        currentConnectivity = result;
        isConnectedToInternet = result != ConnectivityResult.none;
        isInternetUnstable =
            result == ConnectivityResult.none ? false : isInternetUnstable;
      });
    });

    checkInternetUnstable();
  }

  @override
  void dispose() {
    super.dispose();
    connectivityPlus.cancel();
  }

  String getConnectivityMessage() {
    if (isInternetUnstable) {
      return 'Internet Connection Unstable';
    }

    switch (currentConnectivity) {
      case ConnectivityResult.none:
        return 'No Internet Connection';
      case ConnectivityResult.wifi:
        return 'Connected to Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Connected to Mobile Data';
      default:
        return '';
    }
  }

  void checkInternetUnstable() async {
    ConnectivityResult previousResult = ConnectivityResult.none;
    int consecutiveChanges = 0;

    await Future.delayed(Duration.zero); // Delay to avoid setState during build

    connectivityPlus.onData((ConnectivityResult result) {
      if (result != previousResult) {
        consecutiveChanges++;
        if (consecutiveChanges >= 2 && consecutiveChanges <= 4) {
          setState(() {
            isInternetUnstable = true;
          });
        } else if (consecutiveChanges > 4) {
          setState(() {
            isInternetUnstable = false;
          });
          consecutiveChanges = 0;
        }
      } else {
        consecutiveChanges = 0;
      }

      previousResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comminq',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splashScreen,
      routes: {
        Routes.splashScreen: (context) => const SplashScreenView(),
        Routes.home: (context) => const HomeView(),
        Routes.login: (context) => const LoginView(),
        Routes.register: (context) => const RegisterView(),
        Routes.profile: (context) => const ProfileView(),
      },
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: child!),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Visibility(
                  visible: !isConnectedToInternet,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.red,
                    child: Text(
                      getConnectivityMessage(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
