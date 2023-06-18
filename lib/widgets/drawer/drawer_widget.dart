import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../utils/helpers.dart';
import '../common/custom_avatar.dart';

class DrawerWidget extends StatelessWidget {
  final UserProfile? userProfile;
  final String? profilePicture;
  final bool hasProfilePicture;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLogoutPressed;

  const DrawerWidget({
    Key? key,
    required this.userProfile,
    required this.profilePicture,
    required this.hasProfilePicture,
    this.onSettingsPressed,
    this.onLogoutPressed,
  }) : super(key: key);

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
                    userProfile?.username ?? '',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              accountEmail: Text(
                userProfile?.email ?? '',
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
                    profilePicture: profilePicture,
                    hasProfilePicture: hasProfilePicture,
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
              onTap: onSettingsPressed,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: onLogoutPressed,
            ),
          ],
        ),
      ),
    );
  }
}
