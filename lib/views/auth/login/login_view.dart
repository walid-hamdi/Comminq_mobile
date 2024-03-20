import 'package:comminq/utils/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../utils/secure_storage.dart';
import '../../../services/internet_connectivity.dart';
import '../../../utils/dialog_utils.dart';
import '../../../widgets/common/auth_button.dart';
import '../../../widgets/common/auth_link.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/custom_title_text.dart';
import '../../../widgets/google_button/google_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    const CustomTitleText(
                      fontSize: 18,
                      text: '🔐 Unlock the Comminq',
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      enable: !isLoading,
                      controller: _emailController,
                      labelText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        } else if (!isValidEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      showSuffixIcon: false,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      enable: !isLoading,
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    !isLoading
                        ? AuthButton(
                            onPressed: isLoading ? null : _submitForm,
                            isLoading: isLoading,
                            label: 'Sign in',
                          )
                        : Container(),
                    const SizedBox(height: 16),
                    GoogleButton(
                      onPressed: isLoading ? null : _handleGoogleButtonPress,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 16),
                    !isLoading
                        ? TextButton(
                            onPressed: () {
                              pushToRoute(context, Routes.resetPassword);
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(color: Colors.blue.shade200),
                            ),
                          )
                        : Container(),
                    const SizedBox(height: 16),
                    !isLoading
                        ? AuthLink(
                            message: 'New to Comminq? ',
                            linkText: 'Join now',
                            onLinkPressed: () {
                              pushToRoute(context, Routes.register);
                            },
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      InternetConnectivity.checkConnectivity(context).then((isConnected) {
        if (isConnected) {
          final TokenManager tokenManager = TokenManager();
          setState(() {
            isLoading = true;
          });

          authService.login({
            'email': _emailController.text,
            'password': _passwordController.text,
          }).then((response) {
            if (response.statusCode == 200) {
              if (response.data['token'].isNotEmpty) {
                tokenManager.saveToken(response.data['token']).then((_) {
                  navigateToRoute(context, Routes.home);
                }).catchError((error) {
                  debugPrint('Error writing token to secure storage: $error');
                  showErrorDialog(
                    context: context,
                    title: "Login Error",
                    content: 'Error writing token to secure storage: $error',
                  );
                });
              } else {
                debugPrint('Token not found in the response');
                showErrorDialog(
                  context: context,
                  title: "Login Error",
                  content: 'Token not found in the response',
                );
              }
            }
          }).catchError((error, stackTrace) {
            showErrorDialog(
              context: context,
              title: "Login Error",
              content: error.response.data['error'],
            );
            Sentry.captureException(error, stackTrace: stackTrace);
          }).whenComplete(() {
            setState(() {
              isLoading = false;
            });
          });
        }
      });
    }
  }

  // todo : should reduce the repeat code
  void _handleGoogleButtonPress() {
    InternetConnectivity.checkConnectivity(context).then((isConnected) async {
      if (isConnected) {
        final TokenManager tokenManager = TokenManager();
        try {
          final googleSignIn = GoogleSignIn();
          final result = await googleSignIn.signIn();
          final googleKey = await result?.authentication;

          if (googleKey != null) {
            setState(() {
              isLoading = true;
            });

            authService.googleLogin(googleKey.accessToken!).then((response) {
              if (response.statusCode == 200) {
                if (response.data['token'].isNotEmpty) {
                  tokenManager.saveToken(response.data['token']).then((value) {
                    if (mounted) {
                      navigateToRoute(context, Routes.home);
                    }
                  });
                }
              }
            }).catchError((error, stackTrace) {
              showErrorDialog(
                context: context,
                title: "Login error",
                content: '$error stackTrace: $stackTrace',
              );

              Sentry.captureException(error, stackTrace: stackTrace);
            }).whenComplete(() {
              setState(() {
                isLoading = false;
              });
            });
          }
        } catch (error, stackTrace) {
          if (mounted) {
            showErrorDialog(
              context: context,
              title: "Login with Google error",
              content: error.toString(),
            );
          }
          debugPrint('Stacktrace$error');
          Sentry.captureException(error, stackTrace: stackTrace);
        }
      }
    });
  }
}
