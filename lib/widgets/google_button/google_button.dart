import 'package:comminq/services/user_service.dart';
import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/environment.dart';
import '../../utils/secure_storage.dart';

class GoogleButton extends StatefulWidget {
  const GoogleButton({Key? key}) : super(key: key);

  @override
  createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  bool isLoading = false;

  void _handleButtonPress() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: Environment.clientId,
      );

      final result = await googleSignIn.signIn();

      final googleKey = await result?.authentication;

      if (googleKey != null) {
        setState(() {
          isLoading = true;
        });
        final TokenManager tokenManager = TokenManager();

        userHttpService.googleLogin(googleKey.accessToken!).then(
          (response) {
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
              debugPrint(
                  'Login with Google failed with status code ${response.statusCode}');
            }
          },
        ).whenComplete(() {
          setState(() {
            isLoading = false;
          });
        }).catchError((error) {
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
        });
      }
    } catch (error) {
      debugPrint('Error: $error');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login with Google Error'),
            content: Text(error.toString()),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handleButtonPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Button color
        foregroundColor: Colors.black, // Text color // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(12.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !isLoading,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ac_unit, color: Colors.blue),
                SizedBox(width: 8.0),
                Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
