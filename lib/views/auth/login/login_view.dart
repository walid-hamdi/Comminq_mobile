import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/helpers.dart';
import 'package:comminq/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  void _loginUser(LoginFormValues formValues) {
    final data = {
      'email': formValues.email,
      'password': formValues.password,
    };

    setState(() {
      isLoading = true;
    });

    final TokenManager tokenManager = TokenManager();

    try {
      userHttpService.login(data).then((response) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> result =
              extractFromResponse(response.data);
          final String token = result['token'];

          if (token.isNotEmpty) {
            tokenManager.saveToken(token).then((_) {
              navigateToRoute(context, Routes.home);
            }).catchError((error) {
              debugPrint('Error writing token to secure storage: $error');
            });
          } else {
            // Handle missing token error
            debugPrint('Token not found in the response');
          }
        } else {
          // Handle login error
          debugPrint('Login failed with status code ${response.statusCode}');
        }
      }).catchError((error) {
        final Map<String, dynamic> result =
            extractFromResponse(error.response?.data);
        final String errorMessage = result['error'];
        showErrorDialog(
          context: context,
          title: "Login Error",
          content: errorMessage,
        );

        Sentry.captureException(error);
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    } catch (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
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
                    const SizedBox(height: 100),
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
                    TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.blue.shade200),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthLink(
                      isLoading: isLoading,
                      message: 'New to Comminq? ',
                      linkText: 'Join now',
                      onLinkPressed: () {
                        navigateToRoute(context, Routes.register);
                      },
                    ),
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
