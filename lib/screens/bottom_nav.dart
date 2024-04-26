import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:social_media_app/screens/homescreen.dart';
import 'package:social_media_app/screens/message_screen.dart';
import 'package:social_media_app/screens/post_screen.dart';
import 'package:social_media_app/screens/user_explore.dart';
import 'package:social_media_app/screens/user_profile_screen.dart';
import 'package:social_media_app/screens/login/signin.dart'; // Import your sign-in screen
import 'package:social_media_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import "package:social_media_app/main.dart";
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

OverlayEntry? _notificationPopup;

void _showNotificationPopup(String message, BuildContext context, Color color) {
  _notificationPopup?.remove(); // Remove any existing popup
  _notificationPopup = OverlayEntry(
    builder: (context) => Positioned(
      top: 50.0, // Distance from the top
      right: 10.0,
      left: 10.0,
      child: Material(
        elevation: 10.0,
        child: Container(
          padding: EdgeInsets.all(10),
          color: color,
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context)!.insert(_notificationPopup!);

  Future.delayed(Duration(seconds: 5), () {
    _hideNotificationPopup();
  });
}

void _hideNotificationPopup() {
  _notificationPopup?.remove();
  _notificationPopup = null;
}

class _BottomNavState extends State<BottomNav> {
  AuthService authMethods = AuthService();
  late User currentUser;

  late FirebaseMessaging messaging;
  String? notificationText;

  @override
  void initState() {
    super.initState();
    currentUser = authMethods.getCurrentUser()!;
    messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic("messaging");
    messaging.getToken().then((value) {
      print("CURRENT USER TOKEN:" + value!);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("Message received");
      String messageType = event.data['type'];
      Color bgColor = Colors.blue;
      if (messageType == 'post') {
        bgColor = Colors.orange;
      }
      //otherwise its message

      _showNotificationPopup(event.notification!.body!, context, bgColor);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
      _hideNotificationPopup();
    });
    // _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    currentUser = (await authMethods.getCurrentUser())!;
    setState(() {}); // rebuild to reflect the current user
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser != null) {
      PersistentTabController _controller =
          PersistentTabController(initialIndex: 0);

      List<Widget> _buildScreens() {
        return [
          Scaffold(
            appBar: AppBar(title: Text('Home Feed')),
            body: HomeFeed(),
            // Add the homecreen to the body when its made
            //where the actual posts will be displayed
            //just replace body
          ),
          Scaffold(
            body: UserListPage(),
            // Add the Settings... or could try explore screen.
          ),
          Scaffold(
            body: CreatePostScreen(),
            //Adding posts screen
          ),
          Scaffold(
            body: RoomsPage(),
            //Goes to chat screen that shows all the rooms
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
            icon: Icon(Icons.search),
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
                authMethods.signOut(context);
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
          hideNavigationBarWhenKeyboardShows: false,
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
