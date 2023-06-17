import "package:flutter/material.dart";
import "package:flutter/services.dart";
import 'package:image_picker/image_picker.dart';
// import "package:sentry_flutter/sentry_flutter.dart";

import "../../../models/user_profile.dart";
import "../../../services/internet_connectivity.dart";
import "../../../services/user_service.dart";
// import "../../../utils/dialog_utils.dart";
import "../../../utils/dialog_utils.dart";
import "../../../utils/helpers.dart";
import "../../../widgets/common/auth_button.dart";
import "../../../widgets/common/custom_text_field.dart";
import '../../../widgets/common/custom_avatar.dart';

class SettingsView extends StatefulWidget {
  final UserProfile userProfile;
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userProfile.username);
    _emailController = TextEditingController(text: widget.userProfile.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    // check the internet here
    // check the internet here
    InternetConnectivity.checkConnectivity(context).then((isConnected) {
      if (isConnected) {
        _performUpdate();
      }
    });
  }

  void _performUpdate() {
    final newUsername = _usernameController.text.trim();
    final newEmail = _emailController.text.trim();

    ResponseProfile data = ResponseProfile(
        id: widget.userProfile.id,
        name: newUsername,
        email: newEmail,
        password: widget.userProfile.password,
        picture: widget.userProfile.picture);

    setState(() {
      isLoading = true;
    });

    userHttpService.updateProfile(widget.userProfile.id, data).then((response) {
      if (response.statusCode == 200) {
        debugPrint("Response $response");
        // Update success handling
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
                    widget.onUpdateProfile();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // final error = response.data?.;
        showErrorDialog(
          context: context,
          title: "Update Profile Error",
          content: "error",
        );
      }
    }).catchError((error) {
      return;
      // showErrorDialog(
      //   context: context,
      //   title: "Update Profile Error",
      //   content: error.toString(),
      // );
      // Sentry.captureException(error);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _openCamera() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      // Handle the picked image from camera
    }
  }

  Future<void> _openGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Handle the picked image from gallery
    }
  }

  @override
  Widget build(BuildContext context) {
    final String profilePicture = widget.userProfile.picture;
    final bool hasProfilePicture = profilePicture.isNotEmpty;

    return GestureDetector(
      onTap: () => hideKeyboard(context),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomAvatar(
                        profilePicture: profilePicture,
                        hasProfilePicture: hasProfilePicture,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: MediaQuery.of(context).size.width / 2 - 67,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera),
                                    title: const Text('Take a photo'),
                                    onTap: _openCamera,
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from gallery'),
                                    onTap: _openGallery,
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
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
