import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:sentry_flutter/sentry_flutter.dart";

import "../../../models/user_profile.dart";
import "../../../services/user_service.dart";
import "../../../utils/dialog_utils.dart";
import "../../../widgets/common/auth_button.dart";
import "../../../widgets/common/custom_text_field.dart";

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

  bool isLoading = false;

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
    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();

    // Update the user profile object directly
    // widget.userProfile?.username = newUsername;
    // widget.userProfile?.email = newEmail;

    final data = {
      'name': newUsername,
      'email': newEmail,
    };

    debugPrint("data $data");
    debugPrint("id ${widget.userProfile?.id ?? ''}");

    setState(() {
      isLoading = true;
    });
    try {
      userHttpService
          .updateProfile(widget.userProfile?.id, data)
          .then((response) {
        // Update success handling
        // Call the onUpdateProfile callback to refresh the user profile
        // widget.onUpdateProfile();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Profile Updated'),
              content:
                  const Text('Your profile has been updated successfully.'),
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
      }).catchError((error) {
        final String errorMessage = error.response.toString();
        showErrorDialog(
          context: context,
          title: "Update Profile Error",
          content: errorMessage,
        );
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    } catch (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  void _hideKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = widget.userProfile;

    return GestureDetector(
      onTap: _hideKeyboard,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: userProfile!.picture.isNotEmpty
                          ? Image.network(
                              userProfile.picture,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                            )
                          : const Image(
                              image: AssetImage(
                                'assets/icons/place_holder_avatar.png',
                              ),
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                            ),
                    ),
                    Positioned(
                      bottom: 30,
                      right: 90,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _usernameController,
                  labelText: 'Name',
                  showSuffixIcon: false,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  showSuffixIcon: false,
                ),
                const SizedBox(height: 16),
                AuthButton(
                  isLoading: isLoading,
                  label: "Update Profile",
                  onPressed: isLoading ? null : _updateProfile,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
