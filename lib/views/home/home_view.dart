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
                      CircleAvatar(
                        backgroundImage: NetworkImage(profilePicture),
                        radius: 50,
                      ),
                      const SizedBox(height: 16),
                      Text('Username: $profileUsername'),
                      Text('Email: $profileEmail'),
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

  void _navigateToSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  _performLogout(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Update Profile'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showUpdateProfileModal(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
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

  void _showUpdateProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add form fields to update user information
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                // Handle username input
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                // Handle email input
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
                _performUpdateProfile(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _performUpdateProfile(BuildContext context) {
    // Perform the update profile logic
    // You can access the form field values and update the user's information

    // Example:
    // final username = _usernameController.text;
    // final email = _emailController.text;

    // Call the API or perform necessary operations to update the user's information

    // Once the update is successful, you can show a success message and close the modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Profile updated successfully!'),
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
          IconButton(
            onPressed: () {
              _showAddRoomModal(context);
            },
            icon: const Icon(Icons.add),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            _showProfileModal(context);
          } else if (index == 2) {
            _navigateToSettings(context);
          }
        },
      ),
    );
  }

  void _showAddRoomModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
// Add form fields to add room information
              TextFormField(
                decoration: const InputDecoration(labelText: 'Room Name'),
// Handle room name input
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
                _performAddRoom(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _performAddRoom(BuildContext context) {
// Perform the add room logic
// You can access the form field values and add the room

// Example:
// final roomName = _roomNameController.text;

// Call the API or perform necessary operations to add the room

// Once the room is added successfully, you can show a success message and close the modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Room added successfully!'),
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
  }
}
