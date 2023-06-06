import 'package:comminq/services/user_service.dart';
import 'package:comminq/utils/constants.dart';
import 'package:comminq/utils/dialog_utils.dart';
import 'package:comminq/utils/helpers.dart';
import 'package:comminq/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/environment.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _secureStorage = TokenManager();
  bool isLoading = false;
  String? username;
  String? email;
  String? picture;
  List<String> rooms = ['Room 1', 'Room 2', 'Room 3', 'Room 4'];

  void _showProfileModal(BuildContext context) {
    setState(() {
      isLoading = true;
    });

    userHttpService.profile().then((response) {
      final profile = response;
      final profileUsername = profile.name;
      final profileEmail = profile.email;
      final profilePicture = profile.picture;

      debugPrint("profileUsername $profileUsername");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Profile'),
            content: isLoading
                ? const SizedBox(
                    width: 48, // Adjust the width as needed
                    height: 48, // Adjust the height as needed
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle avatar click
                          _showEditAvatarModal(context);
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(profilePicture),
                              radius: 50,
                            ),
                            const Icon(Icons.edit, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          // Handle username click
                          _showEditUsernameModal(context);
                        },
                        child: Text('Username: $profileUsername'),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle email click
                          _showEditEmailModal(context);
                        },
                        child: Text('Email: $profileEmail'),
                      ),
                      // Text('Followers: ${profile.followersCount}'),
                      // Text('Following: ${profile.followingCount}'),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      final String errorMessage = error.response.toString();
      showErrorDialog(
        context: context,
        title: "Retrieve Profile Error",
        content: errorMessage,
      );
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _performLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    _secureStorage.deleteToken().then((_) {
      final googleSignIn = GoogleSignIn(
        clientId: Environment.clientId,
      );
      googleSignIn.signOut().then((_) {
        navigateToRoute(context, Routes.login);
      });
    }).catchError((error) {
      debugPrint('Error deleting token from secure storage: $error');
    });
  }

  void _showEditAvatarModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Avatar'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form field or button to edit avatar
              Text('Edit Avatar'),
              // Add more form fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform edit avatar logic

                // Example:
                // _performEditAvatar(context);

                // Close the modal
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUsernameModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form field or button to edit username
              TextFormField(
                initialValue: username,
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (value) {
                  setState(() {
                    username = value;
                  });
                },
              ),
              // Add more form fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform edit username logic

                // Example:
                // _performEditUsername(context);

                // Close the modal
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditEmailModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form field or button to edit email
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              // Add more form fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform edit email logic

                // Example:
                // _performEditEmail(context);

                // Close the modal
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _refreshProfile(BuildContext context) async {
  //   try {
  //     // final profile = await _userService.getProfile();
  //     // Handle the profile data and update UI if needed
  //   } catch (error) {
  //     debugPrint('Error fetching profile: $error');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _showProfileModal(context);
              } else if (value == 'logout') {
                _performLogout(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Comminq',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  return ListTile(
                    title: Text(room),
                    onTap: () {
                      // Handle room selection
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
