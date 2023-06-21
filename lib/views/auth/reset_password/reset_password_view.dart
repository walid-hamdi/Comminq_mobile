import 'package:comminq/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../services/internet_connectivity.dart';
import '../../../utils/constants.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/common/auth_button.dart';
import '../../../widgets/common/custom_text_field.dart';
import '../../../widgets/common/custom_title_text.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({Key? key}) : super(key: key);

  @override
  createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool showCodeField = false;
  bool showPasswordField = false;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String code = _codeController.text;
      String newPassword = _passwordController.text;

      if (!showCodeField) {
        InternetConnectivity.checkConnectivity(context).then((isConnected) {
          if (isConnected) {
            _sendResetCode(email);
          }
        });
      } else if (!showPasswordField) {
        InternetConnectivity.checkConnectivity(context).then((isConnected) {
          if (isConnected) {
            _validateCode(code);
          }
        });
      } else {
        InternetConnectivity.checkConnectivity(context).then((isConnected) {
          if (isConnected) {
            _changePassword(newPassword);
          }
        });
      }
    }
  }

  void _sendResetCode(String email) {
    setState(() {
      isLoading = true;
    });
    userHttpService.forgotPassword(email).then((response) {
      // final message = response.data['message'];

      // showErrorDialog(
      //   context: context,
      //   title: "Reset Password",
      //   content: message,
      // );

      setState(() {
        showCodeField = true;
      });
    }).catchError((error) {
      final errorData = error.response?.data;
      final errorMessage =
          errorData != null ? errorData['error'] : 'Unknown error occurred';

      showErrorDialog(
        context: context,
        title: "Sent reset code error",
        content: errorMessage,
      );

      Sentry.captureException(errorMessage);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _validateCode(String code) {
    String email = _emailController.text;

    setState(() {
      isLoading = true;
    });
    userHttpService.verifyCode(email, code).then((response) {
      setState(() {
        showPasswordField = true;
      });
    }).catchError((error) {
      final errorData = error.response?.data;
      final errorMessage =
          errorData != null ? errorData['error'] : 'Unknown error occurred';

      showErrorDialog(
        context: context,
        title: "Verify Code Error",
        content: errorMessage,
      );

      Sentry.captureException(errorMessage);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _changePassword(String newPassword) {
    String code = _codeController.text;

    setState(() {
      isLoading = true;
    });

    userHttpService.changePasswordByCode(code, newPassword).then((response) {
      // Reset the form and hide code and password fields
      _formKey.currentState!.reset();
      setState(() {
        showCodeField = false;
        showPasswordField = false;
      });

      // Navigate back to the login screen
      _goToLogin();
    }).catchError((error) {
      final errorData = error.response?.data;
      final errorMessage =
          errorData != null ? errorData['error'] : 'Unknown error occurred';

      showErrorDialog(
        context: context,
        title: "Change Password Error",
        content: errorMessage,
      );

      Sentry.captureException(errorMessage);
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _goToLogin() {
    navigateToRoute(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ));

    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const CustomTitleText(text: '🔒 Reset Password'),
                  const SizedBox(height: 24),
                  if (!showCodeField)
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        }
                        return null;
                      },
                      showSuffixIcon: false,
                    ),
                  if (showCodeField && !showPasswordField) ...[
                    CustomTextField(
                      controller: _codeController,
                      labelText: 'Code',
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the code';
                        }
                        return null;
                      },
                      showSuffixIcon: false,
                    ),
                  ],
                  if (showPasswordField) ...[
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'New Password',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  AuthButton(
                    onPressed: isLoading ? null : _submitForm,
                    isLoading: isLoading,
                    label: !showCodeField
                        ? 'Send Code'
                        : !showPasswordField
                            ? 'Validate Code'
                            : 'Change Password',
                  ),
                  const SizedBox(height: 16),
                  AuthButton(
                      onPressed: _goToLogin,
                      isLoading: false,
                      label: "Back to Login"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
