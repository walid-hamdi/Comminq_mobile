import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/helpers.dart';
import 'package:comminq/utils/secure_storage.dart';
import '../../../services/user_service.dart';
import '../../../utils/dialog_utils.dart';
import '../../../widgets/common/auth_button.dart';
import '../../../widgets/common/auth_link.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/custom_title_text.dart';
import '../../../widgets/google_button/google_button.dart';

class LoginFormValues {
  String email;
  String password;

  LoginFormValues({
    required this.email,
    required this.password,
  });
}

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
  final TokenManager tokenManager = TokenManager();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Perform login logic
      String email = _emailController.text;
      String password = _passwordController.text;
      LoginFormValues formValues =
          LoginFormValues(email: email, password: password);

      _loginUser(formValues);
    }
  }

  Future<bool> _checkInternetConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _loginUser(LoginFormValues formValues) async {
    final isConnected = await _checkInternetConnectivity();
    if (!isConnected) {
      if (mounted) {
        showErrorDialog(
          context: context,
          title: "No Internet Connection",
          content: "Please check your internet connection and try again.",
        );
      }
      return;
    }

    try {
      final data = {
        'email': formValues.email,
        'password': formValues.password,
      };

      setState(() {
        isLoading = true;
      });

      final response = await userHttpService.login(data);

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = extractFromResponse(response.data);
        final String token = result['token'];

        if (token.isNotEmpty) {
          await tokenManager.saveToken(token);
          if (mounted) {
            navigateToRoute(context, Routes.home);
          }
        } else {
          debugPrint('Token not found in the response');
        }
      } else {
        debugPrint('Login failed with status code ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _hideKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ));

    return GestureDetector(
      onTap: _hideKeyboard,
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
                    const CustomTitleText(text: '🔐 Unlock the Comminq'),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      },
                      showSuffixIcon: false,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
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
                    AuthButton(
                      onPressed: isLoading ? null : _submitForm,
                      isLoading: isLoading,
                      label: 'Sign in',
                    ),
                    const SizedBox(height: 16),
                    !isLoading ? const GoogleButton() : Container(),
                    const SizedBox(height: 16),
                    !isLoading
                        ? TextButton(
                            onPressed: () {
                              // Handle forgot password
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
                              navigateToRoute(context, Routes.register);
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
}
