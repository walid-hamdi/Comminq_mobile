import 'dart:io';

import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String profilePicture;

  const CustomAvatar({
    Key? key,
    required this.profilePicture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: Colors.white,
        width: 50,
        height: 50,
        child: profilePicture.isEmpty
            ? const Icon(
                Icons.person_add_alt_1,
                size: 30,
                color: Colors.grey,
              )
            : profilePicture.startsWith('http')
                ? Image.network(
                    profilePicture,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(profilePicture),
                    fit: BoxFit.cover,
                  ),
      ),
    );
  }
}
