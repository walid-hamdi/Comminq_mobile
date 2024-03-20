import 'package:comminq/utils/dialog_utils.dart';
import 'package:comminq/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../environment.dart';
import '../../models/user_profile.dart';
import '../../services/internet_connectivity.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/secure_storage.dart';
import '../../widgets/common/custom_avatar.dart';
import '../../widgets/drawer/drawer_widget.dart';
import '../auth/settings/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  late UserProfile _userProfile;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<Widget> _widgetOptions = <Widget>[
    Center(
      child: Text('Home'),
    ),
    Center(
      child: Text('Network'),
    ),
    Center(
      child: Text('Post'),
    ),
    Center(
      child: Text('Notifications'),
    ),
    Center(
      child: Text('Jobs'),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomAvatar(
                profilePicture: _userProfile.picture,
              ),
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // SizedBox(width: 10), // Add 10 pixels left spacing
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 10),
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              isCollapsed: true,
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.zero, // Remove bottom padding
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(
                  Icons.messenger,
                  size: 30,
                  color: Colors.grey,
                ),
                onPressed: () {
                  // Open the messenger
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        drawer: DrawerWidget(
          userProfile: _userProfile,
          profilePicture: _userProfile.picture,
          onSettingsPressed: () {
            if (_userProfile.id.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsView(
                    userProfile: _userProfile,
                    onUpdateProfile: _fetchUserProfile,
                  ),
                ),
              );
            } else {
              _performLogout(context);
            }
          },
          onLogoutPressed: () {
            _performLogout(context);
          },
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Network',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: 'Post',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: 'Jobs',
            ),
          ],
        ),
      ),
    );
  }

  void _fetchUserProfile() {
    InternetConnectivity.checkConnectivity(context).then((isConnected) {
      if (isConnected) {
        setState(() {
          isLoading = true;
          _userProfile =
              UserProfile(id: "", username: "", email: "", picture: "");
        });

        userHttpService.profile().then((response) {
          if (response.statusCode == 200) {
            final userProfile = UserProfile(
              id: response.data['_id'].toString(),
              username: response.data['name'].toString(),
              email: response.data['email'].toString(),
              picture: response.data['picture'].toString(),
              googleLogin: response.data['googleLogin'] as bool,
              isVerified: response.data['isVerified'] as bool,
            );

            if (userProfile.isVerified != null &&
                userProfile.isVerified == false) {
              return navigateToRoute(context, Routes.verifiedEmail);
            }

            setState(() {
              _userProfile = userProfile;
            });
          }
        }).catchError((error, stackTrace) {
          if (error.response.data['error'] ==
              'Email is not verified. Please verify your email.') {
            navigateToRoute(context, Routes.verifiedEmail,
                arguments: {'email': error.response.data['email'] as String});
            return;
          }
        }).whenComplete(() {
          setState(() {
            isLoading = false;
          });
        });
      }
    });
  }

  void _performLogout(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
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
                const Text(
                  'Are you sure you want to logout?',
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
                      onPressed: () {
                        _logout(setState);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: !isLoading
                          ? const Text(
                              'Logout',
                              style: TextStyle(fontSize: 14),
                            )
                          : const LoadingIndicator(),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }

  void _logout(setState) async {
    final secureStorage = TokenManager();

    setState(() {
      isLoading = true;
    });
    try {
      await secureStorage.deleteToken();
      await GoogleSignIn().signOut();
      if (mounted) {
        return navigateToRoute(context, Routes.login);
      }
    } catch (error, stackTracer) {
      Sentry.captureException(error, stackTrace: stackTracer);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
