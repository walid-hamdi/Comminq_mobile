import 'package:flutter/material.dart';

import '../../../services/user_service.dart';
import '../../../utils/dialog_utils.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = true;
  String _profileUsername = '';
  String _profileEmail = '';
  String _profilePassword = '';
  String _profilePicture = '';
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await userHttpService.profile();
      setState(() {
        _profileUsername = response.name;
        _profileEmail = response.email;
        _profilePassword = response.password;
        _profilePicture = response.picture;
        _isLoading = false;
      });
      print("Password: $_profilePassword");
    } catch (error) {
      final String errorMessage = error.toString();
      showErrorDialog(
        context: context,
        title: "Retrieve Profile Error",
        content: errorMessage,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteAccountModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform delete account operation
                _deleteAccount();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set background color to red
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAccount() {
    // Implement your delete account logic here
    // This method will be called when the user confirms deleting the account
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(_profilePicture),
                          radius: 50,
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle avatar click
                          },
                          child: const Icon(Icons.edit, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Name:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _profileUsername,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Email:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _profileEmail,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(
                        Icons.lock,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Password:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _profilePassword,
                            obscureText: !_isPasswordVisible,
                            readOnly: true,
                            decoration: InputDecoration(
                              suffixIcon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showDeleteAccountModal(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Account'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                      backgroundColor:
                          Colors.red, // Set background color to red
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
