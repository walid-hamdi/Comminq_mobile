import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../services/user_service.dart';
import '../../../utils/email_validator.dart';
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

  bool _isLoading = false;
  bool showCodeField = false;
  bool showPasswordField = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
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
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 10),
                  const CustomTitleText(text: '🔒 Reset Password'),
                  const SizedBox(height: 24),
                  if (!showCodeField)
                    CustomTextField(
                      enable: !_isLoading,
                      controller: _emailController,
                      labelText: 'Email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address';
                        } else if (!isValidEmail(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      showSuffixIcon: false,
                    ),
                  if (showCodeField && !showPasswordField) ...[
                    CustomTextField(
                      enable: !_isLoading,
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
                      enable: !_isLoading,
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
                    onPressed: _isLoading ? null : _submitForm,
                    isLoading: _isLoading,
                    label: !showCodeField
                        ? 'Send Code'
                        : !showPasswordField
                            ? 'Validate Code'
                            : 'Change Password',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String code = _codeController.text;
      String newPassword = _passwordController.text;
      setState(() {
        _isLoading = true;
      });

      if (!showCodeField) {
        InternetConnectivity.checkConnectivity(context).then((isConnected) {
          if (isConnected) {
            userHttpService.forgotPassword(
              {"email": email},
            ).then((response) {
              if (response.statusCode == 200) {
                final message = response.data['message'];
                showErrorDialog(
                  context: context,
                  title: "Send reset code",
                  content: message,
                );

                setState(() {
                  showCodeField = true;
                });
              }
            }).catchError((error, stackTracer) {
              final errorData = error.response?.data;
              final errorMessage = errorData != null
                  ? errorData['error']
                  : 'Unknown error occurred';

              showErrorDialog(
                context: context,
                title: "Sent reset code error",
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
      } else if (!showPasswordField) {
        InternetConnectivity.checkConnectivity(context).then((isConnected) {
          if (isConnected) {
            userHttpService
                .verifyCode({"email": email, "code": code}).then((response) {
              final message = response.data['message'];
              if (response.statusCode == 200) {
                showErrorDialog(
                  context: context,
                  title: "Verify code",
                  content: message,
                );
                setState(() {
                  showPasswordField = true;
                });
              }
            }).catchError((error, stackTracer) {
              final errorData = error.response?.data;
              final errorMessage = errorData != null
                  ? errorData['error']
                  : 'Unknown error occurred';

              showErrorDialog(
                context: context,
                title: "Verify code error",
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
      } else {
        InternetConnectivity.checkConnectivity(context).then((isConnected) {
          if (isConnected) {
            userHttpService.changePasswordByCode(
              {'code': code, 'newPassword': newPassword},
            ).then((response) {
              if (response.statusCode == 200) {
                _formKey.currentState!.reset();
                setState(() {
                  showCodeField = false;
                  showPasswordField = false;
                });
                navigateToRoute(context, Routes.login);
              }
            }).catchError((error, stackTracer) {
              final errorData = error.response?.data;
              final errorMessage = errorData != null
                  ? errorData['error']
                  : 'Unknown error occurred';

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
  }
}
