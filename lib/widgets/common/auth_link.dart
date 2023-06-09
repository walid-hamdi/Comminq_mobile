import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthLink extends StatelessWidget {
  final bool isLoading;
  final String message;
  final String linkText;
  final VoidCallback onLinkPressed;

  const AuthLink({
    Key? key,
    required this.isLoading,
    required this.message,
    required this.linkText,
    required this.onLinkPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: RichText(
        text: TextSpan(
          text: message,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          children: [
            TextSpan(
              text: linkText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = isLoading ? null : onLinkPressed,
            ),
          ],
        ),
      ),
    );
  }
}
