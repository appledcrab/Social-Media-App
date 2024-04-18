import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:social_media_app/screens/message_screen.dart';
import 'package:social_media_app/screens/user_profile_screen.dart';
import 'package:social_media_app/screens/login/signin.dart'; // Import your sign-in screen
import 'package:social_media_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  AuthService authMethods = AuthService();
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = authMethods.getCurrentUser()!;
    // _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    currentUser = (await authMethods.getCurrentUser())!;
    setState(() {}); // Trigger a rebuild to reflect the current user
  }

  @override
  Widget build(BuildContext context) {
    // Only build the bottom navigation bar if the current user is available
    if (currentUser != null) {
      PersistentTabController _controller =
          PersistentTabController(initialIndex: 0);

      List<Widget> _buildScreens() {
        return [
          Scaffold(
            appBar: AppBar(title: Text('Home Feed')),
            body: Center(child: Text('Screen 1')),
            // Add the homecreen to the body when its made
            //where the actual posts will be displayed
            //just replace body
          ),
          Scaffold(
            appBar: AppBar(title: Text('Settings')),
            body: Center(child: Text('Screen 2')),
            // Add the Settings... or could try explore screen.
          ),
          Scaffold(
            appBar: AppBar(title: Text('Screen 3')),
            body: Center(child: Text('Screen 3')),
            //Adding posts screen
          ),
          Scaffold(
            body: RoomsPage(),
            //Adding chats screen
          ),
          Scaffold(
            body: ProfileScreen(userID: currentUser.uid),
            //Goes to personal profile screen
          ),
        ];
      }

      //these are aligned with the icons in the bottom nav bar and matches in order of the build screens.
      List<PersistentBottomNavBarItem> _navBarsItems() {
        return [
          PersistentBottomNavBarItem(
            icon: Icon(Icons.home),
            title: 'Home',
            activeColorPrimary: Colors.deepOrange,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.settings),
            title: 'Search',
            activeColorPrimary: const Color.fromARGB(255, 233, 33, 243),
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.add),
            title: "Add",
            activeColorPrimary: Color.fromARGB(255, 19, 141, 47),
            inactiveColorPrimary: Color.fromARGB(255, 50, 75, 59),
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.message),
            title: "Chats",
            activeColorPrimary: Colors.blue,
            inactiveColorPrimary: Colors.grey,
          ),
          PersistentBottomNavBarItem(
            icon: const Icon(Icons.person),
            title: "Profile",
            activeColorPrimary: const Color.fromARGB(255, 150, 0, 0),
            inactiveColorPrimary: Colors.grey,
          ),
        ];
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('Social Media App'),
          elevation: 0.0,
          centerTitle: false,
          actions: [
            IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  print("Profile");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileScreen(userID: currentUser.uid)),
                  );
                }),
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                print("Sign out");
                authMethods.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignIn()),
                );
              },
            ),
          ],
        ),
        body: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Color.fromARGB(255, 213, 233, 242),
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true,
          decoration: NavBarDecoration(
            colorBehindNavBar: Colors.white,
          ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimation(
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style4,
        ),
      );
    } else {
      // If the current user is not available, return a loading indicator or any other UI
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
