import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/environment.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/helpers.dart';
import '../../utils/secure_storage.dart';

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

  void _hideKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _fetchUserProfile() {
    setState(() {
      isLoading = true;
    });

    userHttpService.profile().then((response) {
      final profile = response;
      final profileUsername = profile.name;
      final profileEmail = profile.email;
      final profilePicture = profile.picture;

      final userProfile = UserProfile(
        username: profileUsername,
        email: profileEmail,
        picture: profilePicture,
      );

      debugPrint("UserProfile ${userProfile.email}");

      setState(() {
        _userProfile = userProfile;
      });
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
      onTap: _hideKeyboard,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(14),
              child: const Image(
                image: AssetImage('assets/icons/place_holder_avatar.png'),
                fit: BoxFit.cover,
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
          title: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        contentPadding: EdgeInsets.only(
                          left: 16,
                          bottom: 13,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.messenger),
                  onPressed: () {
                    // Open the messenger
                  },
                ),
              ],
            ),
          ),
        ),
        drawer: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                  ),
                  accountName: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        capitalizeFirstLetter(
                          _userProfile?.username ?? '',
                        ),
                      ),
                    ],
                  ),
                  accountEmail: Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(_userProfile?.email ?? ''),
                    ],
                  ),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      // Open user profile
                    },
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: const Image(
                          image: AssetImage(
                              'assets/icons/place_holder_avatar.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    // Open settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    _performLogout(context);
                  },
                ),
              ],
            ),
          ),
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
