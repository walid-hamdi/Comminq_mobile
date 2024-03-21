import 'package:flutter/material.dart';

import 'loading_indicator.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final Color backgroundColor;
  final bool enable;

  const AuthButton({
    Key? key,
    required this.onPressed,
    required this.isLoading,
    required this.label,
    this.backgroundColor = Colors.blue,
    this.enable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enable ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoading ? Colors.grey.shade200 : backgroundColor,
        padding: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: !isLoading,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
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
