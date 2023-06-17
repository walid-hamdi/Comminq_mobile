import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? profilePicture;
  final bool hasProfilePicture;

  const CustomAvatar({
    Key? key,
    required this.profilePicture,
    required this.hasProfilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: Colors.white,
        child: hasProfilePicture
            ? Image.network(
                profilePicture!,
              )
            : const Icon(
                Icons.person_add_alt_1,
                size: 30,
                color: Colors.grey,
              ),
      ),
    );
  }
}
