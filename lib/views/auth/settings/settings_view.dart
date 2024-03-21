import 'dart:io';

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_sign_in/google_sign_in.dart";
import 'package:image_picker/image_picker.dart';
import "package:sentry_flutter/sentry_flutter.dart";

import "../../../utils/email_validator.dart";
import "../../../utils/secure_storage.dart";
import "../../../widgets/common/loading_indicator.dart";
import "../../../models/user_profile.dart";
import "../../../services/internet_connectivity.dart";
import "../../../services/user_service.dart";
import "../../../utils/constants.dart";
import "../../../utils/dialog_utils.dart";
import "../../../utils/helpers.dart";
import "../../../widgets/common/auth_button.dart";
import '../../../widgets/common/custom_avatar.dart';
import "../../../widgets/common/custom_text_field.dart";

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
  bool _isLoading = false;
  bool _enableUpdateProfile = false;
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController =
        TextEditingController(text: widget.userProfile.username);
    _emailController = TextEditingController(text: widget.userProfile.email);

    _usernameController.addListener(_updateProfileButtonState);
    _emailController.addListener(_updateProfileButtonState);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateProfileButtonState);
    _emailController.removeListener(_updateProfileButtonState);
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateProfileButtonState() {
    final bool isFormValid = _formKey.currentState!.validate();
    final bool usernameChanged =
        _usernameController.text.trim() != widget.userProfile.username;
    final bool emailChanged =
        _emailController.text.trim() != widget.userProfile.email;
    setState(() {
      _enableUpdateProfile = isFormValid && (usernameChanged || emailChanged);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String profilePicture =
        _pickedImage?.path ?? widget.userProfile.picture;

    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        key: _scaffoldKey,
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
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
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
                      child: !_isLoading
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomAvatar(
                                      profilePicture: profilePicture,
                                    )),
                                Positioned(
                                  top: 10,
                                  right: MediaQuery.of(context).size.width / 2 -
                                      67,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      enable: !_isLoading,
                      controller: _usernameController,
                      labelText: 'Name',
                      showSuffixIcon: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      enable: !_isLoading,
                      controller: _emailController,
                      labelText: 'Email',
                      showSuffixIcon: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        } else if (!isValidEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthButton(
                        isLoading: false,
                        label: 'Change Password',
                        onPressed:
                            !_isLoading ? _showChangePasswordDialog : null,
                        backgroundColor: Colors.yellow.shade900),
                    const SizedBox(height: 16),
                    AuthButton(
                      enable: _enableUpdateProfile,
                      isLoading: _isLoading,
                      label: "Update Profile",
                      onPressed: _isLoading ? null : _updateProfile,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCamera() async {
    Navigator.pop(context);
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _openGallery() async {
    Navigator.pop(context);
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
    }
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      InternetConnectivity.checkConnectivity(context).then((isConnected) {
        if (isConnected) {
          final secureStorage = TokenManager();

          final newUsername = _usernameController.text.trim();
          final newEmail = _emailController.text.trim();

          setState(() {
            _isLoading = true;
          });

          userHttpService
              .updateProfile(
            widget.userProfile.id,
            {"name": newUsername, "email": newEmail},
            profilePicture: _pickedImage?.path != null ? _pickedImage : null,
          )
              .then((response) {
            if (response.statusCode == 200) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Profile Updated"),
                    content: const Text(
                        'Your profile has been updated successfully.'),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          if (newEmail != widget.userProfile.email) {
                            try {
                              await secureStorage.deleteToken();
                              await GoogleSignIn().signOut();
                              if (mounted) {
                                return navigateToRoute(context, Routes.login);
                              }
                            } catch (error, stackTrace) {
                              Sentry.captureException(error,
                                  stackTrace: stackTrace);
                            } finally {}
                          }

                          widget.onUpdateProfile();
                          Navigator.of(context).pop();
                          Navigator.popUntil(
                            _scaffoldKey.currentContext!,
                            ModalRoute.withName(Routes.home),
                          );
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          }).catchError((error, stackTracer) {
            final errorData = error.response?.data;
            final errorMessage = errorData != null
                ? errorData['error']
                : 'Unknown error occurred';
            showErrorDialog(
              context: context,
              title: "Update Profile Error",
              content: errorMessage,
            );
            Sentry.captureException(
              errorMessage,
              stackTrace: stackTracer,
            );
          }).whenComplete(() {
            setState(() {
              _isLoading = false;
            });
          });
        }
      });
    }
  }

  void _showChangePasswordDialog() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordConfirmController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => hideKeyboard(context),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              if (widget.userProfile.googleLogin != null &&
                                  widget.userProfile.googleLogin == false)
                                CustomTextField(
                                  enable: !_isLoading,
                                  controller: currentPasswordController,
                                  labelText: 'Current password',
                                  showSuffixIcon: true,
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your current password';
                                    }
                                    return null;
                                  },
                                ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                enable: !_isLoading,
                                controller: newPasswordController,
                                labelText: 'New password',
                                showSuffixIcon: true,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your new password';
                                  }
                                  return null;
                                },
                              ),
                              CustomTextField(
                                enable: !_isLoading,
                                controller: newPasswordConfirmController,
                                labelText: 'Confirm new password',
                                showSuffixIcon: true,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your confirmation password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
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
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (formKey.currentState!.validate()) {
                                        if (newPasswordController.text !=
                                            newPasswordConfirmController.text) {
                                          return showErrorDialog(
                                              context: context,
                                              title: 'Confirmation password',
                                              content: "Passwords must match.");
                                        }
                                        _changePassword(
                                          currentPasswordController.text,
                                          newPasswordController.text,
                                          setState,
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: !_isLoading
                                  ? const Text(
                                      "Update",
                                      style: TextStyle(fontSize: 14),
                                    )
                                  : const LoadingIndicator(),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _changePassword(currentPassword, newPassword, Function setState) {
    InternetConnectivity.checkConnectivity(context).then((isConnected) {
      if (isConnected) {
        final secureStorage = TokenManager();

        setState(() {
          _isLoading = true;
        });
        userHttpService.changePassword(widget.userProfile.id, {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }).then((response) async {
          if (response.statusCode == 200) {
            // final message = response.data['message'];

            await secureStorage.deleteToken();
            await GoogleSignIn().signOut();
            if (mounted) {
              return navigateToRoute(context, Routes.login);
            }
          }
        }).catchError((error, stackTracer) {
          final errorData = error.response?.data;
          final errorMessage =
              errorData != null ? errorData['error'] : 'Unknown error occurred';
          showErrorDialog(
            context: context,
            title: "Change Password Error",
            content: errorMessage,
          );
          Sentry.captureException(errorMessage, stackTrace: stackTracer);
        }).whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }
}
