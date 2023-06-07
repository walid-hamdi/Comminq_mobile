import 'package:comminq/services/user_service.dart';
import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/helpers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../utils/dialog_utils.dart';
import '../../../utils/email_validator.dart';
import '../../../utils/secure_storage.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/google_button/google_button.dart';

class RegisterFormValues {
  String name;
  String email;
  String password;
  String confirmPassword;

  RegisterFormValues({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

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

  bool isLoading = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Perform registration logic
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;
      RegisterFormValues formValues = RegisterFormValues(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      // Call your registration API or perform any other registration-related actions here
      _registerUser(formValues);
    }
  }

  void _registerUser(RegisterFormValues formValues) {
    final data = {
      'name': formValues.name,
      'email': formValues.email,
      'password': formValues.password,
    };
    setState(() {
      isLoading = true;
    });
    final TokenManager tokenManager = TokenManager();

    userHttpService.register(data).then((response) {
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
        debugPrint('Register failed with status code ${response.statusCode}');
      }
    }).catchError((error) {
      final Map<String, dynamic> result =
          extractFromResponse(error.response?.data);

      final String errorMessage = result['error'];
      showErrorDialog(
        context: context,
        title: "Registration Error",
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode:
                  AutovalidateMode.always, // Enable continuous validation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 100),
                  const Text(
                    '📝 Join the Comminq Community',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
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
                      } else if (value.length < 6) {
                        return 'Password should be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12.0),
                    ),
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
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor:
                          isLoading ? Colors.grey.shade200 : Colors.blue,
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Visibility(
                          visible: !isLoading,
                          child: const Text('Sign up'),
                        ),
                        Visibility(
                          visible: isLoading,
                          child: const LoadingIndicator(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const GoogleButton(),
                  const SizedBox(height: 24),
                  Container(
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                navigateToRoute(context, Routes.login);
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
    );
  }
}
