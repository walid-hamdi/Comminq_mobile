import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/internet_connectivity.dart';
import '../../../services/user_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/helpers.dart';
import '../../../utils/secure_storage.dart';

class VerificationEmailView extends StatefulWidget {
  const VerificationEmailView({super.key});

  @override
  State<VerificationEmailView> createState() => _VerificationEmailViewState();
}

class _VerificationEmailViewState extends State<VerificationEmailView> {
  final _secureStorage = TokenManager();
  StreamSubscription? _profileSubscription;

  void _resendVerificationEmail(context, email) {
    InternetConnectivity.checkConnectivity(context).then((isConnected) {
      if (isConnected) {
        _performResendVerificationEmail(context, email);
      }
    });
  }

  void _performResendVerificationEmail(context, email) {
    userHttpService.resendVerificationEmail(email).then((response) {
      final responseData = response.data;
      final successMessage = responseData['message'];

      showErrorDialog(
        context: context,
        title: "Resent Verification",
        content: successMessage,
      );
    }).catchError((error) {
      String errorMessage = 'An error occurred. Please try again later.';

      if (error is DioError) {
        final response = error.response;
        if (response != null &&
            response.data != null &&
            response.data['message'] != null) {
          errorMessage = response.data['message'];
        }
      }
      showErrorDialog(
        context: context,
        title: "Resent Verification Email Error",
        content: "$errorMessage. Please Check Your Email!",
      );
    });
  }

  void _openMail() {
    const String mailToUrl = 'mailto:';
    launchUrl(Uri.parse(mailToUrl));
  }

  void _logout(context) {
    _secureStorage.deleteToken().then((_) {
      navigateToRoute(context, Routes.login);
    }).catchError((error) {
      debugPrint('Error deleting token from secure storage: $error');
    });
  }

// todo: When the screen of email verification on pause and on reload check about the profile api

  @override
  void initState() {
    super.initState();
    InternetConnectivity.checkConnectivity(context).then((isConnected) {
      if (isConnected) {
        _listenToProfile();
      }
    });
  }

  @override
  void dispose() {
    _profileSubscription!.cancel();
    super.dispose();
  }

  void _listenToProfile() {
    // todo: it should have solution to reduce the loading times to the server
    _profileSubscription =
        Stream.periodic(const Duration(seconds: 2)).listen((_) {
      userHttpService.profile().then((response) {
        final responseData = response.data;
        final isVerified = responseData['isVerified'];
        if (isVerified == true) {
          navigateToRoute(context, Routes.home);
        }
      }).catchError((error) {
        // Handle error
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ));

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Text(
                  '🔐 Verify your Email',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _openMail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Check Your Mail',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _resendVerificationEmail(
                    context,
                    email,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Resend Verification Email',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
