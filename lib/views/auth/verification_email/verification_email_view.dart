import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/common/loading_indicator.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final email = arguments['email'] as String;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
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
                const SizedBox(height: 18),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _openMail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text(
                      'Check your email inbox',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _resendVerificationEmail(email),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: !_isLoading
                        ? const Text(
                            'Resend verification email',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          )
                        : const LoadingIndicator(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _refresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black12,
                    ),
                    child: !_isLoading
                        ? const Text(
                            'Refresh',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          )
                        : const LoadingIndicator(),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: !_isLoading
                        ? const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          )
                        : const LoadingIndicator(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _refresh() {
    InternetConnectivity.checkConnectivity(context).then((isConnected) {
      if (isConnected) {
        setState(() {
          _isLoading = true;
        });
        userHttpService.profile().then((response) {
          if (response.statusCode == 200) {
            if (response.data['isVerified'] == true) {
              navigateToRoute(context, Routes.home);
            }
          }
        }).catchError((error) {
          if (error.response.data['error'] ==
              'Email is not verified. Please verify your email.') {
            _resendVerificationEmail(error.response.data['email']);
          }
        }).whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  void _openMail() async {
    const String mailToUrl = 'https://mail.google.com/mail/u/0/#inbox';
    try {
      setState(() {
        _isLoading = true;
      });
      await launchUrl(
        Uri.parse(
          mailToUrl,
        ),
      );
    } catch (error, stackTracer) {
      Sentry.captureException(error, stackTrace: stackTracer);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resendVerificationEmail(email) {
    InternetConnectivity.checkConnectivity(context).then((isConnected) async {
      if (isConnected) {
        setState(() {
          _isLoading = true;
        });
        userHttpService
            .resendVerificationEmail({'email': email}).then((response) {
          if (response.statusCode == 200) {
            if (response.data['message'] ==
                'Verification email resent successfully') {
              showErrorDialog(
                context: context,
                title: "Verification Email Sent",
                content:
                    "A verification link has been sent to your email inbox. Please check your email to complete the verification process.",
              );
            }
          }
        }).catchError((error, stackTrace) {
          showErrorDialog(
            context: context,
            title: "Error send verification link.",
            content: error.response.data['error'],
          );
          Sentry.captureException(error, stackTrace: stackTrace);
        }).whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  void _logout() {
    try {
      InternetConnectivity.checkConnectivity(context).then((isConnected) async {
        if (isConnected) {
          final secureStorage = TokenManager();
          setState(() {
            _isLoading = true;
          });
          await GoogleSignIn().signOut();
          await secureStorage.deleteToken();
          if (mounted) {
            navigateToRoute(context, Routes.login);
          }
        }
      });
    } catch (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
