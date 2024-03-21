import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../views/auth/login/login_view.dart';
import '../views/auth/register/register_view.dart';
import '../views/auth/verification_email/verification_email_view.dart';
import '../views/auth/reset_password/reset_password_view.dart';
import '../views/home/home_view.dart';
import '../views/startup/splash_screen_view.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivityPlus;
  ConnectivityResult currentConnectivity = ConnectivityResult.none;
  bool isConnectedToInternet = true;

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      setState(() {
        currentConnectivity = result;
        isConnectedToInternet = result != ConnectivityResult.none;
      });
    });

    connectivityPlus = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        currentConnectivity = result;
        isConnectedToInternet = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    connectivityPlus.cancel();
  }

  String getConnectivityMessage() {
    return isConnectedToInternet ? '' : 'No Internet Connection';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      title: 'Comminq',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splashScreen,
      routes: {
        Routes.splashScreen: (context) => const SplashScreenView(),
        Routes.home: (context) => const HomeView(),
        Routes.login: (context) => const LoginView(),
        Routes.register: (context) => const RegisterView(),
        Routes.verifiedEmail: (context) => const VerificationEmailView(),
        Routes.resetPassword: (context) => const ResetPasswordView(),
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
                    color: Colors.red.withOpacity(0.8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 16.0,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          getConnectivityMessage(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
