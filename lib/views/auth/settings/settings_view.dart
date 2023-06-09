import "package:flutter/material.dart";

import "../../../models/user_profile.dart";

class SettingsView extends StatefulWidget {
  final UserProfile? userProfile;
  final Function onUpdateProfile;

  const SettingsView({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
  }) : super(key: key);

  @override
  createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userProfile?.username);
    _emailController = TextEditingController(text: widget.userProfile?.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    // final newUsername = _usernameController.text.trim();
    // final newEmail = _emailController.text.trim();

    // Perform the update profile operation here
    // You can use the `widget.onUpdateProfile` callback to notify the parent widget
    // about the updated profile

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Updated'),
          content: const Text('Your profile has been updated successfully.'),
          actions: [
            ElevatedButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
