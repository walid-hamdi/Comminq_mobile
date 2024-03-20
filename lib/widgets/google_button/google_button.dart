import 'package:flutter/material.dart';

import '../common/loading_indicator.dart';

class GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  const GoogleButton({
    Key? key,
    required this.onPressed,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(10.0),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !isLoading,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/google_icon.png',
                  width: 24.0,
                  height: 24.0,
                ),
                const SizedBox(width: 8.0),
                const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: const LoadingIndicator(),
          ),
        ],
      ),
    );
  }
}
