import 'package:comminq/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../utils/constants.dart';
import '../../utils/secure_storage.dart';
import '../../../models/user_profile.dart';
import '../../services/internet_connectivity.dart';
import '../../services/user_service.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/helpers.dart';
import '../common/custom_avatar.dart';

class DrawerWidget extends StatefulWidget {
  final UserProfile userProfile;
  final String profilePicture;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLogoutPressed;

  const DrawerWidget({
    Key? key,
    required this.userProfile,
    required this.profilePicture,
    this.onSettingsPressed,
    this.onLogoutPressed,
  }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  capitalizeFirstLetter(
                    widget.userProfile.username,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              accountEmail: Text(
                widget.userProfile.email,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  // Open user profile
                },
                child: Center(
                  child: CustomAvatar(
                    profilePicture: widget.profilePicture,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Hallway'),
              onTap: () {
                // Handle Hallway item tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.explore),
              title: const Text('Explore Clubs'),
              onTap: () {
                // Handle Explore Clubs item tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.collections),
              title: const Text('Your Clubs'),
              onTap: () {
                // Handle Your Clubs item tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {
                // Handle Bookmarks item tap
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: widget.onSettingsPressed,
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Delete Account'),
              onTap: _showDeleteAccountConfirmationDialog,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: widget.onLogoutPressed,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirmationDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Confirmation',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Are you sure you want to delete the account?'),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _deleteAccount(setState),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: !_isLoading
                            ? const Text(
                                "Delete",
                                style: TextStyle(fontSize: 14),
                              )
                            : const LoadingIndicator(),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteAccount(Function setState) {
    InternetConnectivity.checkConnectivity(context).then((isConnected) async {
      if (isConnected) {
        final secureStorage = TokenManager();
        if (widget.userProfile.id.isEmpty) {
          showErrorDialog(
            context: context,
            title: "ID not exist",
            content:
                'Your ID has not longer available, Please try to reconnect again.',
          );
          await secureStorage.deleteToken();
          await GoogleSignIn().signOut();
          if (mounted) return navigateToRoute(context, Routes.login);
        }

        setState(() {
          _isLoading = true;
        });

        userHttpService
            .deleteProfile(widget.userProfile.id)
            .then((response) async {
          if (response.statusCode == 200) {
            await secureStorage.deleteToken();
            await GoogleSignIn().signOut();
            if (mounted) return navigateToRoute(context, Routes.login);
          }
        }).catchError((error, stackTrace) {
          final errorData = error.response?.data;
          final errorMessage =
              errorData != null ? errorData['error'] : 'Unknown error occurred';

          showErrorDialog(
            context: context,
            title: "Delete Account Error",
            content: errorMessage,
          );

          Sentry.captureException(errorMessage, stackTrace: stackTrace);
        }).whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }
}
