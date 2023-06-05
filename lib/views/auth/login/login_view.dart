import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/helpers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../services/user_service.dart';
import '../../../widgets/googe_button/google_button.dart';

class LoginFormValues {
  String email;
  String password;

  LoginFormValues({
    required this.email,
    required this.password,
  });
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

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

      // Call your login API or perform any other login-related actions here
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

    userHttpService.login(data).then((response) {
      if (response.statusCode == 200) {
        navigateToRoute(context, Routes.home);
      } else {
        // Handle login error
        debugPrint('Login failed with status code ${response.statusCode}');
      }
    }).catchError((error) {
      debugPrint("ERROR: ${error.response}");

      final errorMessage = error.response.toString();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Text(
                  '🔐 Unlock the Comminq',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email address'),
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
                  decoration: const InputDecoration(labelText: 'Password'),
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
                    backgroundColor: isLoading
                        ? Colors.grey
                        : Colors
                            .blue, // Button color when not loading vs loading
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
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: 'New to Comminq? ',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
