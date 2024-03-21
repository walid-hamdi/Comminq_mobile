import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../services/auth_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/auth_link.dart';
import '../../../services/internet_connectivity.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/email_validator.dart';
import '../../../utils/secure_storage.dart';
import '../../../widgets/common/auth_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/custom_title_text.dart';
import '../../../widgets/google_button/google_button.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 16),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 10),
                    const CustomTitleText(
                      fontSize: 18,
                      text: '📝 Join the Comminq Community',
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      enable: !_isLoading,
                      controller: _nameController,
                      labelText: 'Name',
                      showSuffixIcon: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      enable: !_isLoading,
                      controller: _emailController,
                      labelText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      showSuffixIcon: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        } else if (!isValidEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      enable: !_isLoading,
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password should be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      enable: !_isLoading,
                      controller: _confirmPasswordController,
                      labelText: 'Password Confirm',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    AuthButton(
                      onPressed: _isLoading ? null : _submitForm,
                      isLoading: _isLoading,
                      label: "Sign up",
                    ),
                    const SizedBox(height: 14),
                    !_isLoading
                        ? GoogleButton(
                            onPressed: _handleGoogleButtonPress,
                            isLoading: _isLoading,
                          )
                        : Container(),
                    const SizedBox(height: 24),
                    !_isLoading
                        ? AuthLink(
                            message: 'Already have an account? ',
                            linkText: 'Sign in',
                            onLinkPressed: () {
                              navigateToRoute(context, Routes.login);
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
            _isLoading = true;
          });

          authService.register({
            'name': _nameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
          }).then((response) {
            if (response.statusCode == 200) {
              if (response.data['token'].isNotEmpty) {
                tokenManager.saveToken(response.data['token']).then((_) {
                  navigateToRoute(context, Routes.home);
                }).catchError((error) {
                  debugPrint('Error writing token to secure storage: $error');
                });
              } else {
                debugPrint('Token not found in the response');
              }
            } else {
              debugPrint(
                  'Register failed with status code ${response.statusCode}');
            }
          }).catchError((error, stackTrace) {
            showErrorDialog(
              context: context,
              title: "Registration Error",
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
              _isLoading = true;
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
                _isLoading = false;
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
