import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/helpers.dart';
import 'package:comminq/utils/secure_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../services/user_service.dart';
import '../../../utils/dialog_utils.dart';
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

    userHttpService.login(data).then((response) {
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = extractFromResponse(response.data);
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
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
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
                    const Text(
                      '🔐 Unlock the Comminq',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLoading ? Colors.grey : Colors.blue,
                        padding: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Visibility(
                            visible: !isLoading,
                            child: const Text('Sign in'),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: const CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const GoogleButton(),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      alignment: Alignment.center,
                      child: RichText(
                        text: TextSpan(
                          text: 'New to Comminq? ',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                          children: [
                            TextSpan(
                              text: 'Join now',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  navigateToRoute(context, Routes.register);
                                },
                            ),
                          ],
                        ),
                      ),
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
