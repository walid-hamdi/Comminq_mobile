import 'package:flutter/material.dart';

import 'loading_indicator.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final Color backgroundColor;

  const AuthButton({
    Key? key,
    required this.onPressed,
    required this.isLoading,
    required this.label,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
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
            child: Text(label),
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
