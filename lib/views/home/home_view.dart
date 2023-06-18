import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final _secureStorage = TokenManager();
  int _selectedIndex = 0;
  UserProfile? _userProfile;
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

  void _performLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                ),
                child: const Text('Cancel'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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
        return navigateToRoute(context, Routes.login);
      });
      navigateToRoute(context, Routes.login);
    }).catchError((error) {
      debugPrint('Error deleting token from secure storage: $error');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _fetchUserProfile() {
    // check the internet here
    InternetConnectivity.checkConnectivity(context).then((isConnected) {
      if (isConnected) {
        _performUserProfile();
      }
    });
  }

  void _performUserProfile() {
    setState(() {
      isLoading = true;
    });

    userHttpService.profile().then((response) {
      final profile = response;
      final profileUsername = profile.name;
      final profileEmail = profile.email;
      final profilePicture = profile.picture;
      final profilePassword = profile.password;

      final userProfile = UserProfile(
        id: profile.id,
        username: profileUsername,
        email: profileEmail,
        picture: profilePicture,
        password: profilePassword,
      );

      setState(() {
        _userProfile = userProfile;
      });
    }).catchError((error) {
      return;
      // final String errorMessage = error.response.toString();
      // showErrorDialog(
      //   context: context,
      //   title: "Retrieve Profile Error",
      //   content: errorMessage,
      // );
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final String? profilePicture = _userProfile?.picture;
    final bool hasProfilePicture =
        profilePicture != null && profilePicture.isNotEmpty;

    debugPrint("profile Picture $profilePicture");

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
                profilePicture: profilePicture,
                hasProfilePicture: hasProfilePicture,
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
                      SizedBox(
                          width:
                              10), // Add 10 pixels left padding for the hint text
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
          profilePicture: profilePicture,
          hasProfilePicture: hasProfilePicture,
          onSettingsPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsView(
                  userProfile: _userProfile!,
                  onUpdateProfile: _fetchUserProfile,
                ),
              ),
            );
          },
          onLogoutPressed: () {
            _performLogout(context);
          },
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
}
